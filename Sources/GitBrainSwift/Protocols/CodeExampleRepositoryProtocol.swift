import Fluent
import Foundation

public protocol CodeExampleRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        title: String,
        description: String?,
        language: String,
        code: String,
        inputExample: String?,
        outputExample: String?,
        explanation: String?,
        complexity: String?,
        dependencies: [String]?,
        relatedSnippets: [String]?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> CodeExampleModel?
    func getByCategory(_ category: String) async throws -> [CodeExampleModel]
    func getByLanguage(_ language: String) async throws -> [CodeExampleModel]
    func search(query: String) async throws -> [CodeExampleModel]
    func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        title: String?,
        description: String?,
        language: String?,
        code: String?,
        inputExample: String?,
        outputExample: String?,
        explanation: String?,
        complexity: String?,
        dependencies: [String]?,
        relatedSnippets: [String]?,
        tags: [String]?
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listLanguages() async throws -> [String]
}
