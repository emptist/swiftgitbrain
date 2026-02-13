import Testing
@testable import GitBrainSwift
import Foundation

struct KnowledgeBaseTests {
    @Test("KnowledgeBase add and get knowledge")
    func testAddAndGetKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        let metadata = SendableContent(["source": "test"])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value, metadata: metadata)
        
        let retrieved = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(retrieved != nil)
    }
    
    @Test("KnowledgeBase update knowledge")
    func testUpdateKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value1 = SendableContent(["key": "value1"])
        let value2 = SendableContent(["key": "value2"])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value1)
        
        let updated = try await knowledgeBase.updateKnowledge(category: "test", key: "item1", value: value2)
        #expect(updated == true)
        
        let retrieved = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(retrieved != nil)
    }
    
    @Test("KnowledgeBase update non-existent knowledge")
    func testUpdateNonExistentKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        
        let updated = try await knowledgeBase.updateKnowledge(category: "test", key: "nonexistent", value: value)
        #expect(updated == false)
    }
    
    @Test("KnowledgeBase delete knowledge")
    func testDeleteKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value)
        
        let deleted = try await knowledgeBase.deleteKnowledge(category: "test", key: "item1")
        #expect(deleted == true)
        
        let retrieved = try await knowledgeBase.getKnowledge(category: "test", key: "item1")
        #expect(retrieved == nil)
    }
    
    @Test("KnowledgeBase delete non-existent knowledge")
    func testDeleteNonExistentKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        
        let deleted = try await knowledgeBase.deleteKnowledge(category: "test", key: "nonexistent")
        #expect(deleted == false)
    }
    
    @Test("KnowledgeBase list categories")
    func testListCategories() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        
        try await knowledgeBase.addKnowledge(category: "category1", key: "item1", value: value)
        try await knowledgeBase.addKnowledge(category: "category2", key: "item2", value: value)
        try await knowledgeBase.addKnowledge(category: "category1", key: "item3", value: value)
        
        let categories = try await knowledgeBase.listCategories()
        #expect(categories.count == 2)
        #expect(categories.contains("category1"))
        #expect(categories.contains("category2"))
    }
    
    @Test("KnowledgeBase list keys")
    func testListKeys() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        let value = SendableContent(["key": "value"])
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: value)
        try await knowledgeBase.addKnowledge(category: "test", key: "item2", value: value)
        try await knowledgeBase.addKnowledge(category: "test", key: "item3", value: value)
        
        let keys = try await knowledgeBase.listKeys(category: "test")
        #expect(keys.count == 3)
        #expect(keys.contains("item1"))
        #expect(keys.contains("item2"))
        #expect(keys.contains("item3"))
    }
    
    @Test("KnowledgeBase search knowledge")
    func testSearchKnowledge() async throws {
        let repository = KnowledgeRepositoryProtocolMockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: repository)
        
        try await knowledgeBase.addKnowledge(category: "test", key: "item1", value: SendableContent(["content": "This is a test"]))
        try await knowledgeBase.addKnowledge(category: "test", key: "item2", value: SendableContent(["content": "Another item"]))
        
        let results = try await knowledgeBase.searchKnowledge(category: "test", query: "test")
        #expect(results.count == 1)
        #expect(results[0].toAnyDict()["content"] as? String == "This is a test")
    }
}