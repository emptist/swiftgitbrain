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
    case connectionError(String)
    
    var errorDescription: String? {
        switch self {
        case .unknownCommand(let command):
            let suggestion = suggestCommand(for: command)
            return "Unknown command: \(command)\n\(suggestion)"
        case .invalidArguments(let message):
            return "Invalid arguments: \(message)\n💡 Use 'gitbrain help' to see correct usage"
        case .invalidRecipient(let recipient):
            return "Unknown recipient: \(recipient)\n💡 Recipients should be AI names like 'Creator', 'Monitor', etc."
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)\n💡 Make sure JSON is properly formatted with escaped quotes"
        case .fileNotFound(let path):
            return "File not found: \(path)\n💡 Check the path and ensure the file exists"
        case .initializationError(let message):
            return "Initialization error: \(message)\n💡 Try running 'gitbrain init' first"
        case .databaseError(let message):
            return "Database error: \(message)\n💡 Ensure PostgreSQL is running and database is configured"
        case .connectionError(let message):
            return "Connection error: \(message)\n💡 Check your network and database connection"
        }
    }
    
    private func suggestCommand(for command: String) -> String {
        let commands = [
            "init", "send-task", "check-tasks", "update-task",
            "send-review", "check-reviews", "update-review",
            "send-code", "check-codes", "send-score", "check-scores",
            "send-feedback", "check-feedbacks", "send-heartbeat", "check-heartbeats",
            "brainstate-create", "brainstate-load", "brainstate-save",
            "brainstate-update", "brainstate-get", "brainstate-list", "brainstate-delete",
            "knowledge-add", "knowledge-get", "knowledge-update", "knowledge-delete",
            "knowledge-list", "knowledge-search",
            "daemon-start", "daemon-stop", "daemon-status",
            "interactive", "sleep", "help",
            "st", "ct", "sr", "cr", "sh", "sf", "sc", "ss"
        ]
        
        let lowerCommand = command.lowercased()
        let suggestions = commands.filter { $0.hasPrefix(lowerCommand) || $0.contains(lowerCommand) }
        
        if suggestions.isEmpty {
            return "💡 Use 'gitbrain help' to see available commands"
        } else if suggestions.count == 1 {
            return "💡 Did you mean '\(suggestions[0])'?"
        } else {
            return "💡 Did you mean one of: \(suggestions.prefix(5).joined(separator: ", "))?"
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
            case "daemon-start":
                try await handleDaemonStart(args: args)
            case "daemon-stop":
                try await handleDaemonStop(args: args)
            case "daemon-status":
                try await handleDaemonStatus(args: args)
            case "sleep", "relax", "coffeetime", "nap", "break":
                try await handleSleep(args: args)
            case "interactive":
                try await handleInteractive(args: args)
            case "st":
                try await handleSendTask(args: args)
            case "ct":
                try await handleCheckTasks(args: args)
            case "sr":
                try await handleSendReview(args: args)
            case "cr":
                try await handleCheckReviews(args: args)
            case "sh":
                try await handleSendHeartbeat(args: args)
            case "sf":
                try await handleSendFeedback(args: args)
            case "sc":
                try await handleSendCode(args: args)
            case "ss":
                try await handleSendScore(args: args)
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
        return "./.GitBrain"
    }
    
    private static func handleInit(args: [String]) async throws {
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        
        var projectName: String
        var gitBrainPath: String
        
        if let providedName = args.first {
            let providedPath = providedName.hasPrefix("/") ? providedName : "\(currentPath)/\(providedName)"
            projectName = URL(fileURLWithPath: providedPath).lastPathComponent
            gitBrainPath = "\(providedPath)/.GitBrain"
        } else {
            projectName = URL(fileURLWithPath: currentPath).lastPathComponent
            gitBrainPath = "\(currentPath)/.GitBrain"
        }
        
        let dbName = ProcessInfo.processInfo.environment["GITBRAIN_DB_NAME"] ?? "gitbrain_\(projectName.lowercased())"
        
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        
        print("Initializing GitBrain...")
        print("Project: \(projectName)")
        print("Path: \(gitBrainPath)")
        if ProcessInfo.processInfo.environment["GITBRAIN_PATH"] != nil {
            print("Using environment variable: GITBRAIN_PATH")
        }
        
        try fileManager.createDirectory(at: gitBrainURL, withIntermediateDirectories: true)
        
        let readmeContent = """
        # GitBrain - AI Collaboration Guide
        
        > **READ THIS FIRST** - This guide is for AI assistants working in this project.
        
        ## Project: \(projectName)
        
        This folder enables AI-assisted collaborative development.
        
        ## Quick Start
        
        ### For Creator
        ```bash
        # 1. Load previous state
        gitbrain brainstate-load Creator
        
        # 2. Check for tasks
        gitbrain check-tasks Creator pending
        
        # 3. Keep yourself alive with SPECIFIC tasks
        TodoWrite([
            {"id": "1", "content": "Implement feature X", "status": "in_progress", "priority": "high"},
            {"id": "2", "content": "Write tests for Y", "status": "in_progress", "priority": "high"},
            {"id": "3", "content": "Fix bug in Z", "status": "in_progress", "priority": "high"}
        ])
        ```
        
        ### For Monitor
        ```bash
        # 1. Load previous state
        gitbrain brainstate-load Monitor
        
        # 2. Set up productive monitoring tasks (NOT just "Monitor project")
        TodoWrite([
            {"id": "1", "content": "Review code quality in Sources/", "status": "in_progress", "priority": "high"},
            {"id": "2", "content": "Check for security vulnerabilities", "status": "in_progress", "priority": "high"},
            {"id": "3", "content": "Identify areas needing documentation", "status": "in_progress", "priority": "high"}
        ])
        
        # 3. Send SPECIFIC, ACTIONABLE tasks to Creator
        gitbrain send-task Creator fix-001 "Fix SQL injection in Auth.swift:142" coding 1
        ```
        
        ## Communication
        
        Messages are stored in PostgreSQL database: `\(dbName)`
        Use `gitbrain` CLI commands to send and receive messages.
        
        ## Database
        
        Project database: `\(dbName)`
        All AI communication and state is stored here.
        
        ## Cleanup
        
        After development is complete, you can safely remove this folder:
        ```
        rm -rf .GitBrain
        ```
        """
        
        let readmeURL = gitBrainURL.appendingPathComponent("README.md")
        try readmeContent.write(to: readmeURL, atomically: true, encoding: .utf8)
        
        print("✓ Created .GitBrain/")
        print("✓ Created .GitBrain/README.md")
        
        print("\nChecking PostgreSQL availability...")
        let postgresAvailable = checkPostgreSQLAvailable()
        
        guard postgresAvailable else {
            print("✗ PostgreSQL is NOT available")
            print("\n❌ GitBrain requires PostgreSQL to be installed and running.")
            print("\nInstallation instructions:")
            print("  macOS:")
            print("    brew install postgresql@17")
            print("    brew services start postgresql@17")
            print("\n  Ubuntu/Debian:")
            print("    sudo apt update")
            print("    sudo apt install postgresql postgresql-contrib")
            print("    sudo systemctl start postgresql")
            print("\n  Fedora/RHEL:")
            print("    sudo dnf install postgresql postgresql-server")
            print("    sudo postgresql-setup --initdb")
            print("    sudo systemctl start postgresql")
            print("\nAfter installing PostgreSQL, run: gitbrain init")
            throw CLIError.connectionError("PostgreSQL is required but not available")
        }
        
        print("✓ PostgreSQL is available")
        
        let dbCreated = await createDatabaseIfNeeded(name: dbName)
        
        guard dbCreated else {
            print("✗ Could not create database '\(dbName)'")
            print("  Try creating it manually: createdb \(dbName)")
            print("  Or check PostgreSQL permissions")
            throw CLIError.databaseError("Failed to create database '\(dbName)'")
        }
        
        print("✓ Database '\(dbName)' is ready")
        
        print("\nInitialization complete!")
        print("\nNext steps:")
        print("1. Run migrations: swift run gitbrain-migrate migrate")
        print("2. Open Trae at project root for Creator: trae .")
        print("3. Open Trae at GitBrain for Monitor: trae ./.GitBrain")
    }
    
    private static func checkPostgreSQLAvailable() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["psql"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    private static func createDatabaseIfNeeded(name: String) async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["psql", "-lqt", "-c", "SELECT 1 FROM pg_database WHERE datname = '\(name)'"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let createProcess = Process()
                createProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                createProcess.arguments = ["createdb", name]
                
                try createProcess.run()
                createProcess.waitUntilExit()
                
                return createProcess.terminationStatus == 0
            }
            
            return true
        } catch {
            return false
        }
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
        let aiName = args.first ?? "Creator"
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
        let aiName = args.first ?? "Creator"
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
        let aiName = args.first ?? "Monitor"
        
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
        let aiName = args.first ?? "Creator"
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
        let aiName = args.first ?? "Monitor"
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
    

    nonisolated(unsafe) private static var runningDaemon: AIDaemon?
    
    private static func handleDaemonStart(args: [String]) async throws {
        guard args.count >= 2 else {
            throw CLIError.invalidArguments("daemon-start requires: <ai_name> <role> [poll_interval] [heartbeat_interval]")
        }
        
        let aiName = args[0]
        guard let role = RoleType(rawValue: args[1]) else {
            throw CLIError.invalidArguments("Invalid role: \(args[1]). Valid roles: \(RoleType.allCases.map { $0.rawValue }.joined(separator: ", "))")
        }
        
        let pollInterval = args.count > 2 ? Double(args[2]) ?? 1.0 : 1.0
        let heartbeatInterval = args.count > 3 ? Double(args[3]) ?? 30.0 : 30.0
        
        let config = DaemonConfig(
            aiName: aiName,
            role: role,
            pollInterval: pollInterval,
            heartbeatInterval: heartbeatInterval,
            autoHeartbeat: true,
            processMessages: true
        )
        
        let dbManager = DatabaseManager()
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        await daemon.setCallbacks(
            onTaskReceived: { task in
                print("\n📥 Task received: \(task.taskId)")
                print("   Description: \(task.description)")
                print("   Type: \(task.taskType)")
                print("   Priority: \(task.priority)")
            },
            onReviewReceived: { review in
                print("\n📝 Review received: \(review.taskId)")
                print("   Approved: \(review.approved)")
                if let feedback = review.feedback {
                    print("   Feedback: \(feedback)")
                }
            },
            onCodeReceived: { code in
                print("\n�� Code received: \(code.codeId)")
                print("   Title: \(code.title)")
                print("   Files: \(code.files.joined(separator: ", "))")
            },
            onScoreReceived: { score in
                print("\n⭐ Score request received: \(score.taskId)")
                print("   Requested Score: \(score.requestedScore)")
                print("   Justification: \(score.qualityJustification)")
            },
            onFeedbackReceived: { feedback in
                print("\n💬 Feedback received: \(feedback.subject)")
                print("   Type: \(feedback.feedbackType)")
                print("   Content: \(feedback.content)")
            },
            onHeartbeatReceived: { heartbeat in
                print("\n💓 Heartbeat received from: \(heartbeat.fromAI)")
                print("   Role: \(heartbeat.aiRole)")
                print("   Status: \(heartbeat.status)")
            },
            onError: { error in
                print("\n❌ Daemon error: \(error.localizedDescription)")
            }
        )
        
        try await daemon.start()
        runningDaemon = daemon
        
        print("✓ Daemon started for \(aiName)")
        print("  Role: \(role.rawValue)")
        print("  Poll Interval: \(pollInterval)s")
        print("  Heartbeat Interval: \(heartbeatInterval)s")
        print("\nPress Ctrl+C to stop...")
        
        let task = Task {
            while true {
                try? await Task.sleep(for: .seconds(1))
            }
        }
        
        signal(SIGINT, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        source.setEventHandler {
            task.cancel()
            Task {
                print("\n\nStopping daemon...")
                try? await daemon.stop()
                Foundation.exit(0)
            }
        }
        source.resume()
        
        _ = await task.value
    }
    
    private static func handleDaemonStop(args: [String]) async throws {
        guard let daemon = runningDaemon else {
            print("No daemon is running")
            return
        }
        
        try await daemon.stop()
        runningDaemon = nil
        print("✓ Daemon stopped")
    }
    
    private static func handleDaemonStatus(args: [String]) async throws {
        guard let daemon = runningDaemon else {
            print("No daemon is running")
            return
        }
        
        let status = await daemon.getStatus()
        print("Daemon Status:")
        print("  AI Name: \(status.aiName)")
        print("  Role: \(status.role.rawValue)")
        print("  Running: \(status.isRunning)")
        print("  Poll Interval: \(status.pollInterval)s")
        print("  Heartbeat Interval: \(status.heartbeatInterval)s")
    }
    

    private static func handleSleep(args: [String]) async throws {
        guard args.count >= 1 else {
            throw CLIError.invalidArguments("sleep requires: <seconds>")
        }
        
        guard let seconds = Double(args[0]) else {
            throw CLIError.invalidArguments("Invalid number of seconds: \(args[0])")
        }
        
        print("Sleeping for \(seconds) seconds...")
        try await Task.sleep(for: .seconds(seconds))
        print("✓ Woke up after \(seconds) seconds")
    }
    
    private static func handleInteractive(args: [String]) async throws {
        print("GitBrain Interactive Mode")
        print("Type 'help' for commands, 'exit' to quit")
        print()
        
        while true {
            print("gitbrain> ", terminator: "")
            guard let line = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                break
            }
            
            if line.isEmpty {
                continue
            }
            
            if line == "exit" || line == "quit" {
                print("Goodbye!")
                break
            }
            
            if line == "help" {
                printUsage()
                continue
            }
            
            let parts = line.split(separator: " ").map { String($0) }
            let command = parts.first ?? ""
            let commandArgs = Array(parts.dropFirst())
            
            do {
                try await executeCommand(command: command, args: commandArgs)
            } catch {
                print("Error: \(error.localizedDescription)")
                print("Type 'help' for available commands")
            }
        }
    }
    
    private static func executeCommand(command: String, args: [String]) async throws {
        switch command {
        case "init":
            try await handleInit(args: args)
        case "send-task", "st":
            try await handleSendTask(args: args)
        case "check-tasks", "ct":
            try await handleCheckTasks(args: args)
        case "update-task":
            try await handleUpdateTask(args: args)
        case "send-review", "sr":
            try await handleSendReview(args: args)
        case "check-reviews", "cr":
            try await handleCheckReviews(args: args)
        case "update-review":
            try await handleUpdateReview(args: args)
        case "send-code", "sc":
            try await handleSendCode(args: args)
        case "check-codes":
            try await handleCheckCodes(args: args)
        case "send-score", "ss":
            try await handleSendScore(args: args)
        case "check-scores":
            try await handleCheckScores(args: args)
        case "send-feedback", "sf":
            try await handleSendFeedback(args: args)
        case "check-feedbacks":
            try await handleCheckFeedbacks(args: args)
        case "send-heartbeat", "sh":
            try await handleSendHeartbeat(args: args)
        case "check-heartbeats":
            try await handleCheckHeartbeats(args: args)
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
        case "daemon-start":
            try await handleDaemonStart(args: args)
        case "daemon-stop":
            try await handleDaemonStop(args: args)
        case "daemon-status":
            try await handleDaemonStatus(args: args)
        case "sleep", "relax", "coffeetime", "nap", "break":
            try await handleSleep(args: args)
        default:
            throw CLIError.unknownCommand(command)
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
          
          Daemon Commands:
          daemon-start <ai_name> <role> [poll_interval] [heartbeat_interval]
                               Start daemon for AI communication
          daemon-stop          Stop running daemon
          daemon-status        Show daemon status
          
          Utility Commands:
          interactive          Start interactive mode (REPL)
          sleep <seconds>      Sleep for specified duration (aliases: relax, coffeetime, nap, break)
          
          Shortcuts:
          st                   send-task
          ct                   check-tasks
          sr                   send-review
          cr                   check-reviews
          sh                   send-heartbeat
          sf                   send-feedback
          sc                   send-code
          ss                   send-score
          
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
          gitbrain send-task Monitor task-001 "Review code" review 1
          gitbrain check-tasks Creator pending
          gitbrain update-task <uuid> in_progress
          gitbrain send-heartbeat Monitor Creator working "Implementing feature"
          gitbrain send-feedback Creator performance "Great work" "Keep it up!"
        """)
    }
}
