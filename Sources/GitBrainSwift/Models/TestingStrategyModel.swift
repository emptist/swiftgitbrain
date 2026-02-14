import Fluent
import Foundation

final class TestingStrategyModel: Model, @unchecked Sendable {
    static let schema = "testing_strategies"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "strategy_name")
    var strategyName: String
    
    @Field(key: "testing_type")
    var testingType: String
    
    @Field(key: "description")
    var description: String
    
    @OptionalField(key: "scope")
    var scope: String?
    
    @OptionalField(key: "techniques")
    var techniques: [String]?
    
    @OptionalField(key: "tools")
    var tools: [String]?
    
    @OptionalField(key: "best_practices")
    var bestPractices: [String]?
    
    @OptionalField(key: "coverage_goals")
    var coverageGoals: String?
    
    @OptionalField(key: "automation_level")
    var automationLevel: String?
    
    @OptionalField(key: "test_data_strategy")
    var testDataStrategy: String?
    
    @OptionalField(key: "ci_cd_integration")
    var ciCdIntegration: String?
    
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
