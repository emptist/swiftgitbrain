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
            case "setup":
                try await handleSetup(args: args)
            case "check":
                try await handleCheck(args: args)
            case "send":
                try await handleSend(args: args)
            case "daemon":
                try await handleDaemon(args: args)
            case "status":
                try await handleStatus(args: args)
            case "sync":
                try await handleSync(args: args)
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
    
    private static func handleSetup(args: [String]) async throws {
        guard args.count >= 2 else {
            print("Usage: gitbrain setup <repo> <shared-path>")
            exit(1)
        }
        
        let repo = args[0]
        let sharedPath = args[1]
        
        print("Setting up shared worktree...")
        let worktree = try await WorktreeManager.setupSharedWorktree(
            repository: repo,
            sharedPath: sharedPath
        )
        
        print("✓ Shared worktree created at: \(worktree.path)")
        print("✓ Branch: \(worktree.branch)")
        
        let communication = SharedWorktreeCommunication(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        
        print("Setting up role directories...")
        _ = try await communication.setupRoleDirectory(for: "coder")
        _ = try await communication.setupRoleDirectory(for: "overseer")
        
        print("✓ Role directories created")
        print("\nSetup complete!")
    }
    
    private static func handleCheck(args: [String]) async throws {
        let role = args.first ?? "coder"
        let sharedPath = args.count > 1 ? args[1] : "./shared"
        
        let communication = SharedWorktreeCommunication(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        
        let count = try await communication.getMessageCount(for: role)
        print("Messages for '\(role)': \(count)")
        
        if count > 0 {
            let messages = try await communication.receiveMessages(for: role)
            print("\nMessages:")
            for message in messages {
                print("  [\(message.messageType.rawValue)] \(message.timestamp): \(message.content)")
            }
        }
    }
    
    private static func handleSend(args: [String]) async throws {
        guard args.count >= 4 else {
            print("Usage: gitbrain send <from> <to> <type> <message>")
            exit(1)
        }
        
        let from = args[0]
        let to = args[1]
        let type = args[2]
        let messageContent = args[3]
        
        let sharedPath = args.count > 4 ? args[4] : "./shared"
        
        let communication = SharedWorktreeCommunication(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        
        guard let messageType = MessageType(rawValue: type) else {
            print("Unknown message type: \(type)")
            print("Valid types: status, task, code, review, feedback, approval, rejection, heartbeat")
            exit(1)
        }
        
        let message = Message(
            id: UUID().uuidString,
            fromAI: from,
            toAI: to,
            messageType: messageType,
            content: ["message": messageContent],
            timestamp: Date().iso8601String,
            priority: 1
        )
        
        let path = try await communication.sendMessage(message, from: from, to: to)
        print("✓ Message sent to: \(to)")
        print("  Path: \(path.path)")
    }
    
    private static func handleDaemon(args: [String]) async throws {
        let sharedPath = args.first ?? "./shared"
        let roles = args.count > 1 ? Array(args.dropFirst()) : ["coder", "overseer"]
        
        print("Starting GitBrain daemon...")
        print("Shared worktree: \(sharedPath)")
        print("Monitoring roles: \(roles.joined(separator: ", "))")
        
        let communication = SharedWorktreeCommunication(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        let monitor = try await SharedWorktreeMonitor(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        
        for role in roles {
            await monitor.registerHandler(for: role) { message in
                print("[\(message.fromAI) -> \(message.toAI)] [\(message.messageType.rawValue)] \(message.timestamp)")
                print("  Content: \(message.content)")
            }
        }
        
        try await monitor.start()
        
        print("✓ Daemon started")
        print("Press Ctrl+C to stop")
        
        let task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            await monitor.stop()
        }
        
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            print("\nStopping daemon...")
            task.cancel()
        }
    }
    
    private static func handleStatus(args: [String]) async throws {
        let sharedPath = args.first ?? "./shared"
        
        let communication = SharedWorktreeCommunication(
            sharedWorktree: URL(fileURLWithPath: sharedPath)
        )
        
        print("GitBrain Status")
        print("===============")
        print("Shared worktree: \(sharedPath)")
        
        let coderCount = try await communication.getMessageCount(for: "coder")
        let overseerCount = try await communication.getMessageCount(for: "overseer")
        
        print("\nCoder: \(coderCount) messages")
        print("Overseer: \(overseerCount) messages")
        print("Total: \(coderCount + overseerCount) messages")
    }
    
    private static func handleSync(args: [String]) async throws {
        let repo = args.first ?? "."
        
        let worktreeManager = WorktreeManager(repository: URL(fileURLWithPath: repo))
        
        print("Syncing worktree...")
        let worktrees = try await worktreeManager.listWorktrees()
        
        for worktree in worktrees {
            print("Syncing: \(worktree.path)")
            try? await worktreeManager.syncWorktree(worktree.path)
            print("  ✓ Pulled and pushed")
        }
        
        print("\nSync complete!")
    }
    
    private static func printUsage() {
        print("""
        GitBrain CLI - AI Collaboration Tool
        
        Usage:
          gitbrain <command> [arguments]
        
        Commands:
          setup <repo> <shared-path>     Setup shared worktree and role directories
          check [role] [shared-path]       Check messages for a role
          send <from> <to> <type> <msg>   Send a message
          daemon [shared-path] [roles...]     Start monitoring daemon
          status [shared-path]                Show system status
          sync [repo]                        Sync all worktrees
          help                               Show this help message
        
        Message Types:
          status, task, code, review, feedback, approval, rejection, heartbeat
        
        Examples:
          gitbrain setup . ./shared
          gitbrain check coder
          gitbrain send coder overseer status "Working on feature X"
          gitbrain daemon ./shared coder overseer
          gitbrain status
          gitbrain sync .
        
        For more information, visit: https://github.com/emptist/swiftgitbrain
        """)
    }
}