import Foundation

public struct CoderAI: @unchecked Sendable, BaseRole {
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
        
        func getCurrentTask() -> TaskData? {
            return currentTask.map { TaskData($0) }
        }
        
        func updateCurrentTask(key: String, value: Any) {
            if currentTask != nil {
                currentTask?[key] = value
            }
        }
        
        func addToTaskHistory(_ item: TaskData) {
            taskHistory.append(item.data)
        }
        
        func getTaskHistory() -> TaskData {
            return TaskData(["task_history": taskHistory])
        }
        
        func getTaskHistoryCount() -> Int {
            return taskHistory.count
        }
        
        func addToCodeHistory(_ item: TaskData) {
            codeHistory.append(item.data)
        }
        
        func getCodeHistory() -> TaskData {
            return TaskData(["code_history": codeHistory])
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
        let initialized = try await getBrainStateValue(key: "initialized", defaultValue: false) as? Bool ?? false
        
        if !initialized {
            try await updateBrainState(key: "initialized", value: TaskData(["initialized": true]))
            try await updateBrainState(key: "current_task", value: TaskData([:]))
            try await updateBrainState(key: "task_history", value: TaskData(["task_history": []]))
            try await updateBrainState(key: "code_history", value: TaskData(["code_history": []]))
            try await updateBrainState(key: "preferred_language", value: TaskData(["preferred_language": "swift"]))
            try await updateBrainState(key: "coding_style", value: TaskData(["coding_style": "clean"]))
        }
    }
    
    public func processMessage(_ message: Message) async {
        switch message.messageType {
        case .task:
            await handleTask(TaskData(message.content))
        case .feedback:
            await handleFeedback(TaskData(message.content))
        case .approval:
            await handleApproval(TaskData(message.content))
        case .rejection:
            await handleRejection(TaskData(message.content))
        case .heartbeat:
            await handleHeartbeat(TaskData(message.content))
        default:
            await handleUnknownMessage(message)
        }
    }
    
    public func handleTask(_ task: TaskData) async {
        let taskData = task.data
        guard let taskID = taskData["task_id"] as? String,
              let description = taskData["description"] as? String else {
            return
        }
        
        let newTask: [String: Any] = [
            "task_id": taskID,
            "description": description,
            "status": "assigned",
            "assigned_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        await storage.setCurrentTask(newTask)
        let currentTaskValue = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: currentTaskValue ?? TaskData([:]))
    }
    
    public func handleFeedback(_ feedback: TaskData) async {
        let feedbackData = feedback.data
        guard let taskID = feedbackData["task_id"] as? String,
              let feedbackText = feedbackData["feedback"] as? String else {
            return
        }
        
        let actionRequired = feedbackData["action_required"] as? Bool ?? false
        
        let feedbackRecord: [String: Any] = [
            "task_id": taskID,
            "feedback": feedbackText,
            "action_required": actionRequired,
            "received_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        let feedbackRecordTaskData = TaskData(feedbackRecord)
        
        await storage.addToTaskHistory(feedbackRecordTaskData)
        let taskHistoryValue = await storage.getTaskHistory()
        try? await updateBrainState(key: "task_history", value: taskHistoryValue)
        
        if actionRequired {
            await applyFeedback(taskID: taskID, feedback: feedbackText)
        }
    }
    
    public func handleApproval(_ approval: TaskData) async {
        let approvalData = approval.data
        guard let taskID = approvalData["task_id"] as? String else {
            return
        }
        
        await storage.updateCurrentTask(key: "status", value: "approved")
        let currentTaskValue = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: currentTaskValue ?? TaskData([:]))
    }
    
