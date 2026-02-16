import Foundation

/// Task message for assigning work between AIs.
public struct TaskMessage: TaskMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let taskId: String
    public let title: String
    public let description: String
    public let taskType: TaskType
    public let status: TaskStatus
    public let files: [GitFileReference]?
    public let deadline: Date?
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        taskId: String,
        title: String,
        description: String,
        taskType: TaskType,
        status: TaskStatus = .pending,
        files: [GitFileReference]? = nil,
        deadline: Date? = nil
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.taskId = taskId
        self.title = title
        self.description = description
        self.taskType = taskType
        self.status = status
        self.files = files
        self.deadline = deadline
    }
}

/// Code message for submitting code for review.
public struct CodeMessage: CodeMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let codeId: String
    public let title: String
    public let description: String
    public let files: [GitFileReference]
    public let branch: String?
    public let commitSha: String?
    public let status: CodeStatus
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        codeId: String,
        title: String,
        description: String,
        files: [GitFileReference],
        branch: String? = nil,
        commitSha: String? = nil,
        status: CodeStatus = .pending
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.codeId = codeId
        self.title = title
        self.description = description
        self.files = files
        self.branch = branch
        self.commitSha = commitSha
        self.status = status
    }
}

/// Review message for code review results.
public struct ReviewMessage: ReviewMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let taskId: String
    public let approved: Bool
    public let reviewer: String
    public let comments: [ReviewComment]?
    public let feedback: String
    public let filesReviewed: [GitFileReference]?
    public let status: ReviewStatus
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]? = nil,
        feedback: String = "",
        filesReviewed: [GitFileReference]? = nil,
        status: ReviewStatus = .pending
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.taskId = taskId
        self.approved = approved
        self.reviewer = reviewer
        self.comments = comments
        self.feedback = feedback
        self.filesReviewed = filesReviewed
        self.status = status
    }
}

/// Score message for quality scoring.
public struct ScoreMessage: ScoreMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let taskId: String
    public let requestedScore: Int
    public let justification: String
    public let awardedScore: Int?
    public let awardReason: String?
    public let rejectReason: String?
    public let status: ScoreStatus
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        taskId: String,
        requestedScore: Int,
        justification: String,
        awardedScore: Int? = nil,
        awardReason: String? = nil,
        rejectReason: String? = nil,
        status: ScoreStatus = .pending
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.taskId = taskId
        self.requestedScore = requestedScore
        self.justification = justification
        self.awardedScore = awardedScore
        self.awardReason = awardReason
        self.rejectReason = rejectReason
        self.status = status
    }
}

/// Feedback message for general communication.
public struct FeedbackMessage: FeedbackMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let feedbackType: FeedbackType
    public let subject: String
    public let content: String
    public let relatedTaskId: String?
    public let response: String?
    public let status: FeedbackStatus
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        feedbackType: FeedbackType,
        subject: String,
        content: String,
        relatedTaskId: String? = nil,
        response: String? = nil,
        status: FeedbackStatus = .pending
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.feedbackType = feedbackType
        self.subject = subject
        self.content = content
        self.relatedTaskId = relatedTaskId
        self.response = response
        self.status = status
    }
}

/// Heartbeat message for keep-alive and status reporting.
public struct HeartbeatMessage: HeartbeatMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let status: HeartbeatStatus
    public let currentTask: String?
    public let metadata: [String: String]?
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        status: HeartbeatStatus = .active,
        currentTask: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.status = status
        self.currentTask = currentTask
        self.metadata = metadata
    }
}
