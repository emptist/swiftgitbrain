import Foundation

public enum CoderError: Error {
    case noCurrentTask
    case codeGenerationFailed
}

public actor CoderAI: CoderAIProtocol {
    public let system: SystemConfig
    public let roleConfig: RoleConfig
    public let communication: any CommunicationProtocol
    public let memoryManager: any BrainStateManagerProtocol
    public let memoryStore: any MemoryStoreProtocol
    public let knowledgeBase: any KnowledgeBaseProtocol
    
    private actor Storage {
        var currentTask: [String: Any]?
        var taskHistory: [[String: Any]] = []
        var codeHistory: [[String: Any]] = []
        
        func setCurrentTask(_ task: [String: Any]) {
            currentTask = task
        }
        
        func getCurrentTask() -> SendableContent? {
            return currentTask.map { SendableContent($0) }
        }
        
        func updateCurrentTask(key: String, value: Any) {
            if currentTask != nil {
                currentTask?[key] = value
            }
        }
        
        func addToTaskHistory(_ item: SendableContent) {
            taskHistory.append(item.toAnyDict())
        }
        
        func getTaskHistory() -> SendableContent {
            return SendableContent(["task_history": taskHistory])
        }
        
        func getTaskHistoryCount() -> Int {
            return taskHistory.count
        }
        
        func addToCodeHistory(_ item: SendableContent) {
            codeHistory.append(item.toAnyDict())
        }
        
        func getCodeHistory() -> SendableContent {
            return SendableContent(["code_history": codeHistory])
        }
        
        func getCodeHistoryCount() -> Int {
            return codeHistory.count
        }
    }
    
    private let storage = Storage()
    
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
        
        let newTaskContent = SendableContent([
            "task_id": taskID,
            "description": description,
            "status": "assigned",
            "assigned_at": ISO8601DateFormatter().string(from: Date())
        ])
        
        await storage.setCurrentTask(newTaskContent.toAnyDict())
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": newTaskContent.toAnyDict()]))
        
        await storage.addToTaskHistory(newTaskContent)
        let taskHistoryData = await storage.getTaskHistory()
        try? await updateBrainState(key: "task_history", value: SendableContent(taskHistoryData.toAnyDict()))
        
        try? await sendStatusUpdate(status: "Started task: \(taskID)")
    }
    
    public func implementTask() async -> SendableContent? {
        let currentTaskData = await storage.getCurrentTask()
        guard let currentTask = currentTaskData?.toAnyDict() else {
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
        
        await storage.addToCodeHistory(SendableContent(codeSubmission))
        let codeHistoryData = await storage.getCodeHistory()
        try? await updateBrainState(key: "code_history", value: SendableContent(codeHistoryData.toAnyDict()))
        
        await storage.updateCurrentTask(key: "status", value: "completed")
        await storage.updateCurrentTask(key: "completed_at", value: ISO8601DateFormatter().string(from: Date()))
        let updatedTaskData = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": updatedTaskData?.toAnyDict() ?? [:]]))
        
        return SendableContent(codeSubmission)
    }
    
    public func submitCode(reviewer: String = "overseer") async throws -> URL {
        let currentTaskData = await storage.getCurrentTask()
        guard currentTaskData != nil else {
            throw CoderError.noCurrentTask
        }
        
        guard let codeSubmission = await implementTask() else {
            throw CoderError.codeGenerationFailed
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
        
        let issueURL = try await sendMessage(message)
        return issueURL
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
        
        await storage.setCurrentTask([:])
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": NSNull()]))
        
        try? await sendStatusUpdate(status: "Task \(taskID) approved and completed")
    }
    
    public func handleRejection(_ rejection: SendableContent) async {
        let rejectionDict = rejection.toAnyDict()
        guard let taskID = rejectionDict["task_id"] as? String else {
            return
        }
        
        let reason = rejectionDict["reason"] as? String ?? ""
        
        await storage.updateCurrentTask(key: "status", value: "rejected")
        let currentTaskData = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: SendableContent(["value": currentTaskData?.data ?? [:]]))
        
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
    
    public func generateCode(description: String) async -> String {
        let defaultValue = SendableContent(["value": "swift"])
        let languageContent = (try? await getBrainStateValue(key: "preferred_language", defaultValue: defaultValue)) ?? defaultValue
        let language = languageContent.data["value"] as? String ?? "swift"
        
        switch language.lowercased() {
        case "python":
            return await generatePythonCode(description: description)
        case "swift":
            return await generateSwiftCode(description: description)
        default:
            return await generateSwiftCode(description: description)
        }
    }
    
    private func generateSwiftCode(description: String) async -> String {
        let code = """
"/"\(description)"/

import Foundation

func main() {
    // Implementation for: \(description)
}

main()
"""
        return code
    }
    
    private func generatePythonCode(description: String) async -> String {
        let code = """
"/"\(description)"/

def main():
    # Implementation for: \(description)
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
            value: SendableContent([
                "feedback": feedback,
                "applied": true,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ])
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
        let currentTaskData = await storage.getCurrentTask()
        let taskHistoryData = await storage.getTaskHistory()
        let codeHistoryData = await storage.getCodeHistory()
        
        return SendableContent([
            "role": "CoderAI",
            "current_task": currentTaskData?.toAnyDict() ?? [:],
            "task_history_count": taskHistoryData.toAnyDict()["task_history"] as? Int ?? 0,
            "code_history_count": codeHistoryData.toAnyDict()["code_history"] as? Int ?? 0,
            "capabilities": await getCapabilities()
        ])
    }
    
    public func cleanup() async {
        await memoryStore.clear()
    }
}
