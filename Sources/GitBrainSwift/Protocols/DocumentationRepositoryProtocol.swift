import Fluent
import Foundation

public protocol DocumentationRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        title: String,
        content: String,
        summary: String?,
        version: String?,
        lastReviewed: Date?,
        reviewStatus: String?,
        relatedTopics: [String]?,
        externalLinks: String?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> DocumentationModel?
    func getByCategory(_ category: String) async throws -> [DocumentationModel]
    func search(query: String) async throws -> [DocumentationModel]
    func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        title: String?,
        content: String?,
        summary: String?,
        version: String?,
        lastReviewed: Date?,
        reviewStatus: String?,
        relatedTopics: [String]?,
        externalLinks: String?,
        tags: [String]?
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
}
