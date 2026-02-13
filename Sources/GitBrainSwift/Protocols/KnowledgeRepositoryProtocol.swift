import Foundation

public protocol KnowledgeRepositoryProtocol: Sendable {
    func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws
    func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)?
    func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool
    func delete(category: String, key: String) async throws -> Bool
    func listCategories() async throws -> [String]
    func listKeys(category: String) async throws -> [String]
    func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)]
}
