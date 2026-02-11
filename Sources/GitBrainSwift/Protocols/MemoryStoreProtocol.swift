import Foundation

public protocol MemoryStoreProtocol: Sendable {
    func set(_ key: String, value: SendableContent) async
    func get(_ key: String, defaultValue: SendableContent?) async -> SendableContent?
    func delete(_ key: String) async -> Bool
    func exists(_ key: String) async -> Bool
    func getTimestamp(_ key: String) async -> Date?
    func clear() async
    func listKeys() async -> [String]
}
