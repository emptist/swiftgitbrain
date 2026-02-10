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

public actor MemoryStore: MemoryStoreProtocol {
    private struct StoredValue {
        let value: SendableContent
        let timestamp: Date
    }
    
    private var storage: [String: StoredValue] = [:]
    
    public init() {}
    
    public func set(_ key: String, value: SendableContent) async {
        storage[key] = StoredValue(value: value, timestamp: Date())
    }
    
    public func get(_ key: String, defaultValue: SendableContent? = nil) async -> SendableContent? {
        return storage[key]?.value ?? defaultValue
    }
    
    public func delete(_ key: String) async -> Bool {
        return storage.removeValue(forKey: key) != nil
    }
    
    public func exists(_ key: String) async -> Bool {
        return storage[key] != nil
    }
    
    public func getTimestamp(_ key: String) async -> Date? {
        return storage[key]?.timestamp
    }
    
    public func clear() async {
        storage.removeAll()
    }
    
    public func listKeys() async -> [String] {
        return Array(storage.keys).sorted()
    }
    
    public func count() async -> Int {
        return storage.count
    }
}
