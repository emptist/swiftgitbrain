import Fluent
import Foundation

public actor FluentMessageCacheRepository: MessageCacheRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func sendTaskMessage(
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
    ) async throws {
        let message = TaskMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            taskId: taskId,
            description: description,
            taskType: taskType,
            priority: priority,
            files: files,
            deadline: deadline,
            status: .pending,
            messagePriority: messagePriority
        )
        try await message.save(on: database)
    }
    
    public func getTaskMessages(forAI aiName: String, status: TaskStatus?) async throws -> [TaskMessageModel] {
        var query = TaskMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
        
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        
        return try await query.sort(\.$timestamp, .descending).all()
    }
    
    public func updateTaskStatus(messageId: UUID, to newStatus: TaskStatus) async throws -> Bool {
        guard let message = try await TaskMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try message.transitionStatus(to: newStatus)
        try await message.save(on: database)
        return true
    }
    
    public func deleteTaskMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await TaskMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
    
    public func sendReviewMessage(
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
    ) async throws {
        let message = ReviewMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            taskId: taskId,
            approved: approved,
            reviewer: reviewer,
            comments: comments,
            feedback: feedback,
            filesReviewed: filesReviewed,
            status: .pending,
            messagePriority: messagePriority
        )
        try await message.save(on: database)
    }
    
    public func getReviewMessages(forAI aiName: String, status: ReviewStatus?) async throws -> [ReviewMessageModel] {
        var query = ReviewMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
        
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        
        return try await query.sort(\.$timestamp, .descending).all()
    }
    
    public func updateReviewStatus(messageId: UUID, to newStatus: ReviewStatus) async throws -> Bool {
        guard let message = try await ReviewMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try message.transitionStatus(to: newStatus)
        try await message.save(on: database)
        return true
    }
    
    public func deleteReviewMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await ReviewMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
    
    public func sendCodeMessage(
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
    ) async throws {
        let message = CodeMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            codeId: codeId,
            title: title,
            description: description,
            files: files,
            branch: branch,
            commitSha: commitSha,
            status: .pending,
            messagePriority: messagePriority
        )
        try await message.save(on: database)
    }
    
    public func getCodeMessages(forAI aiName: String, status: CodeStatus?) async throws -> [CodeMessageModel] {
        var query = CodeMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
        
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        
        return try await query.sort(\.$timestamp, .descending).all()
    }
    
    public func updateCodeStatus(messageId: UUID, to newStatus: CodeStatus) async throws -> Bool {
        guard let message = try await CodeMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try message.transitionStatus(to: newStatus)
        try await message.save(on: database)
        return true
    }
    
    public func deleteCodeMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await CodeMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
    
    public func sendScoreMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        requestedScore: Int,
        qualityJustification: String,
        messagePriority: MessagePriority
    ) async throws {
        let message = ScoreMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            taskId: taskId,
            requestedScore: requestedScore,
            qualityJustification: qualityJustification,
            status: .pending,
            messagePriority: messagePriority
        )
        try await message.save(on: database)
    }
    
    public func getScoreMessages(forAI aiName: String, status: ScoreStatus?) async throws -> [ScoreMessageModel] {
        var query = ScoreMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
        
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        
        return try await query.sort(\.$timestamp, .descending).all()
    }
    
    public func updateScoreStatus(messageId: UUID, to newStatus: ScoreStatus) async throws -> Bool {
        guard let message = try await ScoreMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try message.transitionStatus(to: newStatus)
        try await message.save(on: database)
        return true
    }
    
    public func deleteScoreMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await ScoreMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
    
    public func sendFeedbackMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        feedbackType: FeedbackType,
        subject: String,
        content: String,
        relatedTaskId: String?,
        messagePriority: MessagePriority
    ) async throws {
        let message = FeedbackMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            feedbackType: feedbackType,
            subject: subject,
            content: content,
            relatedTaskId: relatedTaskId,
            status: .pending,
            messagePriority: messagePriority
        )
        try await message.save(on: database)
    }
    
    public func getFeedbackMessages(forAI aiName: String, status: FeedbackStatus?) async throws -> [FeedbackMessageModel] {
        var query = FeedbackMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
        
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        
        return try await query.sort(\.$timestamp, .descending).all()
    }
    
    public func updateFeedbackStatus(messageId: UUID, to newStatus: FeedbackStatus) async throws -> Bool {
        guard let message = try await FeedbackMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try message.transitionStatus(to: newStatus)
        try await message.save(on: database)
        return true
    }
    
    public func deleteFeedbackMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await FeedbackMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
    
    public func sendHeartbeatMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        aiRole: String,
        status: HeartbeatStatus,
        currentTask: String?,
        metadata: [String: String]?
    ) async throws {
        let message = HeartbeatMessageModel(
            messageId: messageId,
            fromAI: fromAI,
            toAI: toAI,
            timestamp: Date(),
            aiRole: aiRole,
            status: status,
            currentTask: currentTask,
            metadata: metadata
        )
        try await message.save(on: database)
    }
    
    public func getHeartbeatMessages(forAI aiName: String) async throws -> [HeartbeatMessageModel] {
        return try await HeartbeatMessageModel.query(on: database)
            .filter(\.$toAI == aiName)
            .sort(\.$timestamp, .descending)
            .all()
    }
    
    public func deleteHeartbeatMessage(messageId: UUID) async throws -> Bool {
        guard let message = try await HeartbeatMessageModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        
        try await message.delete(on: database)
        return true
    }
}
