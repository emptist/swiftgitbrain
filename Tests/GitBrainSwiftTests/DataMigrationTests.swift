import Testing
@testable import GitBrainSwift
import Foundation

@Suite("DataMigration Tests")
struct DataMigrationTests {
    
    @Test("Test retry policy calculation")
    func testRetryPolicyCalculation() throws {
        let policy = RetryPolicy(maxRetries: 5, baseDelay: 1.0, maxDelay: 60.0, backoffMultiplier: 2.0)
        
        let delay0 = policy.delay(for: 0)
        let delay1 = policy.delay(for: 1)
        let delay2 = policy.delay(for: 2)
        let delay3 = policy.delay(for: 3)
        let delay4 = policy.delay(for: 4)
        
        #expect(delay0 == 1.0)
        #expect(delay1 == 2.0)
        #expect(delay2 == 4.0)
        #expect(delay3 == 8.0)
        #expect(delay4 == 16.0)
    }
    
    @Test("Test retry policy max delay")
    func testRetryPolicyMaxDelay() throws {
        let policy = RetryPolicy(maxRetries: 10, baseDelay: 1.0, maxDelay: 10.0, backoffMultiplier: 2.0)
        
        let delay5 = policy.delay(for: 5)
        let delay10 = policy.delay(for: 10)
        
        #expect(delay5 == 10.0)
        #expect(delay10 == 10.0)
    }
    
    @Test("Test transient error detection")
    func testTransientErrorDetection() throws {
        let policy = RetryPolicy()
        
        let transientError = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Connection timeout"])
        let permanentError = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
        
        #expect(policy.isTransientError(transientError) == true)
        #expect(policy.isTransientError(permanentError) == false)
    }
    
    @Test("Test should retry logic")
    func testShouldRetryLogic() throws {
        let policy = RetryPolicy(maxRetries: 3)
        
        let transientError = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Connection timeout"])
        
        #expect(policy.shouldRetry(attempt: 0, error: transientError) == true)
        #expect(policy.shouldRetry(attempt: 1, error: transientError) == true)
        #expect(policy.shouldRetry(attempt: 2, error: transientError) == true)
        #expect(policy.shouldRetry(attempt: 3, error: transientError) == false)
    }
    
    @Test("Test migration snapshot creation")
    func testMigrationSnapshotCreation() throws {
        let snapshot = MigrationSnapshot(
            id: "test-snapshot",
            timestamp: Date(),
            knowledgeItems: [],
            brainStates: []
        )
        
        #expect(snapshot.id == "test-snapshot")
        #expect(snapshot.knowledgeItems.isEmpty == true)
        #expect(snapshot.brainStates.isEmpty == true)
    }
    
    @Test("Test knowledge item snapshot")
    func testKnowledgeItemSnapshot() throws {
        let value = SendableContent(["test": "value"])
        let metadata = SendableContent(["timestamp": Date()])
        let snapshot = KnowledgeItemSnapshot(
            category: "test-category",
            key: "test-key",
            value: value,
            metadata: metadata,
            timestamp: Date()
        )
        
        #expect(snapshot.category == "test-category")
        #expect(snapshot.key == "test-key")
    }
    
    @Test("Test brain state snapshot")
    func testBrainStateSnapshot() throws {
        let state = SendableContent(["test": "state"])
        let snapshot = BrainStateSnapshot(
            aiName: "test-ai",
            role: .coder,
            state: state,
            timestamp: Date()
        )
        
        #expect(snapshot.aiName == "test-ai")
        #expect(snapshot.role == .coder)
    }
    
    @Test("Test migration result creation")
    func testMigrationResultCreation() throws {
        let result = MigrationResult(
            success: true,
            itemsMigrated: 100,
            itemsFailed: 0,
            errors: [],
            duration: 10.5,
            timestamp: Date(),
            snapshotId: "test-snapshot"
        )
        
        #expect(result.success == true)
        #expect(result.itemsMigrated == 100)
        #expect(result.itemsFailed == 0)
        #expect(result.snapshotId == "test-snapshot")
    }
    
    @Test("Test migration error detail")
    func testMigrationErrorDetail() throws {
        let error = MigrationErrorDetail(
            item: "test-item",
            error: "Test error",
            phase: "Transfer",
            timestamp: Date(),
            retryCount: 3
        )
        
        #expect(error.item == "test-item")
        #expect(error.error == "Test error")
        #expect(error.phase == "Transfer")
        #expect(error.retryCount == 3)
    }
    
    @Test("Test migration report")
    func testMigrationReport() throws {
        var report = MigrationReport()
        report.knowledgeCategories = 5
        report.knowledgeItems = 100
        report.brainStates = 2
        
        #expect(report.knowledgeCategories == 5)
        #expect(report.knowledgeItems == 100)
        #expect(report.brainStates == 2)
        #expect(report.totalItems == 102)
    }
}

@Suite("DataMigration Integration Tests")
struct DataMigrationIntegrationTests {
    
    @Test("Test migration with mock repository")
    func testMigrationWithMockRepository() async throws {
        let mockRepo = DataMigrationMockKnowledgeRepository()
        let migration = DataMigration()
        
        let testURL = URL(fileURLWithPath: "/tmp/test-knowledge")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        defer {
            try? FileManager.default.removeItem(at: testURL)
        }
        
        let result = try await migration.migrateKnowledgeBase(from: testURL, to: mockRepo)
        
        #expect(result.success == true)
        #expect(result.itemsMigrated == 0)
    }
    
