import Foundation

public actor MessageCacheManager: MessageCacheProtocol {
    private let repository: MessageCacheRepositoryProtocol
    private let fromAI: String
    
    public init(repository: MessageCacheRepositoryProtocol, fromAI: String) {
        self.repository = repository
        self.fromAI = fromAI
    }
    
    public func sendTask(
        to: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendTaskMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            taskId: taskId,
            description: description,
            taskType: taskType,
            priority: priority,
            files: files,
            deadline: deadline,
            messagePriority: messagePriority
        )
        return messageId
    }
    
    public func receiveTasks(for aiName: String) async throws -> [TaskMessageModel] {
        return try await repository.getTaskMessages(forAI: aiName, status: .pending)
    }
    
    public func receiveTasks(for aiName: String, status: TaskStatus) async throws -> [TaskMessageModel] {
        return try await repository.getTaskMessages(forAI: aiName, status: status)
    }
    
    public func updateTaskStatus(messageId: UUID, to newStatus: TaskStatus) async throws -> Bool {
        return try await repository.updateTaskStatus(messageId: messageId, to: newStatus)
    }
    
    public func sendReview(
        to: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]?,
        feedback: String?,
        filesReviewed: [String]?,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendReviewMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            taskId: taskId,
            approved: approved,
            reviewer: reviewer,
            comments: comments,
            feedback: feedback,
            filesReviewed: filesReviewed,
            messagePriority: messagePriority
        )
        return messageId
    }
    
    public func receiveReviews(for aiName: String) async throws -> [ReviewMessageModel] {
        return try await repository.getReviewMessages(forAI: aiName, status: .pending)
    }
    
    public func receiveReviews(for aiName: String, status: ReviewStatus) async throws -> [ReviewMessageModel] {
        return try await repository.getReviewMessages(forAI: aiName, status: status)
    }
    
    public func updateReviewStatus(messageId: UUID, to newStatus: ReviewStatus) async throws -> Bool {
        return try await repository.updateReviewStatus(messageId: messageId, to: newStatus)
    }
    
    public func sendCode(
        to: String,
        codeId: String,
        title: String,
        description: String,
        files: [String],
        branch: String?,
        commitSha: String?,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendCodeMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            codeId: codeId,
            title: title,
            description: description,
            files: files,
            branch: branch,
            commitSha: commitSha,
            messagePriority: messagePriority
        )
        return messageId
    }
    
    public func receiveCodes(for aiName: String) async throws -> [CodeMessageModel] {
        return try await repository.getCodeMessages(forAI: aiName, status: .pending)
    }
    
    public func receiveCodes(for aiName: String, status: CodeStatus) async throws -> [CodeMessageModel] {
        return try await repository.getCodeMessages(forAI: aiName, status: status)
    }
    
    public func updateCodeStatus(messageId: UUID, to newStatus: CodeStatus) async throws -> Bool {
        return try await repository.updateCodeStatus(messageId: messageId, to: newStatus)
    }
    
    public func sendScore(
        to: String,
        taskId: String,
        requestedScore: Int,
        qualityJustification: String,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendScoreMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            taskId: taskId,
            requestedScore: requestedScore,
            qualityJustification: qualityJustification,
            messagePriority: messagePriority
        )
        return messageId
    }
    
    public func receiveScores(for aiName: String) async throws -> [ScoreMessageModel] {
        return try await repository.getScoreMessages(forAI: aiName, status: .pending)
    }
    
    public func receiveScores(for aiName: String, status: ScoreStatus) async throws -> [ScoreMessageModel] {
        return try await repository.getScoreMessages(forAI: aiName, status: status)
    }
    
    public func updateScoreStatus(messageId: UUID, to newStatus: ScoreStatus) async throws -> Bool {
        return try await repository.updateScoreStatus(messageId: messageId, to: newStatus)
    }
    
    public func sendFeedback(
        to: String,
        feedbackType: FeedbackType,
        subject: String,
        content: String,
        relatedTaskId: String?,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendFeedbackMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            feedbackType: feedbackType,
            subject: subject,
            content: content,
            relatedTaskId: relatedTaskId,
            messagePriority: messagePriority
        )
        return messageId
    }
    
    public func receiveFeedbacks(for aiName: String) async throws -> [FeedbackMessageModel] {
        return try await repository.getFeedbackMessages(forAI: aiName, status: .pending)
    }
    
    public func receiveFeedbacks(for aiName: String, status: FeedbackStatus) async throws -> [FeedbackMessageModel] {
        return try await repository.getFeedbackMessages(forAI: aiName, status: status)
    }
    
    public func updateFeedbackStatus(messageId: UUID, to newStatus: FeedbackStatus) async throws -> Bool {
        return try await repository.updateFeedbackStatus(messageId: messageId, to: newStatus)
    }
    
    public func sendHeartbeat(
        to: String,
        aiRole: String,
        status: HeartbeatStatus,
        currentTask: String?,
        metadata: [String: String]?
    ) async throws -> UUID {
        let messageId = UUID()
        try await repository.sendHeartbeatMessage(
            messageId: messageId,
            fromAI: fromAI,
            toAI: to,
            aiRole: aiRole,
            status: status,
            currentTask: currentTask,
            metadata: metadata
        )
        return messageId
    }
    
    public func receiveHeartbeats(for aiName: String) async throws -> [HeartbeatMessageModel] {
        return try await repository.getHeartbeatMessages(forAI: aiName)
    }
}
