import Foundation

public enum MessageType: String, Codable, Sendable, CaseIterable {
    case task = "task"
    case review = "review"
    case code = "code"
    case score = "score"
    case feedback = "feedback"
    case heartbeat = "heartbeat"
}
