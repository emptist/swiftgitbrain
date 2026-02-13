import Fluent
import Foundation

public final class ReviewMessageModel: Model, @unchecked Sendable {
    public static let schema = "review_messages"
    
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
    
    @Field(key: "approved")
    public var approved: Bool
    
    @Field(key: "reviewer")
    public var reviewer: String
    
    @OptionalField(key: "comments")
    public var comments: [ReviewComment]?
    
    @OptionalField(key: "feedback")
    public var feedback: String?
    
    @OptionalField(key: "files_reviewed")
    public var filesReviewed: [String]?
    
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
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]? = nil,
        feedback: String? = nil,
        filesReviewed: [String]? = nil,
        status: ReviewStatus = .pending,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.taskId = taskId
        self.approved = approved
        self.reviewer = reviewer
        self.comments = comments
        self.feedback = feedback
        self.filesReviewed = filesReviewed
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = timestamp
        self.updatedAt = timestamp
    }
    
    public var statusEnum: ReviewStatus? {
        return ReviewStatus(rawValue: status)
    }
    
    public var messagePriorityEnum: MessagePriority? {
        return MessagePriority(rawValue: messagePriority)
    }
    
    public func transitionStatus(to newStatus: ReviewStatus) throws(ReviewStatus.TransitionError) {
        guard let current = statusEnum else { return }
        let _ = try current.transition(to: newStatus)
        self.status = newStatus.rawValue
        self.updatedAt = Date()
    }
    
    public func getCommentsByFile() -> [String: [ReviewComment]] {
        guard let comments = comments else { return [:] }
        var result: [String: [ReviewComment]] = [:]
        for comment in comments {
            if result[comment.file] == nil {
                result[comment.file] = []
            }
            result[comment.file]?.append(comment)
        }
        return result
    }
}
