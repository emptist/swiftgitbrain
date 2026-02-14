import Fluent
import Foundation

public protocol ArchitecturePatternRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        patternName: String,
        description: String,
        problem: String?,
        solution: String?,
        consequences: [String]?,
        useCases: [String]?,
        relatedPatterns: [String]?,
        examples: String?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> ArchitecturePatternModel?
    func getByCategory(_ category: String) async throws -> [ArchitecturePatternModel]
    func search(query: String) async throws -> [ArchitecturePatternModel]
    func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        patternName: String?,
        description: String?,
        problem: String?,
        solution: String?,
        consequences: [String]?,
        useCases: [String]?,
        relatedPatterns: [String]?,
        examples: String?,
        tags: [String]?
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
}
