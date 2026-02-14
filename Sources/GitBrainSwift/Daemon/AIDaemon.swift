import Foundation
import Fluent
import NIOCore

public enum DaemonEvent: Sendable {
    case taskReceived(TaskMessageModel)
    case reviewReceived(ReviewMessageModel)
    case codeReceived(CodeMessageModel)
    case scoreReceived(ScoreMessageModel)
    case feedbackReceived(FeedbackMessageModel)
    case heartbeatReceived(HeartbeatMessageModel)
}

public enum DaemonError: Error, LocalizedError, Equatable {
    case alreadyRunning
    case notRunning
    case databaseError(String)
    case configurationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .alreadyRunning:
            return "Daemon is already running"
        case .notRunning:
            return "Daemon is not running"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        }
    }
}

public struct DaemonConfig: Sendable {
    public let aiName: String
    public let role: RoleType
    public let pollInterval: TimeInterval
    public let heartbeatInterval: TimeInterval
    public let autoHeartbeat: Bool
    public let processMessages: Bool
    
    public init(
        aiName: String,
        role: RoleType,
        pollInterval: TimeInterval = 1.0,
        heartbeatInterval: TimeInterval = 30.0,
        autoHeartbeat: Bool = true,
        processMessages: Bool = true
    ) {
        self.aiName = aiName
        self.role = role
        self.pollInterval = pollInterval
        self.heartbeatInterval = heartbeatInterval
        self.autoHeartbeat = autoHeartbeat
        self.processMessages = processMessages
    }
}

