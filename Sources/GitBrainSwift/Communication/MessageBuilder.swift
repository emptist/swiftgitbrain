import Foundation

public struct MessageBuilder: Sendable {
    
    public static func createTaskMessage(
        fromAI: String,
        toAI: String,
        taskID: String,
        taskDescription: String,
        taskType: String = "coding",
        priority: Int = 0
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .task,
            content: [
                "task_id": taskID,
                "description": taskDescription,
                "type": taskType
            ],
            priority: priority
        )
    }
    
    public static func createCodeMessage(
        fromAI: String,
        toAI: String,
        taskID: String,
        code: String,
        language: String = "python",
        files: [String] = []
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .code,
            content: [
                "task_id": taskID,
                "code": code,
                "language": language,
                "files": files
            ]
        )
    }
    
    public static func createReviewMessage(
        fromAI: String,
        toAI: String,
        taskID: String,
        reviewComments: [[String: Any]],
        approved: Bool
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .review,
            content: [
                "task_id": taskID,
                "comments": reviewComments,
                "approved": approved
            ]
        )
    }
    
    public static func createFeedbackMessage(
        fromAI: String,
        toAI: String,
        taskID: String,
        feedback: String,
        actionRequired: Bool = false
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .feedback,
            content: [
                "task_id": taskID,
                "feedback": feedback,
                "action_required": actionRequired
            ]
        )
    }
    
    public static func createApprovalMessage(
        fromAI: String,
        toAI: String,
        taskID: String,
        approved: Bool,
        reason: String = ""
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: approved ? .approval : .rejection,
            content: [
                "task_id": taskID,
                "approved": approved,
                "reason": reason
            ]
        )
    }
    
    public static func createStatusMessage(
        fromAI: String,
        toAI: String,
        status: String,
        details: [String: Any] = [:]
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .status,
            content: [
                "status": status,
                "details": details
            ]
        )
    }
    
    public static func createHeartbeatMessage(
        fromAI: String,
        toAI: String,
        state: [String: Any] = [:]
    ) -> Message {
        return Message(
            id: UUID().uuidString,
            fromAI: fromAI,
            toAI: toAI,
            messageType: .heartbeat,
            content: [
                "state": state
            ]
        )
    }
}
