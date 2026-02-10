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
        communication: any MaildirCommunicationProtocol,
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
        let initialized = try await getBrainStateValue(key: "initialized", defaultValue: false) as? Bool ?? false
        
        if !initialized {
            try await updateBrainState(key: "initialized", value: true)
            try await updateBrainState(key: "current_task", value: NSNull())
            try await updateBrainState(key: "task_history", value: [])
            try await updateBrainState(key: "code_history", value: [])
            try await updateBrainState(key: "preferred_language", value: "swift")
            try await updateBrainState(key: "coding_style", value: "clean")
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
    
    public func handleTask(_ task: [String: Any]) async {
        guard let taskID = task["task_id"] as? String,
              let description = task["description"] as? String else {
            return
        }
        
        let taskType = task["type"] as? String ?? "coding"
        
        currentTask = [
            "task_id": taskID,
            "description": description,
            "type": taskType,
            "status": "in_progress",
            "started_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try? await updateBrainState(key: "current_task", value: currentTask ?? [:])
        
        taskHistory.append(currentTask ?? [:])
        try? await updateBrainState(key: "task_history", value: taskHistory)
        
        try? await sendStatusUpdate(status: "Started task: \(taskID)")
    }
    
    public func implementTask() async -> [String: Any]? {
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
            "language": (try? await getBrainStateValue(key: "preferred_language", defaultValue: "swift") as? String) ?? "swift",
            "files": [] as [String],
            "description": "Implementation for task: \(description)"
        ]
        
        codeHistory.append(codeSubmission)
        try? await updateBrainState(key: "code_history", value: codeHistory)
        
        self.currentTask?["status"] = "completed"
        self.currentTask?["completed_at"] = ISO8601DateFormatter().string(from: Date())
        try? await updateBrainState(key: "current_task", value: self.currentTask ?? [:])
        
        return codeSubmission
    }
    
    public func submitCode(reviewer: String = "overseer") async throws -> String {
        guard let currentTask = currentTask else {
            return ""
        }
        
        guard let codeSubmission = await implementTask() else {
            return ""
        }
        
        let message = MessageBuilder.createCodeMessage(
            fromAI: roleConfig.name,
            toAI: reviewer,
            taskID: codeSubmission["task_id"] as? String ?? "",
            code: codeSubmission["code"] as? String ?? "",
            language: codeSubmission["language"] as? String ?? "swift",
            files: codeSubmission["files"] as? [String] ?? []
        )
        
        return try await sendMessage(message)
    }
    
    public func handleFeedback(_ feedback: [String: Any]) async {
        guard let taskID = feedback["task_id"] as? String,
              let feedbackText = feedback["feedback"] as? String else {
            return
        }
        
        let actionRequired = feedback["action_required"] as? Bool ?? false
        
        try? await addKnowledge(
            category: "feedback",
            key: taskID,
            value: [
                "feedback": feedbackText,
                "action_required": actionRequired,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        if actionRequired {
            await applyFeedback(feedback: feedbackText)
        }
    }
    
    public func handleApproval(_ approval: [String: Any]) async {
        guard let taskID = approval["task_id"] as? String else {
            return
        }
        
        let tasksCompleted = (try? await getBrainStateValue(key: "tasks_completed", defaultValue: 0) as? Int) ?? 0
        try? await updateBrainState(key: "tasks_completed", value: tasksCompleted + 1)
        
        currentTask = nil
        try? await updateBrainState(key: "current_task", value: NSNull())
        
        try? await sendStatusUpdate(status: "Task \(taskID) approved and completed")
    }
    
    public func handleRejection(_ rejection: [String: Any]) async {
        guard let taskID = rejection["task_id"] as? String else {
            return
        }
        
        let reason = rejection["reason"] as? String ?? ""
        
        currentTask?["status"] = "rejected"
        try? await updateBrainState(key: "current_task", value: currentTask ?? [:])
        
        try? await addKnowledge(
            category: "rejections",
            key: taskID,
            value: [
                "reason": reason,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        try? await sendStatusUpdate(status: "Task \(taskID) rejected: \(reason)")
    }
    
    public func handleHeartbeat(_ heartbeat: [String: Any]) async {
        guard let state = heartbeat["state"] as? [String: Any] else {
            return
        }
        
        for (key, value) in state {
            await saveMemory(key: "heartbeat_\(key)", value: value)
        }
    }
    
    private func handleUnknownMessage(_ message: Message) async {
        try? await addKnowledge(
            category: "unknown_messages",
            key: message.id,
            value: [
                "message_type": message.messageType.rawValue,
                "from": message.fromAI,
                "content": message.content,
                "timestamp": message.timestamp
            ]
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
        var code = """/"\(description)"/

import Foundation

func main() {
    // Implementation
}

main()
"""
        return code
    }
    
    private func generatePythonCode(description: String) async -> String {
        var code = """/"\(description)"/

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
    
    public func getCapabilities() -> [String] {
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
    
    public func getStatus() async -> [String: Any] {
        return [
            "role": "CoderAI",
            "current_task": currentTask,
            "task_history_count": taskHistory.count,
            "code_history_count": codeHistory.count,
            "capabilities": getCapabilities()
        ]
    }
}
