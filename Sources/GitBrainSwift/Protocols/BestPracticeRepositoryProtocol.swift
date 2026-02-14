import Fluent
import Foundation

public protocol BestPracticeRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        title: String,
        description: String,
        context: String?,
        benefits: [String]?,
        antiPattern: String?,
        examples: String?,
        references: [String]?,
        applicableTo: [String]?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> BestPracticeModel?
    func getByCategory(_ category: String) async throws -> [BestPracticeModel]
    func search(query: String) async throws -> [BestPracticeModel]
    func update(knowledgeId: UUID, ...) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
}
