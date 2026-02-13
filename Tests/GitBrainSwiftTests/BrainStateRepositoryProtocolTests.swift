import Testing
@testable import GitBrainSwift
import Foundation

actor MockBrainStateRepository: BrainStateRepositoryProtocol {
    private var storage: [String: (role: RoleType, state: SendableContent?, timestamp: Date)] = [:]
    
    func create(aiName: String, role: RoleType, state: SendableContent?, timestamp: Date) async throws {
        storage[aiName] = (role, state, timestamp)
    }
    
    func load(aiName: String) async throws -> (role: RoleType, state: SendableContent?, timestamp: Date)? {
        return storage[aiName]
    }
    
    func save(aiName: String, role: RoleType, state: SendableContent, timestamp: Date) async throws {
        storage[aiName] = (role, state, timestamp)
    }
    
    func update(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        guard let current = storage[aiName] else {
            return false
        }
        
        var stateDict = current.state?.toAnyDict() as? [String: Any] ?? [:]
        stateDict[key] = value.toAnyDict()
        
        storage[aiName] = (current.role, SendableContent(stateDict), current.timestamp)
        return true
    }
    
    func get(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent? {
        guard let current = storage[aiName] else {
            return defaultValue
        }
        
        guard let stateDict = current.state?.toAnyDict() as? [String: Any] else {
            return defaultValue
        }
        
        guard let value = stateDict[key] else {
            return defaultValue
        }
        
        if let dictValue = value as? [String: Any] {
            return SendableContent(dictValue)
        }
        
        return defaultValue
    }
    
    func delete(aiName: String) async throws -> Bool {
        guard storage[aiName] != nil else {
            return false
        }
        storage.removeValue(forKey: aiName)
        return true
    }
    
    func list() async throws -> [String] {
        return Array(storage.keys).sorted()
    }
    
    func backup(aiName: String, backupSuffix: String?) async throws -> String? {
        guard storage[aiName] != nil else {
            return nil
        }
        let suffix = backupSuffix ?? "_backup_\(Date().timeIntervalSince1970)"
        return "\(aiName)\(suffix)"
    }
    
    func restore(aiName: String, backupFile: String) async throws -> Bool {
        return true
    }
}

struct BrainStateRepositoryProtocolTests {
    @Test("BrainStateRepositoryProtocol create and load")
    func testCreateAndLoad() async throws {
        let repository = MockBrainStateRepository()
        let state = SendableContent(["key": "value"])
        let timestamp = Date()
        
        try await repository.create(aiName: "testAI", role: .coder, state: state, timestamp: timestamp)
        
        let loaded = try await repository.load(aiName: "testAI")
        #expect(loaded != nil)
        #expect(loaded?.role == .coder)
    }
    
    @Test("BrainStateRepositoryProtocol save and load")
    func testSaveAndLoad() async throws {
        let repository = MockBrainStateRepository()
        let state = SendableContent(["key": "value"])
        let timestamp = Date()
        
        try await repository.save(aiName: "testAI", role: .coder, state: state, timestamp: timestamp)
        
        let loaded = try await repository.load(aiName: "testAI")
        #expect(loaded != nil)
        #expect(loaded?.role == .coder)
    }
    
    @Test("BrainStateRepositoryProtocol update existing")
    func testUpdateExisting() async throws {
        let repository = MockBrainStateRepository()
        let state1 = SendableContent(["key1": "value1"])
        let state2 = SendableContent(["key2": "value2"])
        let timestamp = Date()
        
        try await repository.create(aiName: "testAI", role: .coder, state: state1, timestamp: timestamp)
        
        let updated = try await repository.update(aiName: "testAI", key: "newKey", value: SendableContent(["newValue": "data"]))
        #expect(updated == true)
        
        let retrieved = try await repository.get(aiName: "testAI", key: "newKey", defaultValue: nil)
        #expect(retrieved != nil)
    }
    
    @Test("BrainStateRepositoryProtocol update non-existent")
    func testUpdateNonExistent() async throws {
        let repository = MockBrainStateRepository()
        
        let updated = try await repository.update(aiName: "testAI", key: "key", value: SendableContent(["value": "data"]))
        #expect(updated == false)
    }
    
    @Test("BrainStateRepositoryProtocol get with default")
    func testGetWithDefault() async throws {
        let repository = MockBrainStateRepository()
        
        let retrieved = try await repository.get(aiName: "testAI", key: "key", defaultValue: SendableContent(["default": "value"]))
        #expect(retrieved != nil)
    }
    
    @Test("BrainStateRepositoryProtocol delete existing")
    func testDeleteExisting() async throws {
        let repository = MockBrainStateRepository()
        let state = SendableContent(["key": "value"])
        let timestamp = Date()
        
        try await repository.create(aiName: "testAI", role: .coder, state: state, timestamp: timestamp)
        
        let deleted = try await repository.delete(aiName: "testAI")
        #expect(deleted == true)
        
        let loaded = try await repository.load(aiName: "testAI")
        #expect(loaded == nil)
    }
    
    @Test("BrainStateRepositoryProtocol delete non-existent")
    func testDeleteNonExistent() async throws {
        let repository = MockBrainStateRepository()
        
        let deleted = try await repository.delete(aiName: "testAI")
        #expect(deleted == false)
    }
    
    @Test("BrainStateRepositoryProtocol list")
    func testList() async throws {
        let repository = MockBrainStateRepository()
        let state = SendableContent(["key": "value"])
        let timestamp = Date()
        
        try await repository.create(aiName: "ai2", role: .coder, state: state, timestamp: timestamp)
        try await repository.create(aiName: "ai1", role: .overseer, state: state, timestamp: timestamp)
        try await repository.create(aiName: "ai3", role: .coder, state: state, timestamp: timestamp)
        
        let list = try await repository.list()
        #expect(list == ["ai1", "ai2", "ai3"])
    }
    
    @Test("BrainStateRepositoryProtocol backup")
    func testBackup() async throws {
        let repository = MockBrainStateRepository()
        let state = SendableContent(["key": "value"])
        let timestamp = Date()
        
        try await repository.create(aiName: "testAI", role: .coder, state: state, timestamp: timestamp)
        
        let backup = try await repository.backup(aiName: "testAI", backupSuffix: nil)
        #expect(backup != nil)
        #expect(backup?.hasPrefix("testAI") == true)
    }
}
