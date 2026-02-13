import Testing
@testable import GitBrainSwift
import Foundation

struct IntegrationTests {
    @Test("KnowledgeBase with MockRepository integration")
    func testKnowledgeBaseMockRepositoryIntegration() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value", "number": 42])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value)
        
        let retrieved = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(retrieved != nil)
        #expect(retrieved?.isEmpty == false)
    }
    
    @Test("KnowledgeBase update and delete workflow")
    func testKnowledgeBaseWorkflowIntegration() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value1 = SendableContent(["key": "value1"])
        let value2 = SendableContent(["key": "value2"])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value1)
        
        let updated = try await knowledgeBase.updateKnowledge(category: "test", key: "item1", value: value2)
        #expect(updated == true)
        
        let retrieved = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(retrieved != nil)
        
        let deleted = try await knowledgeBase.deleteKnowledge(category: "test", key: "item1")
        #expect(deleted == true)
        
        let afterDelete = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(afterDelete == nil)
    }
    
    @Test("KnowledgeBase multiple categories integration")
    func testKnowledgeBaseMultipleCategoriesIntegration() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        
        try await knowledgeBase.addKnowledge(category: "cat1", key: "item1", value: value)
        try await knowledgeBase.addKnowledge(category: "cat2", key: "item1", value: value)
        try await knowledgeBase.addKnowledge(category: "cat3", key: "item1", value: value)
        
        let categories = try await knowledgeBase.listCategories()
        
        #expect(categories.count == 3)
        #expect(categories.contains("cat1"))
        #expect(categories.contains("cat2"))
        #expect(categories.contains("cat3"))
    }
    
    @Test("MemoryStore set and get workflow")
    func testMemoryStoreWorkflowIntegration() async throws {
        let memoryStore = MemoryStore()
        
        let value = SendableContent(["key": "value", "number": 42])
        
        await memoryStore.set("test_key", value: value)
        
        let retrieved = await memoryStore.get("test_key")
        
        #expect(retrieved != nil)
        #expect(retrieved?.isEmpty == false)
        
        let exists = await memoryStore.exists("test_key")
        #expect(exists == true)
        
        let deleted = await memoryStore.delete("test_key")
        #expect(deleted == true)
        
        let afterDelete = await memoryStore.exists("test_key")
        #expect(afterDelete == false)
    }
    
    @Test("MemoryStore get with default workflow")
    func testMemoryStoreGetWithDefaultIntegration() async throws {
        let memoryStore = MemoryStore()
        
        let defaultValue = SendableContent(["default": true])
        
        let retrieved = await memoryStore.get("nonexistent", defaultValue: defaultValue)
        
        #expect(retrieved != nil)
        #expect(retrieved?.isEmpty == false)
    }
    
    @Test("MemoryStore list keys workflow")
    func testMemoryStoreListKeysIntegration() async throws {
        let memoryStore = MemoryStore()
        
        let value = SendableContent(["key": "value"])
        
        await memoryStore.set("key1", value: value)
        await memoryStore.set("key2", value: value)
        await memoryStore.set("key3", value: value)
        
        let keys = await memoryStore.listKeys()
        
        #expect(keys.count >= 3)
        #expect(keys.contains("key1"))
        #expect(keys.contains("key2"))
        #expect(keys.contains("key3"))
    }
    
    @Test("MemoryStore clear workflow")
    func testMemoryStoreClearIntegration() async throws {
        let memoryStore = MemoryStore()
        
        let value = SendableContent(["key": "value"])
        
        await memoryStore.set("key1", value: value)
        await memoryStore.set("key2", value: value)
        
        let keysBefore = await memoryStore.listKeys()
        #expect(keysBefore.count == 2)
        
        await memoryStore.clear()
        
        let keysAfter = await memoryStore.listKeys()
        #expect(keysAfter.count == 0)
    }
}