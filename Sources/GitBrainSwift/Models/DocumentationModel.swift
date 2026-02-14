import Fluent
import Foundation

final class DocumentationModel: Model, @unchecked Sendable {
    static let schema = "documentation"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @OptionalField(key: "summary")
    var summary: String?
    
    @OptionalField(key: "version")
    var version: String?
    
    @OptionalField(key: "last_reviewed")
    var lastReviewed: Date?
    
    @OptionalField(key: "review_status")
    var reviewStatus: String?
    
    @OptionalField(key: "related_topics")
    var relatedTopics: [String]?
    
    @OptionalField(key: "external_links")
    var externalLinks: String?
    
    @Field(key: "created_by")
    var createdBy: String
    
    @OptionalField(key: "tags")
    var tags: [String]?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
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
