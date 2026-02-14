import Fluent
import Foundation

public actor FluentDocumentationRepository: DocumentationRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
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
    ) async throws {
        let doc = DocumentationModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            title: title,
            content: content,
            summary: summary,
            version: version,
            lastReviewed: lastReviewed,
            reviewStatus: reviewStatus,
            relatedTopics: relatedTopics,
            externalLinks: externalLinks,
            createdBy: createdBy,
            tags: tags
        )
        
        try await doc.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> DocumentationModel? {
        return try await DocumentationModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [DocumentationModel] {
        return try await DocumentationModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func search(query: String) async throws -> [DocumentationModel] {
        return try await DocumentationModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$title ~~ query)
                     .filter(\.$content ~~ query)
                     .filter(\.$summary ~~ query)
            }
            .all()
    }
    
    public func update(
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
    ) async throws -> Bool {
        guard let doc = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { doc.category = category }
        if let key = key { doc.key = key }
        if let title = title { doc.title = title }
        if let content = content { doc.content = content }
        if let summary = summary { doc.summary = summary }
        if let version = version { doc.version = version }
        if let lastReviewed = lastReviewed { doc.lastReviewed = lastReviewed }
        if let reviewStatus = reviewStatus { doc.reviewStatus = reviewStatus }
        if let relatedTopics = relatedTopics { doc.relatedTopics = relatedTopics }
        if let externalLinks = externalLinks { doc.externalLinks = externalLinks }
        if let tags = tags { doc.tags = tags }
        
        try await doc.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let doc = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await doc.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let docs = try await DocumentationModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return docs.compactMap { $0.category }
    }
}
