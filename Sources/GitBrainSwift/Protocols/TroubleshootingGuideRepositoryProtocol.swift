import Fluent
import Foundation

public protocol TroubleshootingGuideRepositoryProtocol: Sendable {
    func add(
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
    ) async throws
    
    func get(knowledgeId: UUID) async throws -> TroubleshootingGuideModel?
    func getByCategory(_ category: String) async throws -> [TroubleshootingGuideModel]
    func getBySeverity(_ severity: String) async throws -> [TroubleshootingGuideModel]
    func search(query: String) async throws -> [TroubleshootingGuideModel]
    func update(
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
    ) async throws -> Bool
    func delete(knowledgeId: UUID) async throws -> Bool
    func listCategories() async throws -> [String]
    func listSeverities() async throws -> [String]
}
