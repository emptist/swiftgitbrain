import Testing
@testable import GitBrainSwift
import Foundation

actor KnowledgeRepositoryProtocolMockKnowledgeRepository: KnowledgeRepositoryProtocol {
    private var storage: [String: [String: (value: SendableContent, metadata: SendableContent, timestamp: Date)]] = [:]
    
    func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws {
        if storage[category] == nil {
            storage[category] = [:]
        }
        storage[category]?[key] = (value, metadata, timestamp)
    }
    
    func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)? {
        return storage[category]?[key]
    }
    
    func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool {
        guard storage[category]?[key] != nil else {
            return false
        }
        storage[category]?[key] = (value, metadata, timestamp)
        return true
    }
    
    func delete(category: String, key: String) async throws -> Bool {
        guard storage[category]?[key] != nil else {
            return false
        }
        storage[category]?.removeValue(forKey: key)
        return true
    }
    
    func listCategories() async throws -> [String] {
        return Array(storage.keys).sorted()
    }
    
    func listKeys(category: String) async throws -> [String] {
        return Array(storage[category]?.keys.sorted() ?? [])
    }
    
    func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)] {
        guard let items = storage[category] else {
            return []
        }
        
        let results = items.filter { key, item in
            let valueStr = String(data: try! JSONSerialization.data(withJSONObject: item.value.toAnyDict()), encoding: .utf8) ?? ""
            return valueStr.localizedCaseInsensitiveContains(query)
        }
        
        return results.map { _, item in (item.value, item.metadata) }
    }
}

struct KnowledgeRepositoryProtocolTests {
    @Test("KnowledgeRepositoryProtocol add and get")
    func testAddAndGet() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "test", key: "item1", value: value, metadata: metadata, timestamp: timestamp)
        
        let retrieved = try await repository.get(category: "test", key: "item1")
        #expect(retrieved != nil)
        let retrievedValue = retrieved?.value.toAnyDict()
        let expectedValue = value.toAnyDict()
        #expect(retrievedValue?.keys.sorted() == expectedValue.keys.sorted())
        #expect(retrievedValue?.values.count == expectedValue.values.count)
    }
    
    @Test("KnowledgeRepositoryProtocol update existing")
    func testUpdateExisting() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value1 = SendableContent(["key": "value1"])
        let value2 = SendableContent(["key": "value2"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "test", key: "item1", value: value1, metadata: metadata, timestamp: timestamp)
        
        let updated = try await repository.update(category: "test", key: "item1", value: value2, metadata: metadata, timestamp: timestamp)
        #expect(updated == true)
        
        let retrieved = try await repository.get(category: "test", key: "item1")
        #expect(retrieved != nil)
        let retrievedValue = retrieved?.value.toAnyDict()
        let expectedValue = value2.toAnyDict()
        #expect(retrievedValue?.keys.sorted() == expectedValue.keys.sorted())
        #expect(retrievedValue?.values.count == expectedValue.values.count)
    }
    
    @Test("KnowledgeRepositoryProtocol update non-existent")
    func testUpdateNonExistent() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        let updated = try await repository.update(category: "test", key: "item1", value: value, metadata: metadata, timestamp: timestamp)
        #expect(updated == false)
    }
    
    @Test("KnowledgeRepositoryProtocol delete existing")
    func testDeleteExisting() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "test", key: "item1", value: value, metadata: metadata, timestamp: timestamp)
        
        let deleted = try await repository.delete(category: "test", key: "item1")
        #expect(deleted == true)
        
        let retrieved = try await repository.get(category: "test", key: "item1")
        #expect(retrieved == nil)
    }
    
    @Test("KnowledgeRepositoryProtocol delete non-existent")
    func testDeleteNonExistent() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        
        let deleted = try await repository.delete(category: "test", key: "item1")
        #expect(deleted == false)
    }
    
    @Test("KnowledgeRepositoryProtocol list categories")
    func testListCategories() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "category2", key: "item1", value: value, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "category1", key: "item2", value: value, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "category3", key: "item3", value: value, metadata: metadata, timestamp: timestamp)
        
        let categories = try await repository.listCategories()
        #expect(categories == ["category1", "category2", "category3"])
    }
    
    @Test("KnowledgeRepositoryProtocol list keys")
    func testListKeys() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "test", key: "key3", value: value, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "test", key: "key1", value: value, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "test", key: "key2", value: value, metadata: metadata, timestamp: timestamp)
        
        let keys = try await repository.listKeys(category: "test")
        #expect(keys == ["key1", "key2", "key3"])
    }
    
    @Test("KnowledgeRepositoryProtocol search")
    func testSearch() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let value1 = SendableContent(["name": "apple", "type": "fruit"])
        let value2 = SendableContent(["name": "banana", "type": "fruit"])
        let value3 = SendableContent(["name": "carrot", "type": "vegetable"])
        let metadata = SendableContent(["source": "test"])
        let timestamp = Date()
        
        try await repository.add(category: "test", key: "item1", value: value1, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "test", key: "item2", value: value2, metadata: metadata, timestamp: timestamp)
        try await repository.add(category: "test", key: "item3", value: value3, metadata: metadata, timestamp: timestamp)
        
        let results = try await repository.search(category: "test", query: "apple")
        #expect(results.count == 1)
        #expect(results[0].value.toAnyDict()["name"] as? String == "apple")
    }
}