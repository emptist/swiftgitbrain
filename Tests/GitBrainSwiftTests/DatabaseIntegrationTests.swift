import Testing
@testable import GitBrainSwift
import Foundation

@Suite("Database Integration Tests")
struct DatabaseIntegrationTests {
    private func getConfig() -> DatabaseConfig {
        return DatabaseConfig(
            host: "localhost",
            port: 5432,
            database: "gitbrain_test",
            username: "jk",
            password: ""
        )
    }
    
    @Test("DatabaseManager initialization")
    func testDatabaseManagerInitialization() async throws {
        let config = getConfig()
        let dbManager = DatabaseManager(config: config)
        
        do {
            _ = try await dbManager.initialize()
            try await dbManager.close()
        } catch {
            try? await dbManager.close()
            #expect(Bool(false), "Database initialization failed: \(error)")
        }
    }
    
    @Test("Knowledge repository operations")
    func testKnowledgeRepositoryOperations() async throws {
        let config = getConfig()
        let dbManager = DatabaseManager(config: config)
        
        do {
            let kbRepo = try await dbManager.createKnowledgeRepository()
            
            let testValue = SendableContent(["test": "data"])
            let testMetadata = SendableContent(["source": "unit_test"])
            let testTimestamp = Date()
            
            try await kbRepo.add(
                category: "test",
                key: "test_key",
                value: testValue,
                metadata: testMetadata,
                timestamp: testTimestamp
            )
            
            let retrieved = try await kbRepo.get(category: "test", key: "test_key")
            #expect(retrieved != nil)
            #expect(retrieved?.value.toAnyDict() != nil)
            #expect(retrieved?.metadata.toAnyDict() != nil)
            
            let categories = try await kbRepo.listCategories()
            #expect(categories.contains("test"))
            
            let keys = try await kbRepo.listKeys(category: "test")
            #expect(keys.contains("test_key"))
            
            _ = try await kbRepo.delete(category: "test", key: "test_key")
            
            let deleted = try await kbRepo.get(category: "test", key: "test_key")
            #expect(deleted == nil)
            
            try await dbManager.close()
        } catch {
            try? await dbManager.close()
            throw error
        }
    }
    
    @Test("Brain state repository operations")
    func testBrainStateRepositoryOperations() async throws {
        let config = getConfig()
        let dbManager = DatabaseManager(config: config)
        
        do {
            let bsmRepo = try await dbManager.createBrainStateRepository()
            
            let testState = SendableContent(["status": "testing", "progress": 50])
            let testTimestamp = Date()
            
            try await bsmRepo.save(
                aiName: "test_ai",
                role: .creator,
                state: testState,
                timestamp: testTimestamp
            )
            
            let retrieved = try await bsmRepo.load(aiName: "test_ai")
            #expect(retrieved != nil)
            #expect(retrieved?.state?.toAnyDict() != nil)
            
            let updatedState = SendableContent(["status": "completed", "progress": 100])
            try await bsmRepo.save(
                aiName: "test_ai",
                role: .creator,
                state: updatedState,
                timestamp: Date()
            )
            
            let updated = try await bsmRepo.load(aiName: "test_ai")
            #expect(updated?.state?.toAnyDict() != nil)
            
            _ = try await bsmRepo.delete(aiName: "test_ai")
            
            let deleted = try await bsmRepo.load(aiName: "test_ai")
            #expect(deleted == nil)
            
            try await dbManager.close()
        } catch {
            try? await dbManager.close()
            throw error
        }
    }
    
    @Test("Knowledge search functionality")
    func testKnowledgeSearch() async throws {
        let config = getConfig()
        let dbManager = DatabaseManager(config: config)
        
        do {
            let kbRepo = try await dbManager.createKnowledgeRepository()
            
            try await kbRepo.delete(category: "search_test", key: "item1")
            try await kbRepo.delete(category: "search_test", key: "item2")
            
            try await kbRepo.add(
                category: "search_test",
                key: "item1",
                value: SendableContent(["content": "This is a test item with UNIQUEWORD"]),
                metadata: SendableContent(["tag": "test"]),
                timestamp: Date()
            )
            
            try await kbRepo.add(
                category: "search_test",
                key: "item2",
                value: SendableContent(["content": "Another item without the special word"]),
                metadata: SendableContent(["tag": "other"]),
                timestamp: Date()
            )
            
            let results = try await kbRepo.search(category: "search_test", query: "UNIQUEWORD")
            #expect(results.count == 1)
            #expect(results[0].value.toAnyDict()["content"] as? String == "This is a test item with UNIQUEWORD")
            
            try await dbManager.close()
        } catch {
            try? await dbManager.close()
            throw error
        }
    }
}