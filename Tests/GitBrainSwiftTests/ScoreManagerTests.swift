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
        
        try await scoreManager.setScore(for: "CoderAI", score: 10)
        let score = try await scoreManager.getScore(for: "CoderAI")
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
        
        try await scoreManager.setScore(for: "CoderAI", score: 0)
        try await scoreManager.incrementScore(for: "CoderAI")
        let score = try await scoreManager.getScore(for: "CoderAI")
        #expect(score == 1)
        
        try await scoreManager.incrementScore(for: "CoderAI", by: 10)
        let newScore = try await scoreManager.getScore(for: "CoderAI")
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
        
        try await scoreManager.setScore(for: "CoderAI", score: 100)
        try await scoreManager.setScore(for: "OverseerAI", score: 50)
        
        try await scoreManager.resetScores()
        
        let score1 = try await scoreManager.getScore(for: "CoderAI")
        let score2 = try await scoreManager.getScore(for: "OverseerAI")
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
        
        try await scoreManager.setScore(for: "CoderAI", score: 10)
        try await scoreManager.setScore(for: "OverseerAI", score: 20)
        try await scoreManager.setScore(for: "TestAI", score: 30)
        
        let allScores = try await scoreManager.getAllScores()
        #expect(allScores.count == 3)
        
        let coderScore = allScores.first { $0.0 == "CoderAI" }?.1
        let overseerScore = allScores.first { $0.0 == "OverseerAI" }?.1
        let testScore = allScores.first { $0.0 == "TestAI" }?.1
        
        #expect(coderScore == 10)
        #expect(overseerScore == 20)
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
        CoderAI Score: 10
        OverseerAI Score: 20
        TestAI Score: 30
        """
        try fileContent.write(to: scoreFile, atomically: true, encoding: .utf8)
        
        try await ScoreManager.migrateFromFile(filePath: scoreFile.path, to: dbFile.path)
        
        let scoreManager = ScoreManager(dbPath: dbFile.path)
        try await scoreManager.initialize()
        let allScores = try await scoreManager.getAllScores()
        
        #expect(allScores.count == 3)
        
        let coderScore = allScores.first { $0.0 == "CoderAI" }?.1
        let overseerScore = allScores.first { $0.0 == "OverseerAI" }?.1
        let testScore = allScores.first { $0.0 == "TestAI" }?.1
        
        #expect(coderScore == 10)
        #expect(overseerScore == 20)
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
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 25,
            qualityJustification: "Task completed successfully with all tests passing"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        #expect(requests.count == 1)
        #expect(requests[0].0 > 0)
        #expect(requests[0].1 == "task-001")
        #expect(requests[0].2 == "coder")
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
        
        try await scoreManager.setScore(for: "coder", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 25,
            qualityJustification: "Task completed successfully with all tests passing"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        #expect(requests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: requests[0].0,
            awarder: "overseer",
            awardedScore: 25,
            reason: "Excellent work! All requirements met"
        )
        
        let score = try await scoreManager.getScore(for: "coder")
        #expect(score == 25)
        
        let history = try await scoreManager.getScoreHistory(for: "coder")
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
        
        try await scoreManager.setScore(for: "coder", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 10,
            qualityJustification: "Task completed"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        try await scoreManager.awardScore(
            requestId: requests[0].0,
            awarder: "overseer",
            awardedScore: 10,
            reason: "Good work"
        )
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 15,
            qualityJustification: "Another task completed"
        )
        
        let requests2 = try await scoreManager.getPendingScoreRequests(for: "overseer")
        try await scoreManager.awardScore(
            requestId: requests2[0].0,
            awarder: "overseer",
            awardedScore: 15,
            reason: "Excellent work"
        )
        
        let history = try await scoreManager.getScoreHistory(for: "coder")
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
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 10,
            qualityJustification: "Task completed"
        )
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 15,
            qualityJustification: "Another task completed"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "overseer")
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
        
        try await scoreManager.setScore(for: "coder", score: 0)
        try await scoreManager.setScore(for: "overseer", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 25,
            qualityJustification: "Feature implemented with all requirements met"
        )
        
        let coderRequests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        #expect(coderRequests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: coderRequests[0].0,
            awarder: "overseer",
            awardedScore: 25,
            reason: "Outstanding implementation!"
        )
        
        let coderScore = try await scoreManager.getScore(for: "coder")
        #expect(coderScore == 25)
        
        try await scoreManager.requestScore(
            taskId: "task-002",
            requester: "overseer",
            targetAI: "coder",
            requestedScore: 20,
            qualityJustification: "Code review completed"
        )
        
        let overseerRequests = try await scoreManager.getPendingScoreRequests(for: "coder")
        #expect(overseerRequests.count == 1)
        
        try await scoreManager.awardScore(
            requestId: overseerRequests[0].0,
            awarder: "coder",
            awardedScore: 20,
            reason: "Excellent review!"
        )
        
        let overseerScore = try await scoreManager.getScore(for: "overseer")
        #expect(overseerScore == 20)
        
        let coderHistory = try await scoreManager.getScoreHistory(for: "coder")
        #expect(coderHistory.count == 1)
        
        let overseerHistory = try await scoreManager.getScoreHistory(for: "overseer")
        #expect(overseerHistory.count == 1)
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
        
        try await scoreManager.setScore(for: "coder", score: 0)
        
        try await scoreManager.requestScore(
            taskId: "task-001",
            requester: "coder",
            targetAI: "overseer",
            requestedScore: 25,
            qualityJustification: "Task completed successfully"
        )
        
        let requests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        #expect(requests.count == 1)
        
        try await scoreManager.rejectScore(
            requestId: requests[0].0,
            rejecter: "overseer",
            reason: "Task not completed according to requirements"
        )
        
        let score = try await scoreManager.getScore(for: "coder")
        #expect(score == 0)
        
        let history = try await scoreManager.getScoreHistory(for: "coder")
        #expect(history.count == 1)
        #expect(history[0].1 == 0)
        
        let pendingRequests = try await scoreManager.getPendingScoreRequests(for: "overseer")
        #expect(pendingRequests.count == 0)
    }
}
