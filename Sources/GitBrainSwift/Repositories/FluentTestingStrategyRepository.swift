import Fluent
import Foundation

public actor FluentTestingStrategyRepository: TestingStrategyRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        strategyName: String,
        testingType: String,
        description: String,
        scope: String?,
        techniques: [String]?,
        tools: [String]?,
        bestPractices: [String]?,
        coverageGoals: String?,
        automationLevel: String?,
        testDataStrategy: String?,
        ciCdIntegration: String?,
        examples: String?,
        createdBy: String,
        tags: [String]?
    ) async throws {
        let strategy = TestingStrategyModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            strategyName: strategyName,
            testingType: testingType,
            description: description,
            scope: scope,
            techniques: techniques,
            tools: tools,
            bestPractices: bestPractices,
            coverageGoals: coverageGoals,
            automationLevel: automationLevel,
            testDataStrategy: testDataStrategy,
            ciCdIntegration: ciCdIntegration,
            examples: examples,
            createdBy: createdBy,
            tags: tags
        )
        
        try await strategy.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> TestingStrategyModel? {
        return try await TestingStrategyModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [TestingStrategyModel] {
        return try await TestingStrategyModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getByTestingType(_ testingType: String) async throws -> [TestingStrategyModel] {
        return try await TestingStrategyModel.query(on: database)
            .filter(\.$testingType == testingType)
            .all()
    }
    
    public func search(query: String) async throws -> [TestingStrategyModel] {
        return try await TestingStrategyModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$strategyName ~~ query)
                     .filter(\.$description ~~ query)
            }
            .all()
    }
    
    public func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        strategyName: String?,
        testingType: String?,
        description: String?,
        scope: String?,
        techniques: [String]?,
        tools: [String]?,
        bestPractices: [String]?,
        coverageGoals: String?,
        automationLevel: String?,
        testDataStrategy: String?,
        ciCdIntegration: String?,
        examples: String?,
        tags: [String]?
    ) async throws -> Bool {
        guard let strategy = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { strategy.category = category }
        if let key = key { strategy.key = key }
        if let strategyName = strategyName { strategy.strategyName = strategyName }
        if let testingType = testingType { strategy.testingType = testingType }
        if let description = description { strategy.description = description }
        if let scope = scope { strategy.scope = scope }
        if let techniques = techniques { strategy.techniques = techniques }
        if let tools = tools { strategy.tools = tools }
        if let bestPractices = bestPractices { strategy.bestPractices = bestPractices }
        if let coverageGoals = coverageGoals { strategy.coverageGoals = coverageGoals }
        if let automationLevel = automationLevel { strategy.automationLevel = automationLevel }
        if let testDataStrategy = testDataStrategy { strategy.testDataStrategy = testDataStrategy }
        if let ciCdIntegration = ciCdIntegration { strategy.ciCdIntegration = ciCdIntegration }
        if let examples = examples { strategy.examples = examples }
        if let tags = tags { strategy.tags = tags }
        
        try await strategy.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let strategy = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await strategy.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let strategies = try await TestingStrategyModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return strategies.compactMap { $0.category }
    }
    
    public func listTestingTypes() async throws -> [String] {
        let strategies = try await TestingStrategyModel.query(on: database)
            .field(\.$testingType)
            .unique()
            .all()
        
        return strategies.compactMap { $0.testingType }
    }
}
