import Fluent
import Foundation

public final class ArchitecturePatternModel: Model, @unchecked Sendable {
    public static let schema = "architecture_patterns"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "pattern_name")
    public var patternName: String
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "problem")
    public var problem: String?
    
    @OptionalField(key: "solution")
    public var solution: String?
    
    @OptionalField(key: "consequences")
    public var consequences: [String]?
    
    @OptionalField(key: "use_cases")
    public var useCases: [String]?
    
    @OptionalField(key: "related_patterns")
    public var relatedPatterns: [String]?
    
    @OptionalField(key: "examples")
    public var examples: String?
    
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
