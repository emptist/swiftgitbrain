import Foundation

public actor CoderAI: BaseRole {
    public let system: SystemConfig
    public let roleConfig: RoleConfig
    public let communication: any CommunicationProtocol
    public let memoryManager: any BrainStateManagerProtocol
    public let memoryStore: any MemoryStoreProtocol
    public let knowledgeBase: any KnowledgeBaseProtocol
    
    private var currentTask: [String: Any]?
    private var taskHistory: [[String: Any]] = []
    private var codeHistory: [[String: Any]] = []
    
    public init(
        system: SystemConfig,
        roleConfig: RoleConfig,
        communication: any CommunicationProtocol,
        memoryManager: any BrainStateManagerProtocol,
        memoryStore: any MemoryStoreProtocol,
        knowledgeBase: any KnowledgeBaseProtocol
    ) {
        self.system = system
        self.roleConfig = roleConfig
        self.communication = communication
        self.memoryManager = memoryManager
        self.memoryStore = memoryStore
        self.knowledgeBase = knowledgeBase
    }
    
    public func initialize() async throws {
        let initialized = try await getBrainStateValue(key: "initialized", defaultValue: SendableContent(["value": false]))?.toAnyDict()["value"] as? Bool ?? false
        
        if !initialized {
            try await updateBrainState(key: "initialized", value: SendableContent(["value": true]))
            try await updateBrainState(key: "current_task", value: SendableContent(["value": NSNull()]))
            try await updateBrainState(key: "task_history", value: SendableContent(["value": []]))
            try await updateBrainState(key: "code_history", value: SendableContent(["value": []]))
            try await updateBrainState(key: "preferred_language", value: SendableContent(["value": "swift"]))
            try await updateBrainState(key: "coding_style", value: SendableContent(["value": "clean"]))
        }
    }
    
    public func processMessage(_ message: Message) async {
        switch message.messageType {
        case .task:
            await handleTask(message.content)
        case .feedback:
            await handleFeedback(message.content)
        case .approval:
            await handleApproval(message.content)
        case .rejection:
            await handleRejection(message.content)
        case .heartbeat:
            await handleHeartbeat(message.content)
        default:
            await handleUnknownMessage(message)
        }
    }
    
    public func handleTask(_ task: SendableContent) async {
        let taskDict = task.toAnyDict()
        guard let taskID = taskDict["task_id"] as? String,
              let description = taskDict["description"] as? String else {
            return
        }
        
        let taskType = taskDict["type"] as? String ?? "coding"
        
        currentTask = [
            "task_id": taskID,
            "description": description,
            "type": taskType,
            "status": "in_progress",
            "started_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": currentTask ?? [:]]))
        
        taskHistory.append(currentTask ?? [:])
        try? await updateBrainState(key: "task_history", value: SendableContent(["value": taskHistory]))
        
        try? await sendStatusUpdate(status: "Started task: \(taskID)")
    }
    
    public func implementTask() async -> SendableContent? {
        guard let currentTask = currentTask else {
            return nil
        }
        
        guard let taskID = currentTask["task_id"] as? String,
              let description = currentTask["description"] as? String else {
            return nil
        }
        
        let code = await generateCode(description: description)
        
        let codeSubmission: [String: Any] = [
            "task_id": taskID,
            "code": code,
            "language": (try? await getBrainStateValue(key: "preferred_language", defaultValue: SendableContent(["value": "swift"]))?.toAnyDict()["value"] as? String) ?? "swift",
            "files": [] as [String],
            "description": "Implementation for task: \(description)"
        ]
        
        codeHistory.append(codeSubmission)
        try? await updateBrainState(key: "code_history", value: SendableContent(["value": codeHistory]))
        
        self.currentTask?["status"] = "completed"
        self.currentTask?["completed_at"] = ISO8601DateFormatter().string(from: Date())
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": self.currentTask ?? [:]]))
        
        return SendableContent(codeSubmission)
    }
    
    public func submitCode(reviewer: String = "overseer") async throws -> String {
        guard let currentTask = currentTask else {
            return ""
        }
        
        guard let codeSubmission = await implementTask() else {
            return ""
        }
        
        let codeSubmissionDict = codeSubmission.toAnyDict()
        
        let message = MessageBuilder.createCodeMessage(
            fromAI: roleConfig.name,
            toAI: reviewer,
            taskID: codeSubmissionDict["task_id"] as? String ?? "",
            code: codeSubmissionDict["code"] as? String ?? "",
            language: codeSubmissionDict["language"] as? String ?? "swift",
            files: codeSubmissionDict["files"] as? [String] ?? []
        )
        
        return try await sendMessage(message)
    }
    
    public func handleFeedback(_ feedback: SendableContent) async {
        let feedbackDict = feedback.toAnyDict()
        guard let taskID = feedbackDict["task_id"] as? String,
              let feedbackText = feedbackDict["feedback"] as? String else {
            return
        }
        
        let actionRequired = feedbackDict["action_required"] as? Bool ?? false
        
        try? await addKnowledge(
            category: "feedback",
            key: taskID,
            value: SendableContent([
                "feedback": feedbackText,
                "action_required": actionRequired,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ])
        )
        
        if actionRequired {
            await applyFeedback(feedback: feedbackText)
        }
    }
    
    public func handleApproval(_ approval: SendableContent) async {
        let approvalDict = approval.toAnyDict()
        guard let taskID = approvalDict["task_id"] as? String else {
            return
        }
        
        let tasksCompleted = (try? await getBrainStateValue(key: "tasks_completed", defaultValue: SendableContent(["value": 0]))?.toAnyDict()["value"] as? Int) ?? 0
        try? await updateBrainState(key: "tasks_completed", value: SendableContent(["value": tasksCompleted + 1]))
        
        currentTask = nil
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": NSNull()]))
        
        try? await sendStatusUpdate(status: "Task \(taskID) approved and completed")
    }
    
    public func handleRejection(_ rejection: SendableContent) async {
        let rejectionDict = rejection.toAnyDict()
        guard let taskID = rejectionDict["task_id"] as? String else {
            return
        }
        
        let reason = rejectionDict["reason"] as? String ?? ""
        
        currentTask?["status"] = "rejected"
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": currentTask ?? [:]]))
        
        try? await addKnowledge(
            category: "rejections",
            key: taskID,
            value: SendableContent([
                "reason": reason,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ])
        )
        
        try? await sendStatusUpdate(status: "Task \(taskID) rejected: \(reason)")
    }
    
    public func handleHeartbeat(_ heartbeat: SendableContent) async {
        let heartbeatDict = heartbeat.toAnyDict()
        guard let state = heartbeatDict["state"] as? [String: Any] else {
            return
        }
        
        for (key, value) in state {
            let wrappedValue: [String: Any]
            if let dictValue = value as? [String: Any] {
                wrappedValue = dictValue
            } else {
                wrappedValue = ["value": value]
            }
            await saveMemory(key: "heartbeat_\(key)", value: SendableContent(wrappedValue))
        }
    }
    
    private func handleUnknownMessage(_ message: Message) async {
        try? await addKnowledge(
            category: "unknown_messages",
            key: message.id,
            value: SendableContent([
                "message_type": message.messageType.rawValue,
                "from": message.fromAI,
                "content": message.content.toAnyDict(),
                "timestamp": message.timestamp
            ])
        )
    }
    
    private func generateCode(description: String) async -> String {
        let language = (try? await getBrainStateValue(key: "preferred_language", defaultValue: "swift") as? String) ?? "swift"
        
        if language == "swift" {
            return await generateSwiftCode(description: description)
        } else if language == "python" {
            return await generatePythonCode(description: description)
        } else {
            return "// Code for: \(description)\n// Language: \(language)\n"
        }
    }
    
    private func generateSwiftCode(description: String) async -> String {
        var code = """
"/"\(description)"/

import Foundation

func main() {
    // Implementation
}

main()
"""
        return code
    }
    
    private func generatePythonCode(description: String) async -> String {
        var code = """
"/"\(description)"/

def main():
    # Implementation
    pass

if __name__ == "__main__":
    main()
"""
        return code
    }
    
    private func applyFeedback(feedback: String) async {
        try? await addKnowledge(
            category: "improvements",
            key: "latest",
            value: [
                "feedback": feedback,
                "applied": true,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
    }
    
    private func sendStatusUpdate(status: String) async throws {
        guard let overseer = findOverseer() else {
            return
        }
        
        let message = MessageBuilder.createStatusMessage(
            fromAI: roleConfig.name,
            toAI: overseer,
            status: status
        )
        
        _ = try await sendMessage(message)
    }
    
    private func findOverseer() -> String? {
        for (roleName, roleConfig) in system.roles {
            if roleConfig.roleType == .overseer {
                return roleName
            }
        }
        return nil
    }
    
    public func getCapabilities() async -> [String] {
        return [
            "write_code",
            "implement_features",
            "fix_bugs",
            "refactor_code",
            "write_tests",
            "document_code",
            "apply_feedback",
            "submit_for_review"
        ]
    }
    
    public func getStatus() async -> SendableContent {
        return SendableContent([
            "role": "CoderAI",
            "current_task": currentTask ?? [:],
            "task_history_count": taskHistory.count,
            "code_history_count": codeHistory.count,
            "capabilities": await getCapabilities()
        ])
    }
}
