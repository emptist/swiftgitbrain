import Foundation

public protocol MessageCacheProtocol: Sendable {
    func sendTask(
        to: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveTasks(for aiName: String) async throws -> [TaskMessageModel]
    func receiveTasks(for aiName: String, status: TaskStatus) async throws -> [TaskMessageModel]
    func updateTaskStatus(messageId: UUID, to newStatus: TaskStatus) async throws -> Bool
    
    func sendReview(
        to: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]?,
        feedback: String?,
        filesReviewed: [String]?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveReviews(for aiName: String) async throws -> [ReviewMessageModel]
    func receiveReviews(for aiName: String, status: ReviewStatus) async throws -> [ReviewMessageModel]
    func updateReviewStatus(messageId: UUID, to newStatus: ReviewStatus) async throws -> Bool
    
    func sendCode(
        to: String,
        codeId: String,
        title: String,
        description: String,
        files: [String],
        branch: String?,
        commitSha: String?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveCodes(for aiName: String) async throws -> [CodeMessageModel]
    func receiveCodes(for aiName: String, status: CodeStatus) async throws -> [CodeMessageModel]
    func updateCodeStatus(messageId: UUID, to newStatus: CodeStatus) async throws -> Bool
    
    func sendScore(
        to: String,
        taskId: String,
        requestedScore: Int,
        qualityJustification: String,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveScores(for aiName: String) async throws -> [ScoreMessageModel]
    func receiveScores(for aiName: String, status: ScoreStatus) async throws -> [ScoreMessageModel]
    func updateScoreStatus(messageId: UUID, to newStatus: ScoreStatus) async throws -> Bool
    
    func sendFeedback(
        to: String,
        feedbackType: String,
        subject: String,
        content: String,
        relatedTaskId: String?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveFeedbacks(for aiName: String) async throws -> [FeedbackMessageModel]
    func receiveFeedbacks(for aiName: String, status: FeedbackStatus) async throws -> [FeedbackMessageModel]
    func updateFeedbackStatus(messageId: UUID, to newStatus: FeedbackStatus) async throws -> Bool
    
    func sendHeartbeat(
        to: String,
        aiRole: String,
        status: String,
        currentTask: String?,
        metadata: [String: String]?
    ) async throws -> UUID
    
    func receiveHeartbeats(for aiName: String) async throws -> [HeartbeatMessageModel]
}
