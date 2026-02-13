import Fluent
import Foundation

public final class ScoreMessageModel: Model, @unchecked Sendable {
    public static let schema = "score_messages"
    
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
    
    @Field(key: "requested_score")
    public var requestedScore: Int
    
    @Field(key: "quality_justification")
    public var qualityJustification: String
    
    @OptionalField(key: "awarded_score")
    public var awardedScore: Int?
    
    @OptionalField(key: "award_reason")
    public var awardReason: String?
    
    @OptionalField(key: "reject_reason")
    public var rejectReason: String?
    
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
        requestedScore: Int,
        qualityJustification: String,
        awardedScore: Int? = nil,
        awardReason: String? = nil,
        rejectReason: String? = nil,
        status: ScoreStatus = .pending,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.taskId = taskId
        self.requestedScore = requestedScore
        self.qualityJustification = qualityJustification
        self.awardedScore = awardedScore
        self.awardReason = awardReason
        self.rejectReason = rejectReason
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var statusEnum: ScoreStatus? {
        return ScoreStatus(rawValue: status)
    }
    
    public func transitionStatus(to newStatus: ScoreStatus) throws(ScoreStatus.TransitionError) {
        guard let current = statusEnum else { return }
        let _ = try current.transition(to: newStatus)
        self.status = newStatus.rawValue
        self.updatedAt = Date()
    }
}