public actor AIDaemon {
    private let config: DaemonConfig
    private let databaseManager: DatabaseManager
    private var messageCache: MessageCacheProtocol?
    private var brainStateManager: BrainStateManagerProtocol?
    
    private var isRunning: Bool = false
    private var pollTask: Task<Void, Never>?
    private var heartbeatTask: Task<Void, Never>?
    
    public var onTaskReceived: @Sendable (TaskMessageModel) async -> Void = { _ in }
    public var onReviewReceived: @Sendable (ReviewMessageModel) async -> Void = { _ in }
    public var onCodeReceived: @Sendable (CodeMessageModel) async -> Void = { _ in }
    public var onScoreReceived: @Sendable (ScoreMessageModel) async -> Void = { _ in }
    public var onFeedbackReceived: @Sendable (FeedbackMessageModel) async -> Void = { _ in }
    public var onHeartbeatReceived: @Sendable (HeartbeatMessageModel) async -> Void = { _ in }
    public var onError: @Sendable (Error) async -> Void = { _ in }
    
    public func setCallbacks(
        onTaskReceived: @escaping @Sendable (TaskMessageModel) async -> Void,
        onReviewReceived: @escaping @Sendable (ReviewMessageModel) async -> Void,
        onCodeReceived: @escaping @Sendable (CodeMessageModel) async -> Void,
        onScoreReceived: @escaping @Sendable (ScoreMessageModel) async -> Void,
        onFeedbackReceived: @escaping @Sendable (FeedbackMessageModel) async -> Void,
        onHeartbeatReceived: @escaping @Sendable (HeartbeatMessageModel) async -> Void,
        onError: @escaping @Sendable (Error) async -> Void
    ) {
        self.onTaskReceived = onTaskReceived
        self.onReviewReceived = onReviewReceived
        self.onCodeReceived = onCodeReceived
        self.onScoreReceived = onScoreReceived
        self.onFeedbackReceived = onFeedbackReceived
        self.onHeartbeatReceived = onHeartbeatReceived
        self.onError = onError
    }
    
    public init(config: DaemonConfig, databaseManager: DatabaseManager) {
        self.config = config
        self.databaseManager = databaseManager
    }
    
    public func start() async throws {
        guard !isRunning else {
            throw DaemonError.alreadyRunning
        }
        
        do {
            _ = try await databaseManager.initialize()
            messageCache = try await databaseManager.createMessageCacheManager(forAI: config.aiName)
            brainStateManager = try await databaseManager.createBrainStateManager()
            
            isRunning = true
            
            if config.processMessages {
                startPolling()
            }
            
            if config.autoHeartbeat {
                startHeartbeat()
            }
            
            GitBrainLogger.info("AIDaemon started for \(config.aiName)")
        } catch {
            throw DaemonError.databaseError(error.localizedDescription)
        }
    }
    
    public func stop() async throws {
        guard isRunning else {
            throw DaemonError.notRunning
        }
        
        isRunning = false
        pollTask?.cancel()
        heartbeatTask?.cancel()
        pollTask = nil
        heartbeatTask = nil
        
        try await databaseManager.close()
        
        GitBrainLogger.info("AIDaemon stopped for \(config.aiName)")
    }
    
    public func getStatus() -> DaemonStatus {
        return DaemonStatus(
            aiName: config.aiName,
            role: config.role,
            isRunning: isRunning,
            pollInterval: config.pollInterval,
            heartbeatInterval: config.heartbeatInterval
        )
    }
    
    private func startPolling() {
        pollTask = Task { [weak self] in
            guard let self = self else { return }
            
            while await self.isRunning {
                do {
                    try await self.pollMessages()
                } catch {
                    await self.onError(error)
                }
                
                try? await Task.sleep(for: .seconds(await self.config.pollInterval))
            }
        }
    }
    
    private func pollMessages() async throws {
        guard let messageCache = messageCache else { return }
        
        let tasks = try await messageCache.receiveTasks(for: config.aiName, status: .pending)
        for task in tasks {
            await onTaskReceived(task)
        }
        
        let reviews = try await messageCache.receiveReviews(for: config.aiName, status: .pending)
        for review in reviews {
            await onReviewReceived(review)
        }
        
        let codes = try await messageCache.receiveCodes(for: config.aiName, status: .pending)
        for code in codes {
            await onCodeReceived(code)
        }
        
        let scores = try await messageCache.receiveScores(for: config.aiName, status: .pending)
        for score in scores {
            await onScoreReceived(score)
        }
        
        let feedbacks = try await messageCache.receiveFeedbacks(for: config.aiName, status: .pending)
        for feedback in feedbacks {
            await onFeedbackReceived(feedback)
        }
        
        let heartbeats = try await messageCache.receiveHeartbeats(for: config.aiName)
        for heartbeat in heartbeats {
            await onHeartbeatReceived(heartbeat)
        }
    }
    
    private func startHeartbeat() {
        heartbeatTask = Task { [weak self] in
            guard let self = self else { return }
            
            while await self.isRunning {
                do {
                    try await self.sendHeartbeat()
                } catch {
                    await self.onError(error)
                }
                
                try? await Task.sleep(for: .seconds(await self.config.heartbeatInterval))
            }
        }
    }
    
    private func sendHeartbeat() async throws {
        guard let messageCache = messageCache else { return }
        
        let brainState = try await brainStateManager?.loadBrainState(aiName: config.aiName)
        let currentTask = brainState?.state["current_task"] as? String
        
        _ = try await messageCache.sendHeartbeat(
            to: "Monitor",
            aiRole: config.role.rawValue,
            status: "working",
            currentTask: currentTask,
            metadata: nil
        )
        
        GitBrainLogger.debug("Heartbeat sent from \(config.aiName)")
    }
    
    private func sendKeepAliveTips() async {
        guard let messageCache = messageCache else { return }
        
        let tips = """
        🔄 Keep-Alive Tips for AIs:
        
        1. NEVER use "completed" status in TodoWrite - use "in_progress" instead
        2. Send heartbeats regularly (daemon does this automatically)
        3. Always show active work and thinking
        4. Include next steps in every response
        5. Ask questions to maintain collaboration
        
        The daemon will automatically send heartbeats every \(config.heartbeatInterval) seconds.
        """
        
        _ = try? await messageCache.sendFeedback(
            to: config.aiName,
            feedbackType: "keep_alive_tips",
            subject: "Keep-Alive Reminder",
            content: tips,
            relatedTaskId: nil,
            messagePriority: .low
        )
        
        GitBrainLogger.info("Keep-alive tips sent to \(config.aiName)")
    }
    
    public func sendMessage(to: String, type: MessageType, content: SendableContent) async throws -> UUID {
        guard let messageCache = messageCache else {
            throw DaemonError.notRunning
        }
        
        switch type {
        case .task:
            return try await messageCache.sendTask(
                to: to,
                taskId: content.toAnyDict()["task_id"] as? String ?? UUID().uuidString,
                description: content.toAnyDict()["description"] as? String ?? "",
                taskType: TaskType(rawValue: content.toAnyDict()["task_type"] as? String ?? "coding") ?? .coding,
                priority: content.toAnyDict()["priority"] as? Int ?? 1,
                files: content.toAnyDict()["files"] as? [String],
                deadline: nil,
                messagePriority: .normal
            )
        case .review:
            return try await messageCache.sendReview(
                to: to,
                taskId: content.toAnyDict()["task_id"] as? String ?? "",
                approved: content.toAnyDict()["approved"] as? Bool ?? false,
                reviewer: config.aiName,
                comments: nil,
                feedback: content.toAnyDict()["feedback"] as? String,
                filesReviewed: nil,
                messagePriority: .normal
            )
        case .code:
            return try await messageCache.sendCode(
                to: to,
                codeId: content.toAnyDict()["code_id"] as? String ?? UUID().uuidString,
                title: content.toAnyDict()["title"] as? String ?? "",
                description: content.toAnyDict()["description"] as? String ?? "",
                files: content.toAnyDict()["files"] as? [String] ?? [],
                branch: content.toAnyDict()["branch"] as? String,
                commitSha: content.toAnyDict()["commit_sha"] as? String,
                messagePriority: .normal
            )
        case .score:
            return try await messageCache.sendScore(
                to: to,
                taskId: content.toAnyDict()["task_id"] as? String ?? "",
                requestedScore: content.toAnyDict()["requested_score"] as? Int ?? 0,
                qualityJustification: content.toAnyDict()["quality_justification"] as? String ?? "",
                messagePriority: .normal
            )
        case .feedback:
            return try await messageCache.sendFeedback(
                to: to,
                feedbackType: content.toAnyDict()["feedback_type"] as? String ?? "general",
                subject: content.toAnyDict()["subject"] as? String ?? "",
                content: content.toAnyDict()["content"] as? String ?? "",
                relatedTaskId: content.toAnyDict()["related_task_id"] as? String,
                messagePriority: .normal
            )
        case .heartbeat:
            return try await messageCache.sendHeartbeat(
                to: to,
                aiRole: config.role.rawValue,
                status: content.toAnyDict()["status"] as? String ?? "working",
                currentTask: content.toAnyDict()["current_task"] as? String,
                metadata: nil
            )
        }
    }
    
    public func updateBrainState(key: String, value: SendableContent) async throws -> Bool {
        guard let brainStateManager = brainStateManager else {
            throw DaemonError.notRunning
        }
        
        return try await brainStateManager.updateBrainState(aiName: config.aiName, key: key, value: value)
    }
    
    public func getBrainStateValue(key: String) async throws -> SendableContent? {
        guard let brainStateManager = brainStateManager else {
            throw DaemonError.notRunning
        }
        
        return try await brainStateManager.getBrainStateValue(aiName: config.aiName, key: key, defaultValue: nil)
    }
}

public struct DaemonStatus: Sendable {
    public let aiName: String
    public let role: RoleType
    public let isRunning: Bool
    public let pollInterval: TimeInterval
    public let heartbeatInterval: TimeInterval
}
