import Fluent
import Foundation

public protocol DesignPatternRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        patternName: String,
        patternType: String,
        description: String,
        intent: String?,
        motivation: String?,
        applicability: String?,
        structure: String?,
        participants: [String]?,
        collaborations: String?,
        consequences: [String]?,
        implementation: String?,
        sampleCode: String?,
        knownUses: [String]?,
        relatedPatterns: [String]?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> DesignPatternModel?
    func getByCategory(_ category: String) async throws -> [DesignPatternModel]
    func getByPatternType(_ patternType: String) async throws -> [DesignPatternModel]
    func search(query: String) async throws -> [DesignPatternModel]
    func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        patternName: String?,
        patternType: String?,
        description: String?,
        intent: String?,
        motivation: String?,
        applicability: String?,
        structure: String?,
        participants: [String]?,
        collaborations: String?,
        consequences: [String]?,
        implementation: String?,
        sampleCode: String?,
        knownUses: [String]?,
        relatedPatterns: [String]?,
        tags: [String]?
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listPatternTypes() async throws -> [String]
}
