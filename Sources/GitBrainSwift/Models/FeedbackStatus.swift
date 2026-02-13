import Foundation

public enum FeedbackStatus: String, Codable, Sendable, CaseIterable {
    case pending = "pending"
    case read = "read"
    case acknowledged = "acknowledged"
    case actioned = "actioned"
    case archived = "archived"
    
    public enum TransitionError: Error, Sendable {
        case invalidTransition(from: FeedbackStatus, to: FeedbackStatus)
    }
    
    public func canTransition(to newStatus: FeedbackStatus) -> Bool {
        switch (self, newStatus) {
        case (.pending, .read),
             (.pending, .acknowledged),
             (.read, .acknowledged),
             (.read, .actioned),
             (.acknowledged, .actioned),
             (.actioned, .archived),
             (.acknowledged, .archived):
            return true
        default:
            return false
        }
    }
    
    public func transition(to newStatus: FeedbackStatus) throws(FeedbackStatus.TransitionError) -> FeedbackStatus {
        guard canTransition(to: newStatus) else {
            throw TransitionError.invalidTransition(from: self, to: newStatus)
        }
        return newStatus
    }
    
    public var isArchivable: Bool {
        switch self {
        case .actioned, .acknowledged:
            return true
        case .pending, .read, .archived:
            return false
        }
    }
    
    public var isTerminal: Bool {
        return self == .archived
    }
    
    public var isActive: Bool {
        switch self {
        case .pending, .read, .acknowledged:
            return true
        case .actioned, .archived:
            return false
        }
    }
}
