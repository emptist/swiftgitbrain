import Testing
import Foundation
@testable import GitBrainSwift

@Suite("AIDaemon Tests")
struct AIDaemonTests {
    
    @Test("DaemonConfig initialization with defaults")
    func testDaemonConfigDefaults() async {
        let config = DaemonConfig(
            aiName: "TestAI",
            role: .coder
        )
        
        #expect(config.aiName == "TestAI")
        #expect(config.role == .coder)
        #expect(config.pollInterval == 1.0)
        #expect(config.heartbeatInterval == 30.0)
        #expect(config.autoHeartbeat == true)
        #expect(config.processMessages == true)
    }
    
    @Test("DaemonConfig initialization with custom values")
    func testDaemonConfigCustom() async {
        let config = DaemonConfig(
            aiName: "CustomAI",
            role: .overseer,
            pollInterval: 2.0,
            heartbeatInterval: 60.0,
            autoHeartbeat: false,
            processMessages: false
        )
        
        #expect(config.aiName == "CustomAI")
        #expect(config.role == .overseer)
        #expect(config.pollInterval == 2.0)
        #expect(config.heartbeatInterval == 60.0)
        #expect(config.autoHeartbeat == false)
        #expect(config.processMessages == false)
    }
    
    @Test("DaemonError descriptions")
    func testDaemonErrorDescriptions() async {
        #expect(DaemonError.alreadyRunning.errorDescription == "Daemon is already running")
        #expect(DaemonError.notRunning.errorDescription == "Daemon is not running")
        #expect(DaemonError.databaseError("test error").errorDescription == "Database error: test error")
        #expect(DaemonError.configurationError("bad config").errorDescription == "Configuration error: bad config")
    }
    
    @Test("DaemonStatus creation")
    func testDaemonStatus() async {
        let status = DaemonStatus(
            aiName: "StatusAI",
            role: .coder,
            isRunning: true,
            pollInterval: 1.5,
            heartbeatInterval: 45.0
        )
        
        #expect(status.aiName == "StatusAI")
        #expect(status.role == .coder)
        #expect(status.isRunning == true)
        #expect(status.pollInterval == 1.5)
        #expect(status.heartbeatInterval == 45.0)
    }
    
    @Test("AIDaemon initialization")
    func testDaemonInit() async {
        let config = DaemonConfig(aiName: "InitAI", role: .coder)
        let dbManager = DatabaseManager()
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        let status = await daemon.getStatus()
        #expect(status.aiName == "InitAI")
        #expect(status.role == .coder)
        #expect(status.isRunning == false)
    }
    
    @Test("AIDaemon callbacks can be set")
    func testDaemonCallbacks() async {
        let config = DaemonConfig(aiName: "CallbackAI", role: .coder)
        let dbManager = DatabaseManager()
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        actor CallbackTracker {
            var taskReceived = false
            var reviewReceived = false
            var codeReceived = false
            var scoreReceived = false
            var feedbackReceived = false
            var heartbeatReceived = false
            var errorReceived = false
            
            func setTaskReceived() { taskReceived = true }
            func setReviewReceived() { reviewReceived = true }
            func setCodeReceived() { codeReceived = true }
            func setScoreReceived() { scoreReceived = true }
            func setFeedbackReceived() { feedbackReceived = true }
            func setHeartbeatReceived() { heartbeatReceived = true }
            func setErrorReceived() { errorReceived = true }
        }
        
        let tracker = CallbackTracker()
        
        await daemon.setCallbacks(
            onTaskReceived: { _ in await tracker.setTaskReceived() },
            onReviewReceived: { _ in await tracker.setReviewReceived() },
            onCodeReceived: { _ in await tracker.setCodeReceived() },
            onScoreReceived: { _ in await tracker.setScoreReceived() },
            onFeedbackReceived: { _ in await tracker.setFeedbackReceived() },
            onHeartbeatReceived: { _ in await tracker.setHeartbeatReceived() },
            onError: { _ in await tracker.setErrorReceived() }
        )
        
        #expect(await tracker.taskReceived == false)
        #expect(await tracker.reviewReceived == false)
        #expect(await tracker.codeReceived == false)
        #expect(await tracker.scoreReceived == false)
        #expect(await tracker.feedbackReceived == false)
        #expect(await tracker.heartbeatReceived == false)
        #expect(await tracker.errorReceived == false)
    }
    
    @Test("AIDaemon start fails when already running")
    func testDaemonDoubleStart() async throws {
        let config = DaemonConfig(
            aiName: "DoubleStartAI",
            role: .coder,
            pollInterval: 1.0,
            heartbeatInterval: 30.0,
            autoHeartbeat: false,
            processMessages: false
        )
        let dbManager = DatabaseManager()
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        do {
            try await daemon.start()
            
            await #expect(throws: DaemonError.alreadyRunning) {
                try await daemon.start()
            }
            
            try await daemon.stop()
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("AIDaemon stop fails when not running")
    func testDaemonStopNotRunning() async {
        let config = DaemonConfig(aiName: "StopAI", role: .coder)
        let dbManager = DatabaseManager()
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        await #expect(throws: DaemonError.notRunning) {
            try await daemon.stop()
        }
    }
}

@Suite("DaemonConfig Sendable Tests")
struct DaemonConfigSendableTests {
    
    @Test("DaemonConfig is Sendable")
    func testDaemonConfigSendable() async {
        let config = DaemonConfig(aiName: "SendableAI", role: .coder)
        
        let task = Task {
            return config.aiName
        }
        
        let result = await task.value
        #expect(result == "SendableAI")
    }
    
    @Test("DaemonStatus is Sendable")
    func testDaemonStatusSendable() async {
        let status = DaemonStatus(
            aiName: "SendableStatusAI",
            role: .coder,
            isRunning: true,
            pollInterval: 1.0,
            heartbeatInterval: 30.0
        )
        
        let task = Task {
            return status.aiName
        }
        
        let result = await task.value
        #expect(result == "SendableStatusAI")
    }
}
