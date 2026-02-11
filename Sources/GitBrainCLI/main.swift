import Foundation
import GitBrainSwift

@main
struct GitBrainCLI {
    static func main() async {
        let arguments = CommandLine.arguments
        
        guard arguments.count > 1 else {
            printUsage()
            exit(1)
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
            case "help", "--help", "-h":
                printUsage()
            default:
                print("Unknown command: \(command)")
                printUsage()
                exit(1)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    private static func handleInit(args: [String]) async throws {
        let gitBrainPath = args.first ?? "./GitBrain"
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        let docsURL = gitBrainURL.appendingPathComponent("Docs")
        
        print("Initializing GitBrain...")
        print("Path: \(gitBrainPath)")
        
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
        print("2. Open Trae at GitBrain/Overseer for OverseerAI: trae ./GitBrain/Overseer")
        print("3. Ask each AI to read GitBrain/Docs/ to understand their role")
    }
    
    private static func handleSend(args: [String]) async throws {
        guard args.count >= 2 else {
            print("Usage: gitbrain send <to> <message>")
            print("  to: 'coder' or 'overseer'")
            print("  message: JSON string or file path")
            exit(1)
        }
        
        let to = args[0]
        let messageContent = args[1]
        
        let gitBrainPath = args.count > 2 ? args[2] : "./GitBrain"
        let gitBrainURL = URL(fileURLWithPath: gitBrainPath)
        let overseerURL = gitBrainURL.appendingPathComponent("Overseer")
        let memoryURL = gitBrainURL.appendingPathComponent("Memory")
        
        let communication = FileBasedCommunication(overseerFolder: overseerURL)
        
        var content: SendableContent
        
        if messageContent.hasPrefix("{") || messageContent.hasPrefix("[") {
            content = SendableContent(try JSONSerialization.jsonObject(with: messageContent.data(using: .utf8)!) as! [String: Any])
        } else {
            let messageURL = URL(fileURLWithPath: messageContent)
            let data = try Data(contentsOf: messageURL)
            content = SendableContent(try JSONSerialization.jsonObject(with: data) as! [String: Any])
        }
        
        let path: URL
        if to == "coder" {
            path = try await communication.sendMessageToCoder(content, coderFolder: memoryURL)
        } else if to == "overseer" {
            path = try await communication.sendMessageToOverseer(content)
        } else {
            print("Unknown recipient: \(to)")
            print("Valid recipients: coder, overseer")
            exit(1)
        }
        
        print("✓ Message sent to: \(to)")
        print("  Path: \(path.path)")
    }
    
    private static func handleCheck(args: [String]) async throws {
        let role = args.first ?? "coder"
        let gitBrainPath = args.count > 1 ? args[1] : "./GitBrain"
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
            exit(1)
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
        let gitBrainPath = args.count > 1 ? args[1] : "./GitBrain"
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
            exit(1)
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
          help                 Show this help message
        
        Arguments:
          path                 Path to GitBrain folder (default: ./GitBrain)
          to                   Recipient: 'coder' or 'overseer'
          message              JSON string or file path
          role                 Role to check/clear: 'coder' or 'overseer'
        
        Examples:
          gitbrain init
          gitbrain send overseer '{"type":"code_review","files":["file.swift"]}'
          gitbrain check coder
          gitbrain clear overseer
        
        For more information, see GitBrain/README.md
        """)
    }
}
