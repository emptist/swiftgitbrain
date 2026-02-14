import Fluent
import Foundation

public actor FluentBestPracticeRepository: BestPracticeRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
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
    ) async throws {
        let practice = BestPracticeModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            title: title,
            description: description,
            context: context,
            benefits: benefits,
            antiPattern: antiPattern,
            examples: examples,
            references: references,
            applicableTo: applicableTo,
            createdBy: createdBy,
            tags: tags
        )
        
        try await practice.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> BestPracticeModel? {
        return try await BestPracticeModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [BestPracticeModel] {
        return try await BestPracticeModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func search(query: String) async throws -> [BestPracticeModel] {
        return try await BestPracticeModel.query(on: database)
            .group(.or) { group in
                group
                    .filter(\.$title ~~ query)
                    .filter(\.$description ~~ query)
                    .filter(\.$context ~~ query)
            }
            .all()
    }
    
    public func update(
        knowledgeId: UUID,
        category: String? = nil,
        key: String? = nil,
        title: String? = nil,
        description: String? = nil,
        context: String? = nil,
        benefits: [String]? = nil,
        antiPattern: String? = nil,
        examples: String? = nil,
        references: [String]? = nil,
        applicableTo: [String]? = nil,
        tags: [String]? = nil
    ) async throws -> Bool {
        guard let practice = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { practice.category = category }
        if let key = key { practice.key = key }
        if let title = title { practice.title = title }
        if let description = description { practice.description = description }
        if let context = context { practice.context = context }
        if let benefits = benefits { practice.benefits = benefits }
        if let antiPattern = antiPattern { practice.antiPattern = antiPattern }
        if let examples = examples { practice.examples = examples }
        if let references = references { practice.references = references }
        if let applicableTo = applicableTo { practice.applicableTo = applicableTo }
        if let tags = tags { practice.tags = tags }
        
        try await practice.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let practice = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await practice.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let practices = try await BestPracticeModel.query(on: database).all()
        let categories = Set(practices.map { $0.category })
        return Array(categories).sorted()
    }
}
