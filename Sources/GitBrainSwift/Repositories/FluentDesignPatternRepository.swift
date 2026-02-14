import Fluent
import Foundation

public actor FluentDesignPatternRepository: DesignPatternRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        patternName: String,
        patternType: String,
        description: String,
        intent: String?,
        motivation: String?,
        applicability: String?,
        structure: String?,
        participants: [String]?,
        collaborations: String?,
        consequences: [String]?,
        implementation: String?,
        sampleCode: String?,
        knownUses: [String]?,
        relatedPatterns: [String]?,
        createdBy: String,
        tags: [String]?
    ) async throws {
        let pattern = DesignPatternModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            patternName: patternName,
            patternType: patternType,
            description: description,
            intent: intent,
            motivation: motivation,
            applicability: applicability,
            structure: structure,
            participants: participants,
            collaborations: collaborations,
            consequences: consequences,
            implementation: implementation,
            sampleCode: sampleCode,
            knownUses: knownUses,
            relatedPatterns: relatedPatterns,
            createdBy: createdBy,
            tags: tags
        )
        
        try await pattern.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> DesignPatternModel? {
        return try await DesignPatternModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [DesignPatternModel] {
        return try await DesignPatternModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getByPatternType(_ patternType: String) async throws -> [DesignPatternModel] {
        return try await DesignPatternModel.query(on: database)
            .filter(\.$patternType == patternType)
            .all()
    }
    
    public func search(query: String) async throws -> [DesignPatternModel] {
        return try await DesignPatternModel.query(on: database)
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
        patternType: String?,
        description: String?,
        intent: String?,
        motivation: String?,
        applicability: String?,
        structure: String?,
        participants: [String]?,
        collaborations: String?,
        consequences: [String]?,
        implementation: String?,
        sampleCode: String?,
        knownUses: [String]?,
        relatedPatterns: [String]?,
        tags: [String]?
    ) async throws -> Bool {
        guard let pattern = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { pattern.category = category }
        if let key = key { pattern.key = key }
        if let patternName = patternName { pattern.patternName = patternName }
        if let patternType = patternType { pattern.patternType = patternType }
        if let description = description { pattern.description = description }
        if let intent = intent { pattern.intent = intent }
        if let motivation = motivation { pattern.motivation = motivation }
        if let applicability = applicability { pattern.applicability = applicability }
        if let structure = structure { pattern.structure = structure }
        if let participants = participants { pattern.participants = participants }
        if let collaborations = collaborations { pattern.collaborations = collaborations }
        if let consequences = consequences { pattern.consequences = consequences }
        if let implementation = implementation { pattern.implementation = implementation }
        if let sampleCode = sampleCode { pattern.sampleCode = sampleCode }
        if let knownUses = knownUses { pattern.knownUses = knownUses }
        if let relatedPatterns = relatedPatterns { pattern.relatedPatterns = relatedPatterns }
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
        let patterns = try await DesignPatternModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return patterns.compactMap { $0.category }
    }
    
    public func listPatternTypes() async throws -> [String] {
        let patterns = try await DesignPatternModel.query(on: database)
            .field(\.$patternType)
            .unique()
            .all()
        
        return patterns.compactMap { $0.patternType }
    }
}
