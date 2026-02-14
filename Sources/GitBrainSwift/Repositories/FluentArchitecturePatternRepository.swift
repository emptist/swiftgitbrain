import Fluent
import Foundation

public actor FluentArchitecturePatternRepository: ArchitecturePatternRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        patternName: String,
        description: String,
        problem: String?,
        solution: String?,
        consequences: [String]?,
        useCases: [String]?,
        relatedPatterns: [String]?,
        examples: String?,
        createdBy: String,
        tags: [String]?
    ) async throws {
        let pattern = ArchitecturePatternModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            patternName: patternName,
            description: description,
            problem: problem,
            solution: solution,
            consequences: consequences,
            useCases: useCases,
            relatedPatterns: relatedPatterns,
            examples: examples,
            createdBy: createdBy,
            tags: tags
        )
        
        try await pattern.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> ArchitecturePatternModel? {
        return try await ArchitecturePatternModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [ArchitecturePatternModel] {
        return try await ArchitecturePatternModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func search(query: String) async throws -> [ArchitecturePatternModel] {
        return try await ArchitecturePatternModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$patternName ~~ query)
                     .filter(\.$description ~~ query)
            }
            .all()
    }
    
    public func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        patternName: String?,
        description: String?,
        problem: String?,
        solution: String?,
        consequences: [String]?,
        useCases: [String]?,
        relatedPatterns: [String]?,
        examples: String?,
        tags: [String]?
    ) async throws -> Bool {
        guard let pattern = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { pattern.category = category }
        if let key = key { pattern.key = key }
        if let patternName = patternName { pattern.patternName = patternName }
        if let description = description { pattern.description = description }
        if let problem = problem { pattern.problem = problem }
        if let solution = solution { pattern.solution = solution }
        if let consequences = consequences { pattern.consequences = consequences }
        if let useCases = useCases { pattern.useCases = useCases }
        if let relatedPatterns = relatedPatterns { pattern.relatedPatterns = relatedPatterns }
        if let examples = examples { pattern.examples = examples }
        if let tags = tags { pattern.tags = tags }
        
        try await pattern.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let pattern = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await pattern.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let patterns = try await ArchitecturePatternModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return patterns.compactMap { $0.category }
    }
}
