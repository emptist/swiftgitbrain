import Fluent
import Foundation

public protocol CodeSnippetRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        language: String,
        code: String,
        description: String?,
        usageExample: String?,
        dependencies: [String]?,
        framework: String?,
        version: String?,
        complexity: String?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> CodeSnippetModel?
    func getByCategory(_ category: String) async throws -> [CodeSnippetModel]
    func getByLanguage(_ language: String) async throws -> [CodeSnippetModel]
    func getByFramework(_ framework: String) async throws -> [CodeSnippetModel]
    func search(query: String) async throws -> [CodeSnippetModel]
    func update(knowledgeId: UUID, ...) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listLanguages() async throws -> [String]
}
