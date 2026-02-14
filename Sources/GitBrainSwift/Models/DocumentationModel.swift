import Fluent
import Foundation

public final class DocumentationModel: Model, @unchecked Sendable {
    public static let schema = "documentation"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "title")
    public var title: String
    
    @Field(key: "content")
    public var content: String
    
    @OptionalField(key: "summary")
    public var summary: String?
    
    @OptionalField(key: "version")
    public var version: String?
    
    @OptionalField(key: "last_reviewed")
    public var lastReviewed: Date?
    
    @OptionalField(key: "review_status")
    public var reviewStatus: String?
    
    @OptionalField(key: "related_topics")
    public var relatedTopics: [String]?
    
    @OptionalField(key: "external_links")
    public var externalLinks: String?
    
    @Field(key: "created_by")
    public var createdBy: String
    
    @OptionalField(key: "tags")
    public var tags: [String]?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init() {}
    
    public init(
        id: UUID? = nil,
        knowledgeId: UUID,
        category: String,
        key: String,
        title: String,
        content: String,
        summary: String? = nil,
        version: String? = nil,
        lastReviewed: Date? = nil,
        reviewStatus: String? = nil,
        relatedTopics: [String]? = nil,
        externalLinks: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.title = title
        self.content = content
        self.summary = summary
        self.version = version
        self.lastReviewed = lastReviewed
        self.reviewStatus = reviewStatus
        self.relatedTopics = relatedTopics
        self.externalLinks = externalLinks
        self.createdBy = createdBy
        self.tags = tags
    }
}
