import Testing
@testable import GitBrainSwift
import Foundation

@Suite("Data Migration Tests")
struct DataMigrationTests {
    
    @Test("Migrate knowledge base from mock to repository")
    func migrateKnowledgeBase() async throws {
        let mockRepo = MockKnowledgeRepository()
        let targetRepo = MockKnowledgeRepository()
        
        let testValue = SendableContent(["test": "data"])
        let testMetadata = SendableContent(["source": "migration_test"])
        
        try await mockRepo.add(
            category: "test_category",
            key: "test_key",
            value: testValue,
            metadata: testMetadata,
            timestamp: Date()
        )
        
        let _ = DataMigration()
        
        let categories = try await mockRepo.listCategories()
        for category in categories {
            let keys = try await mockRepo.listKeys(category: category)
            for key in keys {
                if let item = try await mockRepo.get(category: category, key: key) {
                    try await targetRepo.add(
                        category: category,
                        key: key,
                        value: item.value,
                        metadata: item.metadata,
                        timestamp: item.timestamp
                    )
                }
            }
        }
        
        let targetCategories = try await targetRepo.listCategories()
        #expect(targetCategories.count == 1)
        #expect(targetCategories.contains("test_category"))
        
        let targetKeys = try await targetRepo.listKeys(category: "test_category")
        #expect(targetKeys.count == 1)
        #expect(targetKeys.contains("test_key"))
    }
    
    @Test("Migrate brain states from mock to repository")
    func migrateBrainStates() async throws {
        let mockRepo = MockBrainStateRepository()
        let targetRepo = MockBrainStateRepository()
        
        let testState = SendableContent(["status": "migrating", "progress": 75])
        
        try await mockRepo.save(
            aiName: "test_ai",
            role: .coder,
            state: testState,
            timestamp: Date()
        )
        
        let _ = DataMigration()
        
        let aiNames = try await mockRepo.list()
        for aiName in aiNames {
            if let brainState = try await mockRepo.load(aiName: aiName), let state = brainState.state {
                try await targetRepo.save(
                    aiName: aiName,
                    role: brainState.role,
                    state: state,
                    timestamp: brainState.timestamp
                )
            }
        }
        
        let targetNames = try await targetRepo.list()
        #expect(targetNames.count == 1)
        #expect(targetNames.contains("test_ai"))
    }
    
    @Test("Validate migration report")
    func validateMigrationReport() async throws {
        let kbRepo = MockKnowledgeRepository()
        let bsmRepo = MockBrainStateRepository()
        
        try await kbRepo.add(
            category: "cat1",
            key: "key1",
            value: SendableContent(["data": "value1"]),
            metadata: SendableContent(["timestamp": Date()]),
            timestamp: Date()
        )
        
        try await kbRepo.add(
            category: "cat1",
            key: "key2",
            value: SendableContent(["data": "value2"]),
            metadata: SendableContent(["timestamp": Date()]),
            timestamp: Date()
        )
        
        try await kbRepo.add(
            category: "cat2",
            key: "key3",
            value: SendableContent(["data": "value3"]),
            metadata: SendableContent(["timestamp": Date()]),
            timestamp: Date()
        )
        
        try await bsmRepo.save(
            aiName: "ai1",
            role: .coder,
            state: SendableContent(["status": "active"]),
            timestamp: Date()
        )
        
        try await bsmRepo.save(
            aiName: "ai2",
            role: .overseer,
            state: SendableContent(["status": "idle"]),
            timestamp: Date()
        )
        
        let migration = DataMigration()
        let report = try await migration.validateMigration(knowledgeRepo: kbRepo, brainStateRepo: bsmRepo)
        
        #expect(report.knowledgeCategories == 2)
        #expect(report.knowledgeItems == 3)
        #expect(report.brainStates == 2)
        #expect(report.totalItems == 5)
    }
    
    @Test("Migration error handling")
    func migrationErrorHandling() {
        let error = MigrationError.partialFailure(totalItems: 10, failedItems: 2)
        #expect(error.localizedDescription == "Migration partially failed: 2/10 items failed")
        
        let sourceNotFound = MigrationError.sourceNotFound(URL(fileURLWithPath: "/nonexistent"))
        #expect(sourceNotFound.localizedDescription.contains("Source not found"))
        
        let validationFailed = MigrationError.validationFailed("Missing data")
        #expect(validationFailed.localizedDescription.contains("Validation failed"))
    }
    
    @Test("Migration report description")
    func migrationReportDescription() {
        var report = MigrationReport()
        report.knowledgeCategories = 5
        report.knowledgeItems = 20
        report.brainStates = 3
        
        let description = report.description
        #expect(description.contains("Knowledge Categories: 5"))
        #expect(description.contains("Knowledge Items: 20"))
        #expect(description.contains("Brain States: 3"))
        #expect(description.contains("Total Items: 23"))
    }
}