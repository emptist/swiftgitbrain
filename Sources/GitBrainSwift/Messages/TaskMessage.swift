import Foundation

public enum TaskType: String, Codable, Sendable, CaseIterable {
    case coding = "coding"
    case review = "review"
    case testing = "testing"
    case documentation = "documentation"
}

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

public struct TaskMessage: TaskMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let taskId: String
    public let title: String
    public let description: String
    public let taskType: TaskType
    public let status: TaskStatus
    public let files: [GitFileReference]?
    public let deadline: Date?
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        taskId: String,
        title: String,
        description: String,
        taskType: TaskType,
        status: TaskStatus = .pending,
        files: [GitFileReference]? = nil,
        deadline: Date? = nil
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.taskId = taskId
        self.title = title
        self.description = description
        self.taskType = taskType
        self.status = status
        self.files = files
        self.deadline = deadline
    }
}
