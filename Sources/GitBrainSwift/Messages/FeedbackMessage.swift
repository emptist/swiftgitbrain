import Foundation

public enum FeedbackType: String, Codable, Sendable, CaseIterable {
    case bug = "bug"
    case suggestion = "suggestion"
    case question = "question"
    case praise = "praise"
    case complaint = "complaint"
    case general = "general"
}

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

public struct FeedbackMessage: FeedbackMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let feedbackType: FeedbackType
    public let subject: String
    public let content: String
    public let relatedTaskId: String?
    public let response: String?
    public let status: FeedbackStatus
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        feedbackType: FeedbackType,
        subject: String,
        content: String,
        relatedTaskId: String? = nil,
        response: String? = nil,
        status: FeedbackStatus = .pending
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.feedbackType = feedbackType
        self.subject = subject
        self.content = content
        self.relatedTaskId = relatedTaskId
        self.response = response
        self.status = status
    }
}
