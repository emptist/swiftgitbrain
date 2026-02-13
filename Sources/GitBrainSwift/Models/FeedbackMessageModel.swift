import Fluent
import Foundation

public final class FeedbackMessageModel: Model, @unchecked Sendable {
    public static let schema = "feedback_messages"
    
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
    
    @Field(key: "feedback_type")
    public var feedbackType: String
    
    @Field(key: "subject")
    public var subject: String
    
    @Field(key: "content")
    public var content: String
    
    @OptionalField(key: "related_task_id")
    public var relatedTaskId: String?
    
    @OptionalField(key: "response")
    public var response: String?
    
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
        feedbackType: String,
        subject: String,
        content: String,
        relatedTaskId: String? = nil,
        response: String? = nil,
        status: FeedbackStatus = .pending,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.feedbackType = feedbackType
        self.subject = subject
        self.content = content
        self.relatedTaskId = relatedTaskId
        self.response = response
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var statusEnum: FeedbackStatus? {
        return FeedbackStatus(rawValue: status)
    }
    
    public func transitionStatus(to newStatus: FeedbackStatus) throws(FeedbackStatus.TransitionError) {
        guard let current = statusEnum else { return }
        let _ = try current.transition(to: newStatus)
        self.status = newStatus.rawValue
        self.updatedAt = Date()
    }
}
