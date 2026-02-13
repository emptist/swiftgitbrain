import Foundation
import GitBrainSwift

enum CLIError: LocalizedError {
    case unknownCommand(String)
    case invalidArguments(String)
    case invalidRecipient(String)
    case invalidJSON(String)
    case fileNotFound(String)
    case initializationError(String)
    
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
        }
    }
}

@main
struct GitBrainCLI {
    private static let gitBrainPathEnv = "GITBRAIN_PATH"
    
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
            case "send":
                try await handleSend(args: args)
            case "check":
                try await handleCheck(args: args)
            case "clear":
                try await handleClear(args: args)
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
        if let envPath = ProcessInfo.processInfo.environment[gitBrainPathEnv] {
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
        if ProcessInfo.processInfo.environment[gitBrainPathEnv] != nil {
            print("Using environment variable: \(gitBrainPathEnv)")
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
        
        CoderAI writes to GitBrain/Overseer/
        OverseerAI writes to GitBrain/Memory/ (for CoderAI to read)
        
        Messages are stored as JSON files with timestamps.
        
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
        print("1. Open Trae at project root for CoderAI: trae .")
        print("2. Open Trae at GitBrain for OverseerAI: trae ./GitBrain")
        print("3. Ask each AI to read GitBrain/Docs/ to understand their role")
    }
    
    private static func handleSend(args: [String]) async throws {
        guard args.count >= 2 else {
            print("Usage: gitbrain send <to> <message>")
            print("  to: 'coder' or 'overseer'")
            print("  message: JSON string or file path")
            throw CLIError.invalidArguments("send command requires <to> and <message> arguments")
        }
        
        let to = args[0]
        let messageContent = args[1]
        
        let gitBrainPath = args.count > 2 ? args[2] : getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        
        let communication = FileBasedCommunication(overseerFolder: overseerURL)
        
        var content: SendableContent
        
        if messageContent.hasPrefix("{") || messageContent.hasPrefix("[") {
            guard let data = messageContent.data(using: .utf8) else {
                throw CLIError.invalidJSON("Failed to convert message to UTF-8")
            }
            guard let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw CLIError.invalidJSON("Invalid JSON format")
            }
            content = SendableContent(jsonData)
        } else {
            let messageURL = URL(fileURLWithPath: messageContent)
            guard FileManager.default.fileExists(atPath: messageURL.path) else {
                throw CLIError.fileNotFound(messageContent)
            }
            let data = try Data(contentsOf: messageURL)
            guard let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw CLIError.invalidJSON("Invalid JSON format in file")
            }
            content = SendableContent(jsonData)
        }
        
        let path: URL
        if to == "coder" {
            path = try await communication.sendMessageToCoder(content, coderFolder: memoryURL)
        } else if to == "overseer" {
            path = try await communication.sendMessageToOverseer(content)
        } else {
            print("Unknown recipient: \(to)")
            print("Valid recipients: coder, overseer")
            throw CLIError.invalidRecipient(to)
        }
        
        print("✓ Message sent to: \(to)")
        print("  Path: \(path.path)")
    }
    
    private static func handleCheck(args: [String]) async throws {
        let role = args.first ?? "coder"
        let gitBrainPath = args.count > 1 ? args[1] : getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        
        let communication = FileBasedCommunication(overseerFolder: overseerURL)
        
        let messages: [SendableContent]
        
        if role == "coder" {
            messages = try await communication.getMessagesForCoder(coderFolder: memoryURL)
        } else if role == "overseer" {
            messages = try await communication.getMessagesForOverseer()
        } else {
            print("Unknown role: \(role)")
            print("Valid roles: coder, overseer")
            throw CLIError.invalidArguments("Invalid role: \(role). Valid roles: coder, overseer")
        }
        
        print("Messages for '\(role)': \(messages.count)")
        
        if !messages.isEmpty {
            print("\nMessages:")
            for message in messages {
                let data = message.toAnyDict()
                if let from = data["from"] as? String,
                   let to = data["to"] as? String,
                   let timestamp = data["timestamp"] as? String,
                   let content = data["content"] as? [String: Any] {
                    print("  [\(from) -> \(to)] \(timestamp)")
                    print("    Content: \(content)")
                }
            }
        }
    }
    
    private static func handleClear(args: [String]) async throws {
        let role = args.first ?? "coder"
        let gitBrainPath = args.count > 1 ? args[1] : getGitBrainPath()
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        
        let communication = FileBasedCommunication(overseerFolder: overseerURL)
        
        if role == "coder" {
            try await communication.clearCoderMessages(coderFolder: memoryURL)
            print("✓ Cleared messages for coder")
        } else if role == "overseer" {
            try await communication.clearOverseerMessages()
            print("✓ Cleared messages for overseer")
        } else {
            print("Unknown role: \(role)")
            print("Valid roles: coder, overseer")
            throw CLIError.invalidArguments("Invalid role: \(role). Valid roles: coder, overseer")
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
          send <to> <message>  Send a message to another AI
          check [role]         Check messages for a role
          clear [role]         Clear messages for a role
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
        
        Arguments:
          path                 Path to GitBrain folder (default: ./GitBrain or $GITBRAIN_PATH)
          to                   Recipient: 'coder' or 'overseer'
          message              JSON string or file path
          role                 Role to check/clear: 'coder' or 'overseer'
          task_id              Task identifier
          requested_score       Score being requested
          quality_justification
                               Justification for score request
          requester            AI requesting score (default: 'coder')
          target_ai            AI to award score (default: 'overseer')
          request_id           Score request ID
          awarded_score        Score being awarded
          reason               Reason for score award or rejection
          awarder              AI awarding score (default: 'overseer')
          rejecter             AI rejecting score request (default: 'overseer')
          ai_name              AI name: 'coder' or 'overseer'
        
        Environment Variables:
          GITBRAIN_PATH        Default path to GitBrain folder (overrides ./GitBrain)
        
        Examples:
          gitbrain init
          gitbrain send overseer '{"type":"code_review","files":["file.swift"]}'
          gitbrain check coder
          gitbrain clear overseer
          gitbrain score-request task-001 25 "Task completed successfully with all tests passing"
          gitbrain score-award 1 25 "Excellent work! All requirements met"
          gitbrain score-history coder
          gitbrain score-requests overseer
          
          # Using environment variable
          export GITBRAIN_PATH=/custom/path/to/GitBrain
          gitbrain check coder
        
        For more information, see GitBrain/README.md
        """)
    }
}