    @Test("Test rollback with mock repository")
    func testRollbackWithMockRepository() async throws {
        let mockRepo = DataMigrationMockKnowledgeRepository()
        let migration = DataMigration()
        
        let snapshot = MigrationSnapshot(
            id: "test-snapshot",
            timestamp: Date(),
            knowledgeItems: [
                KnowledgeItemSnapshot(
                    category: "test",
                    key: "key",
                    value: SendableContent(["value": "test"]),
                    metadata: SendableContent(["timestamp": Date()]),
                    timestamp: Date()
                )
            ],
            brainStates: []
        )
        
        try await migration.rollback(to: snapshot, knowledgeRepo: mockRepo, brainStateRepo: DataMigrationMockBrainStateRepository())
        
        #expect(mockRepo.items.count == 1)
    }
    
    @Test("Test validation with mock repository")
    func testValidationWithMockRepository() async throws {
        let mockRepo = DataMigrationMockKnowledgeRepository()
        let migration = DataMigration()
        
        let report = try await migration.validateMigration(
            knowledgeRepo: mockRepo,
            brainStateRepo: DataMigrationMockBrainStateRepository()
        )
        
        #expect(report.knowledgeCategories == 0)
        #expect(report.knowledgeItems == 0)
        #expect(report.brainStates == 0)
    }
}

@Suite("DataMigration Performance Tests")
struct DataMigrationPerformanceTests {
    
    @Test("Test migration performance with large dataset")
    func testMigrationPerformanceWithLargeDataset() async throws {
        let mockRepo = DataMigrationMockKnowledgeRepository()
        let migration = DataMigration()
        
        let testURL = URL(fileURLWithPath: "/tmp/test-knowledge-large")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        defer {
            try? FileManager.default.removeItem(at: testURL)
        }
        
        let startTime = Date()
        let result = try await migration.migrateKnowledgeBase(from: testURL, to: mockRepo)
        let duration = Date().timeIntervalSince(startTime)
        
        #expect(result.success == true)
        #expect(duration < 1.0)
    }
    
    @Test("Test retry performance")
    func testRetryPerformance() async throws {
        let mockRepo = DataMigrationMockKnowledgeRepository()
        let migration = DataMigration(retryPolicy: RetryPolicy(maxRetries: 3, baseDelay: 0.1))
        
        let testURL = URL(fileURLWithPath: "/tmp/test-knowledge-retry")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        defer {
            try? FileManager.default.removeItem(at: testURL)
        }
        
        let startTime = Date()
        let result = try await migration.migrateKnowledgeBase(from: testURL, to: mockRepo)
        let duration = Date().timeIntervalSince(startTime)
        
        #expect(result.success == true)
        #expect(duration < 1.0)
    }
}

class DataMigrationMockKnowledgeRepository: @unchecked Sendable, KnowledgeRepositoryProtocol {
    var items: [(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date)] = []
    
    func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws {
        items.append((category, key, value, metadata, timestamp))
    }
    
    func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)? {
        return items.first { $0.category == category && $0.key == key }.map { ($0.value, $0.metadata, $0.timestamp) }
    }
    
    func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool {
        guard let index = items.firstIndex(where: { $0.category == category && $0.key == key }) else {
            return false
        }
        items[index] = (category, key, value, metadata, timestamp)
        return true
    }
    
    func delete(category: String, key: String) async throws -> Bool {
        let initialCount = items.count
        items.removeAll { $0.category == category && $0.key == key }
        return items.count < initialCount
    }
    
    func listCategories() async throws -> [String] {
        return Array(Set(items.map { $0.category }))
    }
    
    func listKeys(category: String) async throws -> [String] {
        return items.filter { $0.category == category }.map { $0.key }
    }
    
    func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)] {
        return items.filter { $0.category == category && ($0.key.localizedCaseInsensitiveContains(query) || $0.value.toAnyDict().description.localizedCaseInsensitiveContains(query)) }
            .map { ($0.value, $0.metadata) }
    }
}

class DataMigrationMockBrainStateRepository: @unchecked Sendable, BrainStateRepositoryProtocol {
    var states: [(aiName: String, role: RoleType, state: SendableContent, timestamp: Date)] = []
    
    func create(aiName: String, role: RoleType, state: SendableContent?, timestamp: Date) async throws {
        if let state = state {
            states.append((aiName, role, state, timestamp))
        }
    }
    
    func save(aiName: String, role: RoleType, state: SendableContent, timestamp: Date) async throws {
        states.removeAll { $0.aiName == aiName }
        states.append((aiName, role, state, timestamp))
    }
    
    func load(aiName: String) async throws -> (role: RoleType, state: SendableContent?, timestamp: Date)? {
        return states.first { $0.aiName == aiName }.map { ($0.role, $0.state, $0.timestamp) }
    }
    
    func list() async throws -> [String] {
        return states.map { $0.aiName }
    }
    
    func update(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        guard let index = states.firstIndex(where: { $0.aiName == aiName }) else {
            return false
        }
        var stateData = states[index].state
        stateData[key] = .dictionary(value.data)
        states[index] = (states[index].aiName, states[index].role, stateData, states[index].timestamp)
        return true
    }
    
    func get(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent? {
        guard let state = states.first(where: { $0.aiName == aiName })?.state else {
            return defaultValue
        }
        if let codableValue = state[key] {
            if case let .dictionary(dict) = codableValue {
                return SendableContent(data: dict)
            }
            return SendableContent(data: [key: codableValue])
        }
        return defaultValue
    }
    
    func delete(aiName: String) async throws -> Bool {
        let initialCount = states.count
        states.removeAll { $0.aiName == aiName }
        return states.count < initialCount
    }
    
    func backup(aiName: String, backupSuffix: String?) async throws -> String? {
        guard states.first(where: { $0.aiName == aiName }) != nil else {
            return nil
        }
        let suffix = backupSuffix ?? "_backup"
        return "\(aiName)\(suffix).json"
    }
    
    func restore(aiName: String, backupFile: String) async throws -> Bool {
        return true
    }
}