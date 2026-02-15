import Foundation

public protocol BrainStateRepositoryProtocol: Sendable {
    func create(id: BrainStateID, aiName: String, role: RoleType, state: SendableContent?, timestamp: Date) async throws
    func load(aiName: String) async throws -> (id: BrainStateID, role: RoleType, state: SendableContent?, timestamp: Date)?
    func save(aiName: String, role: RoleType, state: SendableContent, timestamp: Date) async throws
    func update(aiName: String, key: String, value: SendableContent) async throws -> Bool
    func get(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent?
    func delete(aiName: String) async throws -> Bool
    func list() async throws -> [String]
    func backup(aiName: String, backupSuffix: String?) async throws -> String?
    func restore(aiName: String, backupFile: String) async throws -> Bool
}
