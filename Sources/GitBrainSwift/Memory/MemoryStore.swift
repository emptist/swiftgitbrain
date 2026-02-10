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
    
    private actor Storage {
        private var storage: [String: StoredValue] = [:]
        
        func set(_ key: String, value: StoredValue) {
            storage[key] = value
        }
        
        func get(_ key: String) -> StoredValue? {
            return storage[key]
        }
        
        func delete(_ key: String) -> Bool {
            return storage.removeValue(forKey: key) != nil
        }
        
        func exists(_ key: String) -> Bool {
            return storage[key] != nil
        }
        
        func getTimestamp(_ key: String) -> Date? {
            return storage[key]?.timestamp
        }
        
        func clear() {
            storage.removeAll()
        }
        
        func listKeys() -> [String] {
            return Array(storage.keys).sorted()
        }
        
        func count() -> Int {
            return storage.count
        }
    }
    
    private let storage = Storage()
    
    public init() {}
    
    public func set(_ key: String, value: SendableContent) async {
        storage[key] = StoredValue(value: value, timestamp: Date())
    }
    
    public func get(_ key: String, defaultValue: SendableContent? = nil) async -> SendableContent? {
        return storage[key]?.value ?? defaultValue
    }
    
    public func delete(_ key: String) async -> Bool {
        return await storage.delete(key)
    }
    
    public func exists(_ key: String) async -> Bool {
        return await storage.exists(key)
    }
    
    public func getTimestamp(_ key: String) async -> Date? {
        return await storage.getTimestamp(key)
    }
    
    public func clear() async {
        await storage.clear()
    }
    
    public func listKeys() async -> [String] {
        return await storage.listKeys()
    }
    
    public func count() async -> Int {
        return await storage.count()
    }
}
