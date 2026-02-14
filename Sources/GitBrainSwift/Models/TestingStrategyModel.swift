import Fluent
import Foundation

public final class TestingStrategyModel: Model, @unchecked Sendable {
    public static let schema = "testing_strategies"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "strategy_name")
    public var strategyName: String
    
    @Field(key: "testing_type")
    public var testingType: String
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "scope")
    public var scope: String?
    
    @OptionalField(key: "techniques")
    public var techniques: [String]?
    
    @OptionalField(key: "tools")
    public var tools: [String]?
    
    @OptionalField(key: "best_practices")
    public var bestPractices: [String]?
    
    @OptionalField(key: "coverage_goals")
    public var coverageGoals: String?
    
    @OptionalField(key: "automation_level")
    public var automationLevel: String?
    
    @OptionalField(key: "test_data_strategy")
    public var testDataStrategy: String?
    
    @OptionalField(key: "ci_cd_integration")
    public var ciCdIntegration: String?
    
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
        strategyName: String,
        testingType: String,
        description: String,
        scope: String? = nil,
        techniques: [String]? = nil,
        tools: [String]? = nil,
        bestPractices: [String]? = nil,
        coverageGoals: String? = nil,
        automationLevel: String? = nil,
        testDataStrategy: String? = nil,
        ciCdIntegration: String? = nil,
        examples: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.strategyName = strategyName
        self.testingType = testingType
        self.description = description
        self.scope = scope
        self.techniques = techniques
        self.tools = tools
        self.bestPractices = bestPractices
        self.coverageGoals = coverageGoals
        self.automationLevel = automationLevel
        self.testDataStrategy = testDataStrategy
        self.ciCdIntegration = ciCdIntegration
        self.examples = examples
        self.createdBy = createdBy
        self.tags = tags
    }
}
