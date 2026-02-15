import Foundation

public protocol MessageCacheRepositoryProtocol: Sendable {
    func sendTaskMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws
    
    func getTaskMessages(forAI aiName: String, status: TaskStatus?) async throws -> [TaskMessageModel]
    func updateTaskStatus(messageId: UUID, to newStatus: TaskStatus) async throws -> Bool
    func deleteTaskMessage(messageId: UUID) async throws -> Bool
    
    func sendReviewMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]?,
        feedback: String?,
        filesReviewed: [String]?,
        messagePriority: MessagePriority
    ) async throws
    
    func getReviewMessages(forAI aiName: String, status: ReviewStatus?) async throws -> [ReviewMessageModel]
    func updateReviewStatus(messageId: UUID, to newStatus: ReviewStatus) async throws -> Bool
    func deleteReviewMessage(messageId: UUID) async throws -> Bool
    
    func sendCodeMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        codeId: String,
        title: String,
        description: String,
        files: [String],
        branch: String?,
        commitSha: String?,
        messagePriority: MessagePriority
    ) async throws
    
    func getCodeMessages(forAI aiName: String, status: CodeStatus?) async throws -> [CodeMessageModel]
    func updateCodeStatus(messageId: UUID, to newStatus: CodeStatus) async throws -> Bool
    func deleteCodeMessage(messageId: UUID) async throws -> Bool
    
    func sendScoreMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        requestedScore: Int,
        qualityJustification: String,
        messagePriority: MessagePriority
    ) async throws
    
    func getScoreMessages(forAI aiName: String, status: ScoreStatus?) async throws -> [ScoreMessageModel]
    func updateScoreStatus(messageId: UUID, to newStatus: ScoreStatus) async throws -> Bool
    func deleteScoreMessage(messageId: UUID) async throws -> Bool
    
    func sendFeedbackMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        feedbackType: FeedbackType,
        subject: String,
        content: String,
        relatedTaskId: String?,
        messagePriority: MessagePriority
    ) async throws
    
    func getFeedbackMessages(forAI aiName: String, status: FeedbackStatus?) async throws -> [FeedbackMessageModel]
    func updateFeedbackStatus(messageId: UUID, to newStatus: FeedbackStatus) async throws -> Bool
    func deleteFeedbackMessage(messageId: UUID) async throws -> Bool
    
    func sendHeartbeatMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        aiRole: String,
        status: HeartbeatStatus,
        currentTask: String?,
        metadata: [String: String]?
    ) async throws
    
    func getHeartbeatMessages(forAI aiName: String) async throws -> [HeartbeatMessageModel]
    func deleteHeartbeatMessage(messageId: UUID) async throws -> Bool
}
