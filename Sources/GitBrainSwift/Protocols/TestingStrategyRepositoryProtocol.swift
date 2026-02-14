import Fluent
import Foundation

public protocol TestingStrategyRepositoryProtocol: Sendable {
    func add(
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
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> TestingStrategyModel?
    func getByCategory(_ category: String) async throws -> [TestingStrategyModel]
    func getByTestingType(_ testingType: String) async throws -> [TestingStrategyModel]
    func search(query: String) async throws -> [TestingStrategyModel]
    func update(
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
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listTestingTypes() async throws -> [String]
}
