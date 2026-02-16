import Foundation

/// Base protocol for all messages in GitBrain.
///
/// Design Principles:
/// - Uses RoleType for AI identification (type-safe, only creator/monitor)
/// - All messages are immutable structs
/// - No database concern at protocol level
/// - All messages have priority
public protocol MessageProtocol: Sendable, Codable {
    var id: UUID { get }
    var from: RoleType { get }
    var to: RoleType { get }
    var createdAt: Date { get }
    var priority: MessagePriority { get }
}

/// Task message for assigning work between AIs.
///
/// Lifecycle: pending → in_progress → completed | failed | cancelled
///
/// Reference Strategy:
/// - taskId: Self-generated, identifies the task
/// - No external references (root entity)
public protocol TaskMessageProtocol: MessageProtocol {
    var taskId: String { get }
    var title: String { get }
    var description: String { get }
    var taskType: TaskType { get }
    var status: TaskStatus { get }
    var files: [GitFileReference]? { get }
    var deadline: Date? { get }
}

/// Code message for submitting code for review.
///
/// Lifecycle: pending → reviewing → approved | rejected | merged
///
/// Reference Strategy:
/// - codeId: Self-generated, identifies the code submission
/// - No external references (self-contained)
public protocol CodeMessageProtocol: MessageProtocol {
    var codeId: String { get }
    var title: String { get }
    var description: String { get }
    var files: [GitFileReference] { get }
    var branch: String? { get }
    var commitSha: String? { get }
    var status: CodeStatus { get }
}

/// Review message for code review results.
///
/// Lifecycle: pending → in_review → approved | rejected | needs_changes
///
/// Reference Strategy:
/// - taskId: References the task being reviewed
/// - No reviewId (removed - redundant with taskId)
public protocol ReviewMessageProtocol: MessageProtocol {
    var taskId: String { get }
    var approved: Bool { get }
    var reviewer: String { get }
    var comments: [ReviewComment]? { get }
    var feedback: String { get }
    var filesReviewed: [GitFileReference]? { get }
    var status: ReviewStatus { get }
}

/// Score message for quality scoring.
///
/// Lifecycle: pending → requested → awarded | rejected
///
/// Reference Strategy:
/// - taskId: References the task being scored
/// - No scoreId (removed - redundant with taskId)
public protocol ScoreMessageProtocol: MessageProtocol {
    var taskId: String { get }
    var requestedScore: Int { get }
    var justification: String { get }
    var awardedScore: Int? { get }
    var awardReason: String? { get }
    var rejectReason: String? { get }
    var status: ScoreStatus { get }
}

/// Feedback message for general communication.
///
/// Lifecycle: pending → read → acknowledged → actioned
///
/// Reference Strategy:
/// - relatedTaskId: Optional context reference
/// - No feedbackId (removed - redundant with message id)
public protocol FeedbackMessageProtocol: MessageProtocol {
    var feedbackType: FeedbackType { get }
    var subject: String { get }
    var content: String { get }
    var relatedTaskId: String? { get }
    var response: String? { get }
    var status: FeedbackStatus { get }
}

/// Heartbeat message for keep-alive and status reporting.
///
/// No lifecycle - just status reporting.
///
/// Reference Strategy:
/// - No external references
/// - from field indicates the AI role
public protocol HeartbeatMessageProtocol: MessageProtocol {
    var status: HeartbeatStatus { get }
    var currentTask: String? { get }
    var metadata: [String: String]? { get }
}
