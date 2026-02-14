import Fluent
import Foundation

public actor FluentApiReferenceRepository: ApiReferenceRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
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
    ) async throws {
        let api = ApiReferenceModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            apiName: apiName,
            apiType: apiType,
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            responseSchema: responseSchema,
            authentication: authentication,
            rateLimiting: rateLimiting,
            examples: examples,
            version: version,
            deprecated: deprecated,
            deprecationNote: deprecationNote,
            createdBy: createdBy,
            tags: tags
        )
        
        try await api.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> ApiReferenceModel? {
        return try await ApiReferenceModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [ApiReferenceModel] {
        return try await ApiReferenceModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getByApiType(_ apiType: String) async throws -> [ApiReferenceModel] {
        return try await ApiReferenceModel.query(on: database)
            .filter(\.$apiType == apiType)
            .all()
    }
    
    public func search(query: String) async throws -> [ApiReferenceModel] {
        return try await ApiReferenceModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$apiName ~~ query)
                     .filter(\.$endpoint ~~ query)
            }
            .all()
    }
    
    public func update(
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
    ) async throws -> Bool {
        guard let api = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { api.category = category }
        if let key = key { api.key = key }
        if let apiName = apiName { api.apiName = apiName }
        if let apiType = apiType { api.apiType = apiType }
        if let endpoint = endpoint { api.endpoint = endpoint }
        if let method = method { api.method = method }
        if let parameters = parameters { api.parameters = parameters }
        if let responseSchema = responseSchema { api.responseSchema = responseSchema }
        if let authentication = authentication { api.authentication = authentication }
        if let rateLimiting = rateLimiting { api.rateLimiting = rateLimiting }
        if let examples = examples { api.examples = examples }
        if let version = version { api.version = version }
        if let deprecated = deprecated { api.deprecated = deprecated }
        if let deprecationNote = deprecationNote { api.deprecationNote = deprecationNote }
        if let tags = tags { api.tags = tags }
        
        try await api.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let api = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await api.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let apis = try await ApiReferenceModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return apis.compactMap { $0.category }
    }
    
    public func listApiTypes() async throws -> [String] {
        let apis = try await ApiReferenceModel.query(on: database)
            .field(\.$apiType)
            .unique()
            .all()
        
        return apis.compactMap { $0.apiType }
    }
}
