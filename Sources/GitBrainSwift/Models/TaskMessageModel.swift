import Fluent
import Foundation

public final class TaskMessageModel: Model, @unchecked Sendable {
    public static let schema = "task_messages"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "message_id")
    public var messageId: UUID
    
    @Field(key: "from_ai")
    public var fromAI: String
    
    @Field(key: "to_ai")
    public var toAI: String
    
    @Field(key: "timestamp")
    public var timestamp: Date
    
    @Field(key: "task_id")
    public var taskId: String
    
    @Field(key: "description")
    public var description: String
    
    @Field(key: "task_type")
    public var taskType: String
    
    @Field(key: "priority")
    public var priority: Int
    
    @OptionalField(key: "files")
    public var files: [String]?
    
    @OptionalField(key: "deadline")
    public var deadline: Date?
    
    @Field(key: "status")
    public var status: String
    
    @Field(key: "message_priority")
    public var messagePriority: Int
    
    @Field(key: "created_at")
    public var createdAt: Date
    
    @Field(key: "updated_at")
    public var updatedAt: Date
    
    public init() {}
    
    public init(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        timestamp: Date,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]? = nil,
        deadline: Date? = nil,
        status: TaskStatus = .pending,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.taskId = taskId
        self.description = description
        self.taskType = taskType.rawValue
        self.priority = priority
        self.files = files
        self.deadline = deadline
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = timestamp
        self.updatedAt = timestamp
    }
    
    public var taskTypeEnum: TaskType? {
        return TaskType(rawValue: taskType)
    }
    
    public var statusEnum: TaskStatus? {
        return TaskStatus(rawValue: status)
    }
    
    public var messagePriorityEnum: MessagePriority? {
        return MessagePriority(rawValue: messagePriority)
    }
    
    public func transitionStatus(to newStatus: TaskStatus) throws(TaskStatus.TransitionError) {
        guard let current = statusEnum else { return }
        let _ = try current.transition(to: newStatus)
        self.status = newStatus.rawValue
        self.updatedAt = Date()
    }
}
