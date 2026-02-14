import Fluent
import Foundation

public actor FluentCodeSnippetRepository: CodeSnippetRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
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
    ) async throws {
        let snippet = CodeSnippetModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            language: language,
            code: code,
            description: description,
            usageExample: usageExample,
            dependencies: dependencies,
            framework: framework,
            version: version,
            complexity: complexity,
            createdBy: createdBy,
            tags: tags
        )
        
        try await snippet.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> CodeSnippetModel? {
        return try await CodeSnippetModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [CodeSnippetModel] {
        return try await CodeSnippetModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getByLanguage(_ language: String) async throws -> [CodeSnippetModel] {
        return try await CodeSnippetModel.query(on: database)
            .filter(\.$language == language)
            .all()
    }
    
    public func getByFramework(_ framework: String) async throws -> [CodeSnippetModel] {
        return try await CodeSnippetModel.query(on: database)
            .filter(\.$framework == framework)
            .all()
    }
    
    public func search(query: String) async throws -> [CodeSnippetModel] {
        return try await CodeSnippetModel.query(on: database)
            .group(.or) { group in
                group
                    .filter(\.$code ~~ query)
                    .filter(\.$description ~~ query)
                    .filter(\.$usageExample ~~ query)
            }
            .all()
    }
    
    public func update(
        knowledgeId: UUID,
        category: String? = nil,
        key: String? = nil,
        language: String? = nil,
        code: String? = nil,
        description: String? = nil,
        usageExample: String? = nil,
        dependencies: [String]? = nil,
        framework: String? = nil,
        version: String? = nil,
        complexity: String? = nil,
        tags: [String]? = nil
    ) async throws -> Bool {
        guard let snippet = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { snippet.category = category }
        if let key = key { snippet.key = key }
        if let language = language { snippet.language = language }
        if let code = code { snippet.code = code }
        if let description = description { snippet.description = description }
        if let usageExample = usageExample { snippet.usageExample = usageExample }
        if let dependencies = dependencies { snippet.dependencies = dependencies }
        if let framework = framework { snippet.framework = framework }
        if let version = version { snippet.version = version }
        if let complexity = complexity { snippet.complexity = complexity }
        if let tags = tags { snippet.tags = tags }
        
        try await snippet.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let snippet = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await snippet.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let snippets = try await CodeSnippetModel.query(on: database).all()
        let categories = Set(snippets.map { $0.category })
        return Array(categories).sorted()
    }
    
    public func listLanguages() async throws -> [String] {
        let snippets = try await CodeSnippetModel.query(on: database).all()
        let languages = Set(snippets.map { $0.language })
        return Array(languages).sorted()
    }
}
