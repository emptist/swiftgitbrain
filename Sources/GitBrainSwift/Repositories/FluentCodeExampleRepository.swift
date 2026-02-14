import Fluent
import Foundation

public actor FluentCodeExampleRepository: CodeExampleRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
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
    ) async throws {
        let example = CodeExampleModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            title: title,
            description: description,
            language: language,
            code: code,
            inputExample: inputExample,
            outputExample: outputExample,
            explanation: explanation,
            complexity: complexity,
            dependencies: dependencies,
            relatedSnippets: relatedSnippets,
            createdBy: createdBy,
            tags: tags
        )
        
        try await example.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> CodeExampleModel? {
        return try await CodeExampleModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [CodeExampleModel] {
        return try await CodeExampleModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getByLanguage(_ language: String) async throws -> [CodeExampleModel] {
        return try await CodeExampleModel.query(on: database)
            .filter(\.$language == language)
            .all()
    }
    
    public func search(query: String) async throws -> [CodeExampleModel] {
        return try await CodeExampleModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$title ~~ query)
                     .filter(\.$code ~~ query)
                     .filter(\.$description ~~ query)
            }
            .all()
    }
    
    public func update(
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
    ) async throws -> Bool {
        guard let example = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { example.category = category }
        if let key = key { example.key = key }
        if let title = title { example.title = title }
        if let description = description { example.description = description }
        if let language = language { example.language = language }
        if let code = code { example.code = code }
        if let inputExample = inputExample { example.inputExample = inputExample }
        if let outputExample = outputExample { example.outputExample = outputExample }
        if let explanation = explanation { example.explanation = explanation }
        if let complexity = complexity { example.complexity = complexity }
        if let dependencies = dependencies { example.dependencies = dependencies }
        if let relatedSnippets = relatedSnippets { example.relatedSnippets = relatedSnippets }
        if let tags = tags { example.tags = tags }
        
        try await example.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let example = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await example.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let examples = try await CodeExampleModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return examples.compactMap { $0.category }
    }
    
    public func listLanguages() async throws -> [String] {
        let examples = try await CodeExampleModel.query(on: database)
            .field(\.$language)
            .unique()
            .all()
        
        return examples.compactMap { $0.language }
    }
}