    public func handleRejection(_ rejection: TaskData) async {
        let rejectionData = rejection.data
        guard let taskID = rejectionData["task_id"] as? String else {
            return
        }
        
        await storage.updateCurrentTask(key: "status", value: "rejected")
        let currentTaskValue = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: currentTaskValue ?? TaskData([:]))
    }
    
    public func handleHeartbeat(_ heartbeat: TaskData) async {
        let heartbeatData = heartbeat.data
        guard let state = heartbeatData["state"] as? [String: Any] else {
            return
        }
        
        try? await updateBrainState(key: "last_heartbeat", value: state)
    }
    
    public func handleUnknownMessage(_ message: Message) async {
    }
    
    public nonisolated func implementTask() async -> TaskData? {
        return await withUnsafeContinuation { continuation in
            Task {
                let result = await self.implementTaskInternal()
                continuation.resume(returning: result)
            }
        }
    }
    
    private func implementTaskInternal() async -> TaskData? {
        guard let currentTaskTaskData = await storage.getCurrentTask() else {
            return nil
        }
        
        let currentTask = currentTaskTaskData.data
        
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
        
        let codeSubmissionTaskData = TaskData(codeSubmission)
        
        await storage.addToCodeHistory(codeSubmissionTaskData)
        let codeHistoryValue = await storage.getCodeHistory()
        try? await updateBrainState(key: "code_history", value: codeHistoryValue)
        
        await storage.updateCurrentTask(key: "status", value: "completed")
        await storage.updateCurrentTask(key: "completed_at", value: ISO8601DateFormatter().string(from: Date()))
        let currentTaskValue = await storage.getCurrentTask()
        try? await updateBrainState(key: "current_task", value: currentTaskValue ?? TaskData([:]))
        
        return codeSubmissionTaskData
    }
    
    public func submitCode(reviewer: String = "overseer") async throws -> String {
        guard let currentTask = await storage.getCurrentTask() else {
            return ""
        }
        
        guard let codeSubmission = await implementTask() else {
            return ""
        }
        
        let message = MessageBuilder.createCodeMessage(
            fromAI: roleConfig.name,
            toAI: reviewer,
            taskID: codeSubmission["task_id"] ?? "",
            code: codeSubmission["code"] ?? "",
            language: codeSubmission["language"] ?? "swift",
            files: codeSubmission["files"] ?? []
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    private func applyFeedback(taskID: String, feedback: String) async {
    }
    
    private func generateCode(description: String) async -> String {
        let language = (try? await getBrainStateValue(key: "preferred_language", defaultValue: "swift") as? String) ?? "swift"
        
        switch language.lowercased() {
        case "python":
            return await generatePythonCode(description: description)
        case "javascript", "js":
            return await generateJavaScriptCode(description: description)
        case "swift":
            return await generateSwiftCode(description: description)
        default:
            return await generateSwiftCode(description: description)
        }
    }
    
    private func generateSwiftCode(description: String) async -> String {
        let code = """
// \(description)

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
# \(description)

def main():
    # Implementation for: \(description)
    pass

if __name__ == "__main__":
    main()
"""
        return code
    }
    
    private func generateJavaScriptCode(description: String) async -> String {
        let code = """
// \(description)

function main() {
    // Implementation for: \(description)
}

main();
"""
        return code
    }
    
    public nonisolated func getCapabilities() -> [String] {
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
    
    public nonisolated func getStatus() async -> TaskData {
        return await withUnsafeContinuation { continuation in
            Task {
                let status = await self.getStatusInternal()
                continuation.resume(returning: status)
            }
        }
    }
    
    private func getStatusInternal() async -> TaskData {
        let currentTaskValue = await storage.getCurrentTask()
        let taskHistoryCount = await storage.getTaskHistoryCount()
        let codeHistoryCount = await storage.getCodeHistoryCount()
        
        let status: [String: Any] = [
            "role": "CoderAI",
            "current_task": currentTaskValue ?? [:],
            "task_history_count": taskHistoryCount,
            "code_history_count": codeHistoryCount,
            "capabilities": getCapabilities()
        ]
        return TaskData(status)
    }
}
