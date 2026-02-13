import Foundation
import GitBrainSwift

enum CLIError: LocalizedError {
    case unknownCommand(String)
    case invalidArguments(String)
    case invalidRecipient(String)
    case invalidJSON(String)
    case fileNotFound(String)
    case initializationError(String)
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .unknownCommand(let command):
            return "Unknown command: \(command)"
        case .invalidArguments(let message):
            return "Invalid arguments: \(message)"
        case .invalidRecipient(let recipient):
            return "Unknown recipient: \(recipient)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .initializationError(let message):
            return "Initialization error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}

@main
struct GitBrainCLI {
    static func main() async {
        let arguments = CommandLine.arguments
        
        guard arguments.count > 1 else {
            printUsage()
            Foundation.exit(0)
        }
        
        let command = arguments[1]
        let args = Array(arguments.dropFirst(2))
        
        do {
            switch command {
            case "init":
                try await handleInit(args: args)
            case "send-task":
                try await handleSendTask(args: args)
            case "send-review":
                try await handleSendReview(args: args)
            case "check-tasks":
                try await handleCheckTasks(args: args)
            case "check-reviews":
                try await handleCheckReviews(args: args)
            case "update-task":
                try await handleUpdateTask(args: args)
            case "update-review":
                try await handleUpdateReview(args: args)
            case "score-request":
                try await handleScoreRequest(args: args)
            case "score-award":
                try await handleScoreAward(args: args)
            case "score-reject":
                try await handleScoreReject(args: args)
            case "score-history":
                try await handleScoreHistory(args: args)
            case "score-requests":
                try await handleScoreRequests(args: args)
            case "score-all-requests":
                try await handleScoreAllRequests(args: args)
            case "help", "--help", "-h":
                printUsage()
            default:
                print("Unknown command: \(command)")
                printUsage()
                throw CLIError.unknownCommand(command)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            Foundation.exit(1)
        }
    }
    
    private static func getGitBrainPath() -> String {
        if let envPath = ProcessInfo.processInfo.environment["GITBRAIN_PATH"] {
            return envPath
        }
        return "./GitBrain"
    }
    
    private static func handleInit(args: [String]) async throws {
        let gitBrainPath = args.first ?? getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let docsURL = gitBrainURL.appendingPathComponent("Docs")
        
        print("Initializing GitBrain...")
        print("Path: \(gitBrainPath)")
        if ProcessInfo.processInfo.environment["GITBRAIN_PATH"] != nil {
            print("Using environment variable: GITBRAIN_PATH")
        }
        
        let fileManager = FileManager.default
        
        try fileManager.createDirectory(at: overseerURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: memoryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: docsURL, withIntermediateDirectories: true)
        
        print("✓ Created GitBrain/Overseer/")
        print("✓ Created GitBrain/Memory/")
        print("✓ Created GitBrain/Docs/")
        
        let readmeContent = """
        # GitBrain Development Folder
        
        This folder is used for AI-assisted collaborative development.
        
        ## Structure
        
        - **Overseer/**: Working folder for OverseerAI (write access)
        - **Memory/**: Shared persistent memory
        - **Docs/**: Documentation for AIs
        
        ## Usage
        
        ### For CoderAI
        Open Trae at project root:
        ```
        trae .
        ```
        
        CoderAI has access to all folders in the project.
        
        ### For OverseerAI
        Open Trae at Overseer folder:
        ```
        trae ./GitBrain/Overseer
        ```
        
        OverseerAI has read access to the whole project and write access to GitBrain/Overseer/.
        
        ## Communication
        
        Messages are stored in PostgreSQL database via MessageCache.
        Sub-millisecond latency for AI-to-AI communication.
        
        ## Cleanup
        
        After development is complete, you can safely remove this folder:
        ```
        rm -rf GitBrain
        ```
        """
        
        let readmeURL = gitBrainURL.appendingPathComponent("README.md")
        try readmeContent.write(to: readmeURL, atomically: true, encoding: .utf8)
        
        print("✓ Created GitBrain/README.md")
        print("\nInitialization complete!")
        print("\nNext steps:")
        print("1. Ensure PostgreSQL is running")
        print("2. Run migrations: swift run gitbrain-migrate migrate")
        print("3. Open Trae at project root for CoderAI: trae .")
        print("4. Open Trae at GitBrain for OverseerAI: trae ./GitBrain")
    }
    
    private static func handleSendTask(args: [String]) async throws {
        guard args.count >= 4 else {
            print("Usage: gitbrain send-task <to> <task_id> <description> <task_type> [priority] [files...]")
            throw CLIError.invalidArguments("send-task requires: <to> <task_id> <description> <task_type>")
        }
        
        let to = args[0]
        let taskId = args[1]
        let description = args[2]
        guard let taskType = TaskType(rawValue: args[3]) else {
            print("Invalid task type. Valid types: \(TaskType.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid task type: \(args[3])")
        }
        
        let priority = args.count > 4 ? Int(args[4]) ?? 1 : 1
        let files = args.count > 5 ? Array(args[5...]) : nil
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendTask(
                to: to,
                taskId: taskId,
                description: description,
                taskType: taskType,
                priority: priority,
                files: files,
                deadline: nil,
                messagePriority: .normal
            )
            
            print("✓ Task sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  Task ID: \(taskId)")
            print("  Type: \(taskType.rawValue)")
            print("  Priority: \(priority)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleSendReview(args: [String]) async throws {
        guard args.count >= 4 else {
            print("Usage: gitbrain send-review <to> <task_id> <approved> <reviewer> [feedback]")
            throw CLIError.invalidArguments("send-review requires: <to> <task_id> <approved> <reviewer>")
        }
        
        let to = args[0]
        let taskId = args[1]
        let approved = args[2].lowercased() == "true"
        let reviewer = args[3]
        let feedback = args.count > 4 ? args[4] : nil
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendReview(
                to: to,
                taskId: taskId,
                approved: approved,
                reviewer: reviewer,
                comments: nil,
                feedback: feedback,
                filesReviewed: nil,
                messagePriority: .normal
            )
            
            print("✓ Review sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  Task ID: \(taskId)")
            print("  Approved: \(approved)")
            print("  Reviewer: \(reviewer)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckTasks(args: [String]) async throws {
        let aiName = args.first ?? "CoderAI"
        let statusRaw = args.count > 1 ? args[1] : "pending"
        
        guard let status = TaskStatus(rawValue: statusRaw) else {
            print("Invalid status. Valid statuses: \(TaskStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(statusRaw)")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let tasks = try await messageCache.receiveTasks(for: aiName, status: status)
            
            print("Tasks for '\(aiName)' with status '\(status.rawValue)': \(tasks.count)")
            
            if !tasks.isEmpty {
                print("\nTasks:")
                for task in tasks {
                    print("  [\(task.taskId)] \(task.description)")
                    print("    From: \(task.fromAI)")
                    print("    Type: \(task.taskType)")
                    print("    Priority: \(task.priority)")
                    print("    Created: \(task.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckReviews(args: [String]) async throws {
        let aiName = args.first ?? "CoderAI"
        let statusRaw = args.count > 1 ? args[1] : "pending"
        
        guard let status = ReviewStatus(rawValue: statusRaw) else {
            print("Invalid status. Valid statuses: \(ReviewStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(statusRaw)")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let reviews = try await messageCache.receiveReviews(for: aiName, status: status)
            
            print("Reviews for '\(aiName)' with status '\(status.rawValue)': \(reviews.count)")
            
            if !reviews.isEmpty {
                print("\nReviews:")
                for review in reviews {
                    print("  [\(review.taskId)] Approved: \(review.approved)")
                    print("    From: \(review.fromAI)")
                    print("    Reviewer: \(review.reviewer)")
                    if let feedback = review.feedback {
                        print("    Feedback: \(feedback)")
                    }
                    print("    Created: \(review.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleUpdateTask(args: [String]) async throws {
        guard args.count >= 2 else {
            print("Usage: gitbrain update-task <message_id> <status>")
            throw CLIError.invalidArguments("update-task requires: <message_id> <status>")
        }
        
        guard let messageId = UUID(uuidString: args[0]) else {
            throw CLIError.invalidArguments("Invalid UUID: \(args[0])")
        }
        
        guard let status = TaskStatus(rawValue: args[1]) else {
            print("Invalid status. Valid statuses: \(TaskStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(args[1])")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let success = try await messageCache.updateTaskStatus(messageId: messageId, to: status)
            
            if success {
                print("✓ Task status updated to: \(status.rawValue)")
                print("  Message ID: \(messageId)")
            } else {
                print("⚠️ Task not found or update failed")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleUpdateReview(args: [String]) async throws {
        guard args.count >= 2 else {
            print("Usage: gitbrain update-review <message_id> <status>")
            throw CLIError.invalidArguments("update-review requires: <message_id> <status>")
        }
        
        guard let messageId = UUID(uuidString: args[0]) else {
            throw CLIError.invalidArguments("Invalid UUID: \(args[0])")
        }
        
        guard let status = ReviewStatus(rawValue: args[1]) else {
            print("Invalid status. Valid statuses: \(ReviewStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(args[1])")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let success = try await messageCache.updateReviewStatus(messageId: messageId, to: status)
            
            if success {
                print("✓ Review status updated to: \(status.rawValue)")
                print("  Message ID: \(messageId)")
            } else {
                print("⚠️ Review not found or update failed")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleScoreRequest(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("score-request requires: <task_id> <requested_score> <quality_justification> [requester] [target_ai]")
        }
        
        let taskId = args[0]
        let requestedScore = Int(args[1]) ?? 0
        let qualityJustification = args[2]
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let requester = args.count > 3 ? args[3] : "coder"
        let targetAI = args.count > 4 ? args[4] : "overseer"
        
        try await scoreManager.requestScore(taskId: taskId, requester: requester, targetAI: targetAI, requestedScore: requestedScore, qualityJustification: qualityJustification)
        
        print("✓ Score request sent to \(targetAI)")
        print("  Task ID: \(taskId)")
        print("  Requested Score: \(requestedScore)")
        print("  Justification: \(qualityJustification)")
        print("  Requester: \(requester)")
    }
    
    private static func handleScoreAward(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("score-award requires: <request_id> <awarded_score> <reason> [awarder]")
        }
        
        let requestId = Int(args[0]) ?? 0
        let awardedScore = Int(args[1]) ?? 0
        let reason = args[2]
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let awarder = args.count > 3 ? args[3] : "overseer"
        
        try await scoreManager.awardScore(requestId: requestId, awarder: awarder, awardedScore: awardedScore, reason: reason)
        
        print("✓ Score awarded")
        print("  Request ID: \(requestId)")
        print("  Awarded Score: \(awardedScore)")
        print("  Reason: \(reason)")
        print("  Awarder: \(awarder)")
    }
    
    private static func handleScoreReject(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("score-reject requires: <request_id> <reason> [rejecter]")
        }
        
        let requestId = Int(args[0]) ?? 0
        let reason = args[1]
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let rejecter = args.count > 2 ? args[2] : "overseer"
        
        try await scoreManager.rejectScore(requestId: requestId, rejecter: rejecter, reason: reason)
        
        print("✓ Score request rejected")
        print("  Request ID: \(requestId)")
        print("  Reason: \(reason)")
        print("  Rejecter: \(rejecter)")
    }
    
    private static func handleScoreHistory(args: [String]) async throws {
        let aiName = args.first ?? "coder"
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let history = try await scoreManager.getScoreHistory(for: aiName)
        
        print("Score History for \(aiName):")
        print("================================")
        
        if history.isEmpty {
            print("No score history found")
        } else {
            print("| ID | Change | Reason | Requester | Awarder | Created At |")
            print("|----|--------|--------|-----------|---------|-------------|")
            
            for entry in history {
                print("| \(entry.0) | \(entry.1) | \(entry.2) | \(entry.3) | \(entry.4) | \(entry.5) |")
            }
        }
    }
    
    private static func handleScoreRequests(args: [String]) async throws {
        let targetAI = args.first ?? "overseer"
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let requests = try await scoreManager.getPendingScoreRequests(for: targetAI)
        
        print("Pending Score Requests for \(targetAI):")
        print("=======================================")
        
        if requests.isEmpty {
            print("No pending score requests")
        } else {
            print("| ID | Task ID | Requester | Requested Score | Justification | Created At |")
            print("|----|---------|-----------|-----------------|---------------|-------------|")
            
            for request in requests {
                print("| \(request.0) | \(request.1) | \(request.2) | \(request.3) | \(request.4) | \(request.5) |")
            }
        }
    }
    
    private static func handleScoreAllRequests(args: [String]) async throws {
        let targetAI = args.first ?? "overseer"
        
        let gitBrainPath = getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let scoresDBPath = memoryURL.appendingPathComponent("scores.db").path
        
        let scoreManager = ScoreManager(dbPath: scoresDBPath)
        try await scoreManager.initialize()
        
        let requests = try await scoreManager.getAllScoreRequests(for: targetAI)
        
        print("All Score Requests for \(targetAI):")
        print("==================================")
        
        if requests.isEmpty {
            print("No score requests found")
        } else {
            print("| ID | Task ID | Requester | Requested Score | Justification | Status | Created At |")
            print("|----|---------|-----------|-----------------|---------------|--------|-------------|")
            
            for request in requests {
                print("| \(request.0) | \(request.1) | \(request.2) | \(request.3) | \(request.4) | \(request.5) | \(request.6) |")
            }
        }
    }
    
    private static func printUsage() {
        print("""
        GitBrain CLI - AI-Assisted Collaborative Development Tool
        
        Usage: gitbrain <command> [arguments]
        
        Commands:
          init [path]          Initialize GitBrain folder structure
          
          Task Commands:
          send-task <to> <task_id> <description> <task_type> [priority] [files...]
                               Send a task message to another AI
          check-tasks [ai_name] [status]
                               Check tasks for an AI (default: pending)
          update-task <message_id> <status>
                               Update task status
          
          Review Commands:
          send-review <to> <task_id> <approved> <reviewer> [feedback]
                               Send a review message to another AI
          check-reviews [ai_name] [status]
                               Check reviews for an AI (default: pending)
          update-review <message_id> <status>
                               Update review status
          
          Score Commands:
          score-request <task_id> <requested_score> <quality_justification> [requester] [target_ai]
                               Request a score from the other AI
          score-award <request_id> <awarded_score> <reason> [awarder]
                               Award a score to the other AI
          score-reject <request_id> <reason> [rejecter]
                               Reject a score request
          score-history [ai_name]
                               View score history for an AI
          score-requests [ai_name]
                               View pending score requests for an AI
          score-all-requests [ai_name]
                               View all score requests for an AI
          
          help                 Show this help message
        
        Task Types: \(TaskType.allCases.map { $0.rawValue }.joined(separator: ", "))
        Task Statuses: \(TaskStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        Review Statuses: \(ReviewStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        
        Environment Variables:
          GITBRAIN_PATH        Default path to GitBrain folder (overrides ./GitBrain)
          GITBRAIN_DB_HOST     Database host (default: localhost)
          GITBRAIN_DB_PORT     Database port (default: 5432)
          GITBRAIN_DB_NAME     Database name (default: gitbrain)
          GITBRAIN_DB_USER     Database user (default: postgres)
          GITBRAIN_DB_PASSWORD Database password (default: postgres)
        
        Examples:
          gitbrain init
          gitbrain send-task OverseerAI task-001 "Review code" review 1
          gitbrain check-tasks CoderAI pending
          gitbrain update-task <uuid> in_progress
        """)
    }
}
