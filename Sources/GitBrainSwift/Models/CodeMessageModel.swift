import Fluent
import Foundation

public final class CodeMessageModel: Model, @unchecked Sendable {
    public static let schema = "code_messages"
    
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
    
    @Field(key: "code_id")
    public var codeId: String
    
    @Field(key: "title")
    public var title: String
    
    @Field(key: "description")
    public var description: String
    
    @Field(key: "files")
    public var files: [String]
    
    @OptionalField(key: "branch")
    public var branch: String?
    
    @OptionalField(key: "commit_sha")
    public var commitSha: String?
    
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
        codeId: String,
        title: String,
        description: String,
        files: [String],
        branch: String? = nil,
        commitSha: String? = nil,
        status: CodeStatus = .pending,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.codeId = codeId
        self.title = title
        self.description = description
        self.files = files
        self.branch = branch
        self.commitSha = commitSha
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var statusEnum: CodeStatus? {
        return CodeStatus(rawValue: status)
    }
    
    public func transitionStatus(to newStatus: CodeStatus) throws(CodeStatus.TransitionError) {
        guard let current = statusEnum else { return }
        let _ = try current.transition(to: newStatus)
        self.status = newStatus.rawValue
        self.updatedAt = Date()
    }
}
