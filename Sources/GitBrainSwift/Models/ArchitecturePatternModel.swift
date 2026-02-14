import Fluent
import Foundation

final class ArchitecturePatternModel: Model, @unchecked Sendable {
    static let schema = "architecture_patterns"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "pattern_name")
    var patternName: String
    
    @Field(key: "description")
    var description: String
    
    @OptionalField(key: "problem")
    var problem: String?
    
    @OptionalField(key: "solution")
    var solution: String?
    
    @OptionalField(key: "consequences")
    var consequences: [String]?
    
    @OptionalField(key: "use_cases")
    var useCases: [String]?
    
    @OptionalField(key: "related_patterns")
    var relatedPatterns: [String]?
    
    @OptionalField(key: "examples")
    var examples: String?
    
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
        patternName: String,
        description: String,
        problem: String? = nil,
        solution: String? = nil,
        consequences: [String]? = nil,
        useCases: [String]? = nil,
        relatedPatterns: [String]? = nil,
        examples: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.patternName = patternName
        self.description = description
        self.problem = problem
        self.solution = solution
        self.consequences = consequences
        self.useCases = useCases
        self.relatedPatterns = relatedPatterns
        self.examples = examples
        self.createdBy = createdBy
        self.tags = tags
    }
}
