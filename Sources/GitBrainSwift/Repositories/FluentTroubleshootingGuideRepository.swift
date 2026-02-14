import Fluent
import Foundation

public actor FluentTroubleshootingGuideRepository: TroubleshootingGuideRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(
        knowledgeId: UUID,
        category: String,
        key: String,
        issueTitle: String,
        issueDescription: String,
        symptoms: [String]?,
        rootCause: String?,
        solutions: String?,
        prevention: String?,
        relatedIssues: [String]?,
        severity: String?,
        frequency: String?,
        createdBy: String,
        tags: [String]?
    ) async throws {
        let guide = TroubleshootingGuideModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            issueTitle: issueTitle,
            issueDescription: issueDescription,
            symptoms: symptoms,
            rootCause: rootCause,
            solutions: solutions,
            prevention: prevention,
            relatedIssues: relatedIssues,
            severity: severity,
            frequency: frequency,
            createdBy: createdBy,
            tags: tags
        )
        
        try await guide.save(on: database)
    }
    
    public func get(knowledgeId: UUID) async throws -> TroubleshootingGuideModel? {
        return try await TroubleshootingGuideModel.query(on: database)
            .filter(\.$knowledgeId == knowledgeId)
            .first()
    }
    
    public func getByCategory(_ category: String) async throws -> [TroubleshootingGuideModel] {
        return try await TroubleshootingGuideModel.query(on: database)
            .filter(\.$category == category)
            .all()
    }
    
    public func getBySeverity(_ severity: String) async throws -> [TroubleshootingGuideModel] {
        return try await TroubleshootingGuideModel.query(on: database)
            .filter(\.$severity == severity)
            .all()
    }
    
    public func search(query: String) async throws -> [TroubleshootingGuideModel] {
        return try await TroubleshootingGuideModel.query(on: database)
            .group(.or) { group in
                group.filter(\.$issueTitle ~~ query)
                     .filter(\.$issueDescription ~~ query)
            }
            .all()
    }
    
    public func update(
        knowledgeId: UUID,
        category: String?,
        key: String?,
        issueTitle: String?,
        issueDescription: String?,
        symptoms: [String]?,
        rootCause: String?,
        solutions: String?,
        prevention: String?,
        relatedIssues: [String]?,
        severity: String?,
        frequency: String?,
        tags: [String]?
    ) async throws -> Bool {
        guard let guide = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        if let category = category { guide.category = category }
        if let key = key { guide.key = key }
        if let issueTitle = issueTitle { guide.issueTitle = issueTitle }
        if let issueDescription = issueDescription { guide.issueDescription = issueDescription }
        if let symptoms = symptoms { guide.symptoms = symptoms }
        if let rootCause = rootCause { guide.rootCause = rootCause }
        if let solutions = solutions { guide.solutions = solutions }
        if let prevention = prevention { guide.prevention = prevention }
        if let relatedIssues = relatedIssues { guide.relatedIssues = relatedIssues }
        if let severity = severity { guide.severity = severity }
        if let frequency = frequency { guide.frequency = frequency }
        if let tags = tags { guide.tags = tags }
        
        try await guide.save(on: database)
        return true
    }
    
    public func delete(knowledgeId: UUID) async throws -> Bool {
        guard let guide = try await get(knowledgeId: knowledgeId) else {
            return false
        }
        
        try await guide.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let guides = try await TroubleshootingGuideModel.query(on: database)
            .field(\.$category)
            .unique()
            .all()
        
        return guides.compactMap { $0.category }
    }
    
    public func listSeverities() async throws -> [String] {
        let guides = try await TroubleshootingGuideModel.query(on: database)
            .field(\.$severity)
            .unique()
            .all()
        
        return guides.compactMap { $0.severity }
    }
}
