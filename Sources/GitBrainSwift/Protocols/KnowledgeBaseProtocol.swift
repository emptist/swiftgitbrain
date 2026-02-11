import Foundation

public protocol KnowledgeBaseProtocol: Sendable {
    func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent?) async throws
    func getKnowledge(category: String, key: String) async throws -> SendableContent?
    func updateKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent?) async throws -> Bool
    func deleteKnowledge(category: String, key: String) async throws -> Bool
    func listCategories() async throws -> [String]
    func listKeys(category: String) async throws -> [String]
    func searchKnowledge(category: String, query: String) async throws -> [SendableContent]
}
