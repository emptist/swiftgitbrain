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
            case "send-heartbeat":
                try await handleSendHeartbeat(args: args)
            case "send-feedback":
                try await handleSendFeedback(args: args)
            case "send-code":
                try await handleSendCode(args: args)
            case "send-score":
                try await handleSendScore(args: args)
            case "check-heartbeats":
                try await handleCheckHeartbeats(args: args)
            case "check-feedbacks":
                try await handleCheckFeedbacks(args: args)
            case "check-codes":
                try await handleCheckCodes(args: args)
            case "check-scores":
                try await handleCheckScores(args: args)
            case "brainstate-create":
                try await handleBrainStateCreate(args: args)
            case "brainstate-load":
                try await handleBrainStateLoad(args: args)
            case "brainstate-save":
                try await handleBrainStateSave(args: args)
            case "brainstate-update":
                try await handleBrainStateUpdate(args: args)
            case "brainstate-get":
                try await handleBrainStateGet(args: args)
            case "brainstate-list":
                try await handleBrainStateList(args: args)
            case "brainstate-delete":
                try await handleBrainStateDelete(args: args)
            case "knowledge-add":
                try await handleKnowledgeAdd(args: args)
            case "knowledge-get":
                try await handleKnowledgeGet(args: args)
            case "knowledge-update":
                try await handleKnowledgeUpdate(args: args)
            case "knowledge-delete":
                try await handleKnowledgeDelete(args: args)
            case "knowledge-list":
                try await handleKnowledgeList(args: args)
            case "knowledge-search":
                try await handleKnowledgeSearch(args: args)
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
    
    private static func handleSendHeartbeat(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("send-heartbeat requires: <to> <ai_role> <status> [current_task] [metadata_key=value...]")
        }
        
        let to = args[0]
        let aiRole = args[1]
        let status = args[2]
        let currentTask = args.count > 3 ? args[3] : nil
        var metadata: [String: String] = [:]
        
        if args.count > 4 {
            for pair in args[4...] {
                let parts = pair.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    metadata[String(parts[0])] = String(parts[1])
                }
            }
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendHeartbeat(
                to: to,
                aiRole: aiRole,
                status: status,
                currentTask: currentTask,
                metadata: metadata.isEmpty ? nil : metadata
            )
            
            print("✓ Heartbeat sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  AI Role: \(aiRole)")
            print("  Status: \(status)")
            if let task = currentTask {
                print("  Current Task: \(task)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleSendFeedback(args: [String]) async throws {
        guard args.count >= 4 else {
            throw CLIError.invalidArguments("send-feedback requires: <to> <feedback_type> <subject> <content> [related_task_id]")
        }
        
        let to = args[0]
        let feedbackType = args[1]
        let subject = args[2]
        let content = args[3]
        let relatedTaskId = args.count > 4 ? args[4] : nil
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendFeedback(
                to: to,
                feedbackType: feedbackType,
                subject: subject,
                content: content,
                relatedTaskId: relatedTaskId,
                messagePriority: .normal
            )
            
            print("✓ Feedback sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  Type: \(feedbackType)")
            print("  Subject: \(subject)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleSendCode(args: [String]) async throws {
        guard args.count >= 5 else {
            throw CLIError.invalidArguments("send-code requires: <to> <code_id> <title> <description> <files...> [branch] [commit_sha]")
        }
        
        let to = args[0]
        let codeId = args[1]
        let title = args[2]
        let description = args[3]
        let files = args.count > 4 ? [args[4]] : []
        let branch = args.count > 5 ? args[5] : nil
        let commitSha = args.count > 6 ? args[6] : nil
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendCode(
                to: to,
                codeId: codeId,
                title: title,
                description: description,
                files: files,
                branch: branch,
                commitSha: commitSha,
                messagePriority: .normal
            )
            
            print("✓ Code sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  Code ID: \(codeId)")
            print("  Title: \(title)")
            print("  Files: \(files.joined(separator: ", "))")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleSendScore(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("send-score requires: <to> <task_id> <requested_score> <quality_justification>")
        }
        
        let to = args[0]
        let taskId = args[1]
        let requestedScore = Int(args[2]) ?? 0
        let qualityJustification = args.count > 3 ? args[3] : "No justification provided"
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: "CLI")
            
            let messageId = try await messageCache.sendScore(
                to: to,
                taskId: taskId,
                requestedScore: requestedScore,
                qualityJustification: qualityJustification,
                messagePriority: .normal
            )
            
            print("✓ Score request sent to: \(to)")
            print("  Message ID: \(messageId)")
            print("  Task ID: \(taskId)")
            print("  Requested Score: \(requestedScore)")
            print("  Justification: \(qualityJustification)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckHeartbeats(args: [String]) async throws {
        let aiName = args.first ?? "OverseerAI"
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let heartbeats = try await messageCache.receiveHeartbeats(for: aiName)
            
            print("Heartbeats for '\(aiName)': \(heartbeats.count)")
            
            if !heartbeats.isEmpty {
                print("\nHeartbeats:")
                for hb in heartbeats {
                    print("  From: \(hb.fromAI)")
                    print("    Role: \(hb.aiRole)")
                    print("    Status: \(hb.status)")
                    if let task = hb.currentTask {
                        print("    Current Task: \(task)")
                    }
                    print("    Created: \(hb.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckFeedbacks(args: [String]) async throws {
        let aiName = args.first ?? "CoderAI"
        let statusRaw = args.count > 1 ? args[1] : "pending"
        
        guard let status = FeedbackStatus(rawValue: statusRaw) else {
            print("Invalid status. Valid statuses: \(FeedbackStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(statusRaw)")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let feedbacks = try await messageCache.receiveFeedbacks(for: aiName, status: status)
            
            print("Feedbacks for '\(aiName)' with status '\(status.rawValue)': \(feedbacks.count)")
            
            if !feedbacks.isEmpty {
                print("\nFeedbacks:")
                for fb in feedbacks {
                    print("  [\(fb.feedbackType)] \(fb.subject)")
                    print("    From: \(fb.fromAI)")
                    print("    Content: \(fb.content)")
                    print("    Created: \(fb.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckCodes(args: [String]) async throws {
        let aiName = args.first ?? "ReviewerAI"
        let statusRaw = args.count > 1 ? args[1] : "pending"
        
        guard let status = CodeStatus(rawValue: statusRaw) else {
            print("Invalid status. Valid statuses: \(CodeStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(statusRaw)")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let codes = try await messageCache.receiveCodes(for: aiName, status: status)
            
            print("Code messages for '\(aiName)' with status '\(status.rawValue)': \(codes.count)")
            
            if !codes.isEmpty {
                print("\nCode Messages:")
                for code in codes {
                    print("  [\(code.codeId)] \(code.title)")
                    print("    From: \(code.fromAI)")
                    print("    Description: \(code.description)")
                    print("    Files: \(code.files.joined(separator: ", "))")
                    print("    Created: \(code.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleCheckScores(args: [String]) async throws {
        let aiName = args.first ?? "OverseerAI"
        let statusRaw = args.count > 1 ? args[1] : "pending"
        
        guard let status = ScoreStatus(rawValue: statusRaw) else {
            print("Invalid status. Valid statuses: \(ScoreStatus.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid status: \(statusRaw)")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let messageCache = try await dbManager.createMessageCacheManager(forAI: aiName)
            
            let scores = try await messageCache.receiveScores(for: aiName, status: status)
            
            print("Score requests for '\(aiName)' with status '\(status.rawValue)': \(scores.count)")
            
            if !scores.isEmpty {
                print("\nScore Requests:")
                for score in scores {
                    print("  [\(score.taskId)] Requested: \(score.requestedScore)")
                    print("    From: \(score.fromAI)")
                    print("    Justification: \(score.qualityJustification)")
                    print("    Created: \(score.timestamp)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateCreate(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("brainstate-create requires: <ai_name> <role> [state_json]")
        }
        
        let aiName = args[0]
        guard let role = RoleType(rawValue: args[1]) else {
            print("Invalid role. Valid roles: \(RoleType.allCases.map { $0.rawValue }.joined(separator: ", "))")
            throw CLIError.invalidArguments("Invalid role: \(args[1])")
        }
        
        var initialState: SendableContent? = nil
        if args.count > 2 {
            let jsonData = args[2].data(using: .utf8)!
            let json = try JSONSerialization.jsonObject(with: jsonData)
            if let dict = json as? [String: Any] {
                initialState = SendableContent(dict)
            }
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            let state = try await brainStateManager.createBrainState(aiName: aiName, role: role, initialState: initialState)
            
            print("✓ Brain state created")
            print("  AI Name: \(state.aiName)")
            print("  Role: \(state.role)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateLoad(args: [String]) async throws {
        guard args.count >= 1 else {
            throw CLIError.invalidArguments("brainstate-load requires: <ai_name>")
        }
        
        let aiName = args[0]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            guard let state = try await brainStateManager.loadBrainState(aiName: aiName) else {
                print("Brain state not found: \(aiName)")
                try await dbManager.close()
                return
            }
            
            print("Brain State: \(aiName)")
            print("  Role: \(state.role)")
            print("  Last Updated: \(state.lastUpdated)")
            print("  State: \(state.state)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateSave(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("brainstate-save requires: <ai_name> <role> <state_json>")
        }
        
        let aiName = args[0]
        guard let role = RoleType(rawValue: args[1]) else {
            throw CLIError.invalidArguments("Invalid role: \(args[1])")
        }
        
        let jsonData = args[2].data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let dict = json as? [String: Any] else {
            throw CLIError.invalidJSON("State must be a JSON object")
        }
        
        let brainState = BrainState(
            aiName: aiName,
            role: role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: dict
        )
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            try await brainStateManager.saveBrainState(brainState)
            print("✓ Brain state saved: \(aiName)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateUpdate(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("brainstate-update requires: <ai_name> <key> <value_json>")
        }
        
        let aiName = args[0]
        let key = args[1]
        let jsonData = args[2].data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let dict = json as? [String: Any] else {
            throw CLIError.invalidJSON("Value must be a JSON object")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            let success = try await brainStateManager.updateBrainState(aiName: aiName, key: key, value: SendableContent(dict))
            
            if success {
                print("✓ Brain state updated: \(aiName).\(key)")
            } else {
                print("⚠️ Brain state not found: \(aiName)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateGet(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("brainstate-get requires: <ai_name> <key>")
        }
        
        let aiName = args[0]
        let key = args[1]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            if let value = try await brainStateManager.getBrainStateValue(aiName: aiName, key: key, defaultValue: nil) {
                print("Brain state value: \(aiName).\(key)")
                print("  Value: \(value.toAnyDict())")
            } else {
                print("Key not found: \(aiName).\(key)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateList(args: [String]) async throws {
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            let aiNames = try await brainStateManager.listBrainStates()
            
            print("Brain States: \(aiNames.count)")
            for name in aiNames {
                print("  - \(name)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleBrainStateDelete(args: [String]) async throws {
        guard args.count >= 1 else {
            throw CLIError.invalidArguments("brainstate-delete requires: <ai_name>")
        }
        
        let aiName = args[0]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let brainStateManager = try await dbManager.createBrainStateManager()
            
            let success = try await brainStateManager.deleteBrainState(aiName: aiName)
            
            if success {
                print("✓ Brain state deleted: \(aiName)")
            } else {
                print("⚠️ Brain state not found: \(aiName)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeAdd(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("knowledge-add requires: <category> <key> <value_json>")
        }
        
        let category = args[0]
        let key = args[1]
        let jsonData = args[2].data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let dict = json as? [String: Any] else {
            throw CLIError.invalidJSON("Value must be a JSON object")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            try await knowledgeBase.addKnowledge(category: category, key: key, value: SendableContent(dict), metadata: nil)
            print("✓ Knowledge added: \(category)/\(key)")
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeGet(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("knowledge-get requires: <category> <key>")
        }
        
        let category = args[0]
        let key = args[1]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            if let value = try await knowledgeBase.getKnowledge(category: category, key: key) {
                print("Knowledge: \(category)/\(key)")
                print("  Value: \(value.toAnyDict())")
            } else {
                print("Knowledge not found: \(category)/\(key)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeUpdate(args: [String]) async throws {
        guard args.count >= 3 else {
            throw CLIError.invalidArguments("knowledge-update requires: <category> <key> <value_json>")
        }
        
        let category = args[0]
        let key = args[1]
        let jsonData = args[2].data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let dict = json as? [String: Any] else {
            throw CLIError.invalidJSON("Value must be a JSON object")
        }
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            let success = try await knowledgeBase.updateKnowledge(category: category, key: key, value: SendableContent(dict), metadata: nil)
            
            if success {
                print("✓ Knowledge updated: \(category)/\(key)")
            } else {
                print("⚠️ Knowledge not found: \(category)/\(key)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeDelete(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("knowledge-delete requires: <category> <key>")
        }
        
        let category = args[0]
        let key = args[1]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            let success = try await knowledgeBase.deleteKnowledge(category: category, key: key)
            
            if success {
                print("✓ Knowledge deleted: \(category)/\(key)")
            } else {
                print("⚠️ Knowledge not found: \(category)/\(key)")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeList(args: [String]) async throws {
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            if args.isEmpty {
                let categories = try await knowledgeBase.listCategories()
                print("Categories: \(categories.count)")
                for cat in categories {
                    print("  - \(cat)")
                }
            } else {
                let category = args[0]
                let keys = try await knowledgeBase.listKeys(category: category)
                print("Keys in '\(category)': \(keys.count)")
                for key in keys {
                    print("  - \(key)")
                }
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
        }
    }
    
    private static func handleKnowledgeSearch(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("knowledge-search requires: <category> <query>")
        }
        
        let category = args[0]
        let query = args[1]
        
        let dbManager = DatabaseManager()
        do {
            _ = try await dbManager.initialize()
            let knowledgeBase = try await dbManager.createKnowledgeBase()
            
            let results = try await knowledgeBase.searchKnowledge(category: category, query: query)
            
            print("Search results: \(results.count)")
            for (index, value) in results.enumerated() {
                print("  \(index + 1). \(value.toAnyDict())")
            }
            
            try await dbManager.close()
        } catch {
            throw CLIError.databaseError(error.localizedDescription)
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
          
          Code Commands:
          send-code <to> <code_id> <title> <description> <files...> [branch] [commit_sha]
                               Send code for review
          check-codes [ai_name] [status]
                               Check code messages for an AI (default: pending)
          
          Score Commands:
          send-score <to> <task_id> <requested_score> <quality_justification>
                               Request a score from another AI
          check-scores [ai_name] [status]
                               Check score requests for an AI (default: pending)
          
          Feedback Commands:
          send-feedback <to> <feedback_type> <subject> <content> [related_task_id]
                               Send feedback to another AI
          check-feedbacks [ai_name] [status]
                               Check feedbacks for an AI (default: pending)
          
          Heartbeat Commands:
          send-heartbeat <to> <ai_role> <status> [current_task] [metadata_key=value...]
                               Send a heartbeat to show AI is alive
          check-heartbeats [ai_name]
          
          BrainState Commands:
          brainstate-create <ai_name> <role> [state_json]
                               Create a brain state for an AI
          brainstate-load <ai_name>
                               Load brain state for an AI
          brainstate-save <ai_name> <role> <state_json>
                               Save brain state for an AI
          brainstate-update <ai_name> <key> <value_json>
                               Update a key in brain state
          brainstate-get <ai_name> <key>
                               Get a value from brain state
          brainstate-list
                               List all brain states
          brainstate-delete <ai_name>
                               Delete a brain state
          
          Knowledge Commands:
          knowledge-add <category> <key> <value_json>
                               Add knowledge to the knowledge base
          knowledge-get <category> <key>
                               Get knowledge from the knowledge base
          knowledge-update <category> <key> <value_json>
                               Update knowledge in the knowledge base
          knowledge-delete <category> <key>
                               Delete knowledge from the knowledge base
          knowledge-list [category]
                               List categories or keys in a category
          knowledge-search <category> <query>
                               Search knowledge in a category
                               Check heartbeats for an AI
          
          BrainState Commands:
          brainstate-create <ai_name> <role> [state_json]
                               Create a brain state for an AI
          brainstate-load <ai_name>
                               Load brain state for an AI
          brainstate-save <ai_name> <role> <state_json>
                               Save brain state for an AI
          brainstate-update <ai_name> <key> <value_json>
                               Update a key in brain state
          brainstate-get <ai_name> <key>
                               Get a value from brain state
          brainstate-list
                               List all brain states
          brainstate-delete <ai_name>
                               Delete a brain state
          
          Knowledge Commands:
          knowledge-add <category> <key> <value_json>
                               Add knowledge to the knowledge base
          knowledge-get <category> <key>
                               Get knowledge from the knowledge base
          knowledge-update <category> <key> <value_json>
                               Update knowledge in the knowledge base
          knowledge-delete <category> <key>
                               Delete knowledge from the knowledge base
          knowledge-list [category]
                               List categories or keys in a category
          knowledge-search <category> <query>
                               Search knowledge in a category
          
          help                 Show this help message
        
        Task Types: \(TaskType.allCases.map { $0.rawValue }.joined(separator: ", "))
        Task Statuses: \(TaskStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        Review Statuses: \(ReviewStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        Code Statuses: \(CodeStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        Score Statuses: \(ScoreStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        Feedback Statuses: \(FeedbackStatus.allCases.map { $0.rawValue }.joined(separator: ", "))
        
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
          gitbrain send-heartbeat OverseerAI CoderAI working "Implementing feature"
          gitbrain send-feedback CoderAI performance "Great work" "Keep it up!"
        """)
    }
}
