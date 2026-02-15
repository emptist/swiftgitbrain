import Foundation

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
