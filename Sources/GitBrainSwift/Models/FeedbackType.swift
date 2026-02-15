import Foundation

public enum FeedbackType: String, Codable, Sendable, CaseIterable {
    case bug = "bug"
    case suggestion = "suggestion"
    case question = "question"
    case praise = "praise"
    case complaint = "complaint"
    case general = "general"
}
