import Foundation
import Testing
@testable import GitBrainSwift

struct ScoreManagerTests {
    @Test("ScoreManager initialization")
    func testScoreManagerInitialization() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        let scores = try await scoreManager.getAllScores()
        #expect(scores.count == 0)
    }
    
    @Test("ScoreManager get and set")
    func testScoreManagerGetAndSet() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "Creator", score: 10)
        let score = try await scoreManager.getScore(for: "Creator")
        #expect(score == 10)
    }
    
    @Test("ScoreManager increment")
    func testScoreManagerIncrement() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "Creator", score: 0)
        try await scoreManager.incrementScore(for: "Creator")
        let score = try await scoreManager.getScore(for: "Creator")
        #expect(score == 1)
        
        try await scoreManager.incrementScore(for: "Creator", by: 10)
        let newScore = try await scoreManager.getScore(for: "Creator")
        #expect(newScore == 11)
    }
    
    @Test("ScoreManager reset")
    func testScoreManagerReset() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "Creator", score: 100)
        try await scoreManager.setScore(for: "Monitor", score: 50)
        
        try await scoreManager.resetScores()
        
        let score1 = try await scoreManager.getScore(for: "Creator")
        let score2 = try await scoreManager.getScore(for: "Monitor")
        #expect(score1 == 0)
        #expect(score2 == 0)
    }
    
    @Test("ScoreManager get all scores")
    func testScoreManagerGetAllScores() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "Creator", score: 10)
        try await scoreManager.setScore(for: "Monitor", score: 20)
        try await scoreManager.setScore(for: "TestAI", score: 30)
        
        let allScores = try await scoreManager.getAllScores()
        #expect(allScores.count == 3)
        
        let creatorScore = allScores.first { $0.0 == "Creator" }?.1
        let monitorScore = allScores.first { $0.0 == "Monitor" }?.1
        let testScore = allScores.first { $0.0 == "TestAI" }?.1
        
        #expect(creatorScore == 10)
        #expect(monitorScore == 20)
        #expect(testScore == 30)
    }
    
    @Test("Migration from file")
    func testMigrationFromFile() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let scoreFile = tempDir.appendingPathComponent("ai_scores.txt")
        let dbFile = tempDir.appendingPathComponent("scores.db")
        
        let fileContent = """
        Creator Score: 10
        Monitor Score: 20
        TestAI Score: 30
        """
        try fileContent.write(to: scoreFile, atomically: true, encoding: .utf8)
        
        try await ScoreManager.migrateFromFile(filePath: scoreFile.path, to: dbFile.path)
        
        let scoreManager = ScoreManager(dbPath: dbFile.path)
        try await scoreManager.initialize()
        let allScores = try await scoreManager.getAllScores()
        
        #expect(allScores.count == 3)
        
        let creatorScore = allScores.first { $0.0 == "Creator" }?.1
        let monitorScore = allScores.first { $0.0 == "Monitor" }?.1
        let testScore = allScores.first { $0.0 == "TestAI" }?.1
        
        #expect(creatorScore == 10)
        #expect(monitorScore == 20)
        #expect(testScore == 30)
    }
    
    @Test("Migration from empty file")
    func testMigrationFromEmptyFile() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let scoreFile = tempDir.appendingPathComponent("ai_scores.txt")
        let dbFile = tempDir.appendingPathComponent("scores.db")
        
        try "".write(to: scoreFile, atomically: true, encoding: .utf8)
        
        try await ScoreManager.migrateFromFile(filePath: scoreFile.path, to: dbFile.path)
        
        let scoreManager = ScoreManager(dbPath: dbFile.path)
        try await scoreManager.initialize()
        let allScores = try await scoreManager.getAllScores()
        
        #expect(allScores.count == 0)
    }
    
    @Test("Migration from non-existent file")
    func testMigrationFromNonExistentFile() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let scoreFile = tempDir.appendingPathComponent("ai_scores.txt")
        let dbFile = tempDir.appendingPathComponent("scores.db")
        
        try await ScoreManager.migrateFromFile(filePath: scoreFile.path, to: dbFile.path)
        
        let scoreManager = ScoreManager(dbPath: dbFile.path)
        try await scoreManager.initialize()
        let allScores = try await scoreManager.getAllScores()
        
        #expect(allScores.count == 0)
    }
    
    @Test("ScoreManager request score")
    func testRequestScore() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 25,
            qualityJustification: "Task completed successfully with all tests passing"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(requests.count == 1)
        #expect(requests[0].0 > 0)
        #expect(requests[0].1 == "task-001")
        #expect(requests[0].2 == "creator")
        #expect(requests[0].3 == 25)
    }
    
    @Test("ScoreManager award score")
    func testAwardScore() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "creator", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 25,
            qualityJustification: "Task completed successfully with all tests passing"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(requests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: requests[0].0,
            awarder: "monitor",
            awardedScore: 25,
            reason: "Excellent work! All requirements met"
        )
        
        let score = try await scoreManager.getScore(for: "creator")
        #expect(score == 25)
        
        let history = try await scoreManager.getScoreHistory(for: "creator")
        #expect(history.count == 1)
        #expect(history[0].1 == 25)
    }
    
    @Test("ScoreManager get score history")
    func testGetScoreHistory() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "creator", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 10,
            qualityJustification: "Task completed"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        try await scoreManager.awardScore(
            requestId: requests[0].0,
            awarder: "monitor",
            awardedScore: 10,
            reason: "Good work"
        )
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 15,
            qualityJustification: "Another task completed"
        )
        
        let requests2 = try await scoreManager.getPendingScoreRequests(for: "monitor")
        try await scoreManager.awardScore(
            requestId: requests2[0].0,
            awarder: "monitor",
            awardedScore: 15,
            reason: "Excellent work"
        )
        
        let history = try await scoreManager.getScoreHistory(for: "creator")
        #expect(history.count == 2)
        #expect(history[0].1 == 15)
        #expect(history[1].1 == 10)
    }
    
    @Test("ScoreManager get pending score requests")
    func testGetPendingScoreRequests() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 10,
            qualityJustification: "Task completed"
        )
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 15,
            qualityJustification: "Another task completed"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(requests.count == 2)
        #expect(requests[0].1 == "task-002")
        #expect(requests[1].1 == "task-001")
    }
    
    @Test("Collaborative scoring workflow")
    func testCollaborativeScoringWorkflow() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "creator", score: 0)
        try await scoreManager.setScore(for: "monitor", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 25,
            qualityJustification: "Feature implemented with all requirements met"
        )
        
        let creatorRequests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(creatorRequests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: creatorRequests[0].0,
            awarder: "monitor",
            awardedScore: 25,
            reason: "Outstanding implementation!"
        )
        
        let creatorScore = try await scoreManager.getScore(for: "creator")
        #expect(creatorScore == 25)
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "monitor",
            targetAI: "creator",
            requestedScore: 20,
            qualityJustification: "Code review completed"
        )
        
        let monitorRequests = try await scoreManager.getPendingScoreRequests(for: "creator")
        #expect(monitorRequests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: monitorRequests[0].0,
            awarder: "creator",
            awardedScore: 20,
            reason: "Excellent review!"
        )
        
        let monitorScore = try await scoreManager.getScore(for: "monitor")
        #expect(monitorScore == 20)
        
        let creatorHistory = try await scoreManager.getScoreHistory(for: "creator")
        #expect(creatorHistory.count == 1)
        
        let monitorHistory = try await scoreManager.getScoreHistory(for: "monitor")
        #expect(monitorHistory.count == 1)
    }
    
    @Test("ScoreManager reject score")
    func testRejectScore() async throws {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScoreManagerTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.db")
        
        defer {
            try? FileManager.default.removeItem(at: tempFile.deletingLastPathComponent())
        }
        
        let scoreManager = ScoreManager(dbPath: tempFile.path)
        try await scoreManager.initialize()
        
        try await scoreManager.setScore(for: "creator", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "creator",
            targetAI: "monitor",
            requestedScore: 25,
            qualityJustification: "Task completed successfully"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(requests.count == 1)
        
        try await scoreManager.rejectScore(
            requestId: requests[0].0,
            rejecter: "monitor",
            reason: "Task not completed according to requirements"
        )
        
        let score = try await scoreManager.getScore(for: "creator")
        #expect(score == 0)
        
        let history = try await scoreManager.getScoreHistory(for: "creator")
        #expect(history.count == 1)
        #expect(history[0].1 == 0)
        
        let pendingRequests = try await scoreManager.getPendingScoreRequests(for: "monitor")
        #expect(pendingRequests.count == 0)
    }
}
