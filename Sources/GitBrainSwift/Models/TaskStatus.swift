import Foundation

public enum TaskStatus: String, Codable, Sendable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    case archived = "archived"
    
    public enum TransitionError: Error, Sendable {
        case invalidTransition(from: TaskStatus, to: TaskStatus)
    }
    
    public func canTransition(to newStatus: TaskStatus) -> Bool {
        switch (self, newStatus) {
        case (.pending, .inProgress),
             (.pending, .cancelled),
             (.inProgress, .completed),
             (.inProgress, .failed),
             (.inProgress, .cancelled),
             (.completed, .archived),
             (.failed, .archived),
             (.cancelled, .archived):
            return true
        default:
            return false
        }
    }
    
    public func transition(to newStatus: TaskStatus) throws(TaskStatus.TransitionError) -> TaskStatus {
        guard canTransition(to: newStatus) else {
            throw TransitionError.invalidTransition(from: self, to: newStatus)
        }
        return newStatus
    }
    
    public var isArchivable: Bool {
        switch self {
        case .completed, .failed, .cancelled, .archived:
            return true
        case .pending, .inProgress:
            return false
        }
    }
    
    public var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled:
            return true
        case .pending, .inProgress, .archived:
            return false
        }
    }
    
    public var isActive: Bool {
        switch self {
        case .pending, .inProgress:
            return true
        case .completed, .failed, .cancelled, .archived:
            return false
        }
    }
}
