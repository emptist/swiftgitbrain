import Foundation

public enum MessageType: String, Codable, Sendable {
    case task = "task"
    case code = "code"
    case review = "review"
    case feedback = "feedback"
    case approval = "approval"
    case rejection = "rejection"
    case status = "status"
    case heartbeat = "heartbeat"
}
