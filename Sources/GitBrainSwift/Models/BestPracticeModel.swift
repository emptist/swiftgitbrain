import Fluent
import Foundation

public final class BestPracticeModel: Model, @unchecked Sendable {
    public static let schema = "best_practices"
    
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
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "context")
    public var context: String?
    
    @OptionalField(key: "benefits")
    public var benefits: [String]?
    
    @OptionalField(key: "anti_pattern")
    public var antiPattern: String?
    
    @OptionalField(key: "examples")
    public var examples: String?
    
    @OptionalField(key: "references")
    public var references: [String]?
    
    @OptionalField(key: "applicable_to")
    public var applicableTo: [String]?
    
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
        description: String,
        context: String? = nil,
        benefits: [String]? = nil,
        antiPattern: String? = nil,
        examples: String? = nil,
        references: [String]? = nil,
        applicableTo: [String]? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.title = title
        self.description = description
        self.context = context
        self.benefits = benefits
        self.antiPattern = antiPattern
        self.examples = examples
        self.references = references
        self.applicableTo = applicableTo
        self.createdBy = createdBy
        self.tags = tags
    }
}
