import Fluent
import Foundation

final class BestPracticeModel: Model, @unchecked Sendable {
    static let schema = "best_practices"
    
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
    
    @Field(key: "description")
    var description: String
    
    @OptionalField(key: "context")
    var context: String?
    
    @OptionalField(key: "benefits")
    var benefits: [String]?
    
    @OptionalField(key: "anti_pattern")
    var antiPattern: String?
    
    @OptionalField(key: "examples")
    var examples: String?
    
    @OptionalField(key: "references")
    var references: [String]?
    
    @OptionalField(key: "applicable_to")
    var applicableTo: [String]?
    
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
