import Foundation

public enum ReviewStatus: String, Codable, Sendable, CaseIterable {
    case pending = "pending"
    case inReview = "in_review"
    case approved = "approved"
    case rejected = "rejected"
    case needsChanges = "needs_changes"
    case applied = "applied"
    case archived = "archived"
    
    public enum TransitionError: Error, Sendable {
        case invalidTransition(from: ReviewStatus, to: ReviewStatus)
    }
    
    public func canTransition(to newStatus: ReviewStatus) -> Bool {
        switch (self, newStatus) {
        case (.pending, .inReview),
             (.pending, .approved),
             (.pending, .rejected),
             (.inReview, .approved),
             (.inReview, .rejected),
             (.inReview, .needsChanges),
             (.needsChanges, .inReview),
             (.needsChanges, .approved),
             (.needsChanges, .rejected),
             (.approved, .applied),
             (.approved, .archived),
             (.rejected, .archived),
             (.applied, .archived):
            return true
        default:
            return false
        }
    }
    
    public func transition(to newStatus: ReviewStatus) throws(ReviewStatus.TransitionError) -> ReviewStatus {
        guard canTransition(to: newStatus) else {
            throw TransitionError.invalidTransition(from: self, to: newStatus)
        }
        return newStatus
    }
    
    public var isArchivable: Bool {
        switch self {
        case .approved, .rejected, .applied, .archived:
            return true
        case .pending, .inReview, .needsChanges:
            return false
        }
    }
    
    public var isTerminal: Bool {
        switch self {
        case .applied, .rejected, .archived:
            return true
        case .pending, .inReview, .approved, .needsChanges:
            return false
        }
    }
    
    public var requiresAction: Bool {
        switch self {
        case .pending, .needsChanges:
            return true
        case .inReview, .approved, .rejected, .applied, .archived:
            return false
        }
    }
}
