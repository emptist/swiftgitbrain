import Fluent
import Foundation

public protocol ApiReferenceRepositoryProtocol: Sendable {
    func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        apiName: String,
        apiType: String,
        endpoint: String?,
        method: String?,
        parameters: String?,
        responseSchema: String?,
        authentication: String?,
        rateLimiting: String?,
        examples: String?,
        version: String?,
        deprecated: Bool,
        deprecationNote: String?,
        createdBy: String,
        tags: [String]?
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> ApiReferenceModel?
    func getByCategory(_ category: String) async throws -> [ApiReferenceModel]
    func getByApiType(_ apiType: String) async throws -> [ApiReferenceModel]
    func search(query: String) async throws -> [ApiReferenceModel]
    func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        apiName: String?,
        apiType: String?,
        endpoint: String?,
        method: String?,
        parameters: String?,
        responseSchema: String?,
        authentication: String?,
        rateLimiting: String?,
        examples: String?,
        version: String?,
        deprecated: Bool?,
        deprecationNote: String?,
        tags: [String]?
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listApiTypes() async throws -> [String]
}
