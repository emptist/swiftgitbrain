import Fluent
import Foundation

public final class HeartbeatMessageModel: Model, @unchecked Sendable {
    public static let schema = "heartbeat_messages"
    
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
    
    @Field(key: "ai_role")
    public var aiRole: String
    
    @Field(key: "status")
    public var status: String
    
    @OptionalField(key: "current_task")
    public var currentTask: String?
    
    @OptionalField(key: "metadata")
    public var metadata: [String: String]?
    
    @Field(key: "created_at")
    public var createdAt: Date
    
    public init() {}
    
    public init(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        timestamp: Date,
        aiRole: String,
        status: HeartbeatStatus = .active,
        currentTask: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.aiRole = aiRole
        self.status = status.rawValue
        self.currentTask = currentTask
        self.metadata = metadata
        self.createdAt = Date()
    }
    
    public var statusEnum: HeartbeatStatus? {
        return HeartbeatStatus(rawValue: status)
    }
}
