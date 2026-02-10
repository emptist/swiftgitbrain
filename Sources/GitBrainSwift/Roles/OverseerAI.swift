import Foundation

public struct OverseerAI: @unchecked Sendable, BaseRole {
    public let system: SystemConfig
    public let roleConfig: RoleConfig
    public let communication: any CommunicationProtocol
    public let memoryManager: any BrainStateManagerProtocol
    public let memoryStore: any MemoryStoreProtocol
    public let knowledgeBase: any KnowledgeBaseProtocol
    
    private actor Storage {
        var reviewQueue: [[String: Any]] = []
        var reviewHistory: [[String: Any]] = []
        var approvedTasks: [[String: Any]] = []
        var rejectedTasks: [[String: Any]] = []
        
        func addToReviewQueue(_ item: [String: Any]) {
            reviewQueue.append(item)
        }
        
        func getReviewQueue() -> TaskData {
            return TaskData(["review_queue": reviewQueue])
        }
        
        func updateReviewQueueStatus(taskID: String, status: String) {
            if let index = reviewQueue.firstIndex(where: { ($0["task_id"] as? String) == taskID }) {
                reviewQueue[index]["status"] = status
            }
        }
        
        func findReviewItem(taskID: String) -> TaskData? {
            guard let index = reviewQueue.firstIndex(where: { ($0["task_id"] as? String) == taskID }) else {
                return nil
            }
            return TaskData(reviewQueue[index])
        }
        
        func updateReviewItemStatus(taskID: String, status: String) {
            if let index = reviewQueue.firstIndex(where: { ($0["task_id"] as? String) == taskID }) {
                reviewQueue[index]["status"] = status
            }
        }
        
        func removeFromReviewQueue(taskID: String) -> Bool {
            guard let index = reviewQueue.firstIndex(where: { ($0["task_id"] as? String) == taskID }) else {
                return false
            }
            reviewQueue.remove(at: index)
            return true
        }
        
        func addToReviewHistory(_ item: TaskData) {
            reviewHistory.append(item.data)
        }
        
        func getReviewHistory() -> TaskData {
            return TaskData(["review_history": reviewHistory])
        }
        
        func addToApprovedTasks(_ item: TaskData) {
            approvedTasks.append(item.data)
        }
        
        func addToRejectedTasks(_ item: TaskData) {
            rejectedTasks.append(item.data)
        }
        
        func findInReviewHistory(taskID: String) -> TaskData? {
            guard let item = reviewHistory.first(where: { ($0["task_id"] as? String) == taskID }) else {
                return nil
            }
            return TaskData(item)
        }
        
        func getReviewQueueCount() -> Int {
            return reviewQueue.count
        }
        
        func getReviewHistoryCount() -> Int {
            return reviewHistory.count
        }
        
        func getApprovedTasksCount() -> Int {
            return approvedTasks.count
        }
        
        func getRejectedTasksCount() -> Int {
            return rejectedTasks.count
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
            try await updateBrainState(key: "review_queue", value: TaskData(["review_queue": []]))
            try await updateBrainState(key: "review_history", value: TaskData(["review_history": []]))
            try await updateBrainState(key: "approved_tasks", value: TaskData(["approved_tasks": []]))
            try await updateBrainState(key: "rejected_tasks", value: TaskData(["rejected_tasks": []]))
            try await updateBrainState(key: "review_criteria", value: TaskData([
                "code_quality": true,
                "correctness": true,
                "best_practices": true,
                "documentation": true,
                "testing": true
            ]))
            try await updateBrainState(key: "strictness", value: TaskData(["strictness": "medium"]))
        }
    }
    
    public func processMessage(_ message: Message) async {
        switch message.messageType {
        case .code:
            await handleCodeSubmission(message)
        case .status:
            await handleStatusUpdate(message)
        case .heartbeat:
            await handleHeartbeat(TaskData(message.content))
        default:
            await handleUnknownMessage(message)
        }
    }
    
    public func handleTask(_ task: TaskData) async {
    }
    
    public func handleFeedback(_ feedback: TaskData) async {
    }
    
    public func handleApproval(_ approval: TaskData) async {
    }
    
    public func handleRejection(_ rejection: TaskData) async {
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
    
    public func handleCodeSubmission(_ message: Message) async {
        let codeData = message.content
        
        guard let taskID = codeData["task_id"] as? String,
              let code = codeData["code"] as? String else {
            return
        }
        
        let submission: [String: Any] = [
            "task_id": taskID,
            "code": code,
            "language": codeData["language"] as? String ?? "swift",
            "files": codeData["files"] as? [String] ?? [],
            "submitted_by": message.fromAI,
            "submitted_at": ISO8601DateFormatter().string(from: Date()),
            "status": "pending"
        ]
        
        await storage.addToReviewQueue(submission)
        let reviewQueueValue = await storage.getReviewQueue()
        try? await updateBrainState(key: "review_queue", value: reviewQueueValue)
    }
    
    public func handleStatusUpdate(_ message: Message) async {
        let statusData = message.content
        
        guard let taskID = statusData["task_id"] as? String,
              let status = statusData["status"] as? String else {
            return
        }
        
        if status == "completed" {
            await storage.updateReviewQueueStatus(taskID: taskID, status: "ready_for_review")
            let reviewQueueValue = await storage.getReviewQueue()
            try? await updateBrainState(key: "review_queue", value: reviewQueueValue)
        }
    }
    
    public nonisolated func reviewCode(taskID: String) async -> [String: Any]? {
        return await withUnsafeContinuation { continuation in
            Task {
                let result = await self.reviewCodeInternal(taskID: taskID)
                continuation.resume(returning: result)
            }
        }
    }
    
    private func reviewCodeInternal(taskID: String) async -> [String: Any]? {
        guard let reviewItemTaskData = await storage.findReviewItem(taskID: taskID) else {
            return nil
        }
        
        let reviewItem = reviewItemTaskData.data
        
        await storage.updateReviewItemStatus(taskID: taskID, status: "reviewing")
        let reviewQueueValue = await storage.getReviewQueue()
        try? await updateBrainState(key: "review_queue", value: reviewQueueValue)
        
        let reviewResult = await performReview(reviewItem)
        let reviewResultTaskData = TaskData(reviewResult)
        
        _ = await storage.removeFromReviewQueue(taskID: taskID)
        await storage.addToReviewHistory(reviewResultTaskData)
        
        let updatedReviewQueueValue = await storage.getReviewQueue()
        let reviewHistoryValue = await storage.getReviewHistory()
        try? await updateBrainState(key: "review_queue", value: updatedReviewQueueValue)
        try? await updateBrainState(key: "review_history", value: reviewHistoryValue)
        
        return reviewResult
    }
    
    private func performReview(_ reviewItem: [String: Any]) async -> [String: Any] {
        guard let taskID = reviewItem["task_id"] as? String,
              let code = reviewItem["code"] as? String else {
            return [:]
        }
        
        let comments = await generateReviewComments(code: code)
        let approved = await shouldApprove(comments: comments)
        
        let reviewResult: [String: Any] = [
            "task_id": taskID,
            "code": code,
            "comments": comments,
            "approved": approved,
            "reviewed_at": ISO8601DateFormatter().string(from: Date()),
            "reviewer": roleConfig.name
        ]
        
        let reviewResultTaskData = TaskData(reviewResult)
        
        if approved {
            await storage.addToApprovedTasks(reviewResultTaskData)
            let approvedTasksValue = await storage.getApprovedTasksCount()
            try? await updateBrainState(key: "approved_tasks", value: TaskData(["approved_tasks_count": approvedTasksValue]))
        } else {
            await storage.addToRejectedTasks(reviewResultTaskData)
            let rejectedTasksValue = await storage.getRejectedTasksCount()
            try? await updateBrainState(key: "rejected_tasks", value: TaskData(["rejected_tasks_count": rejectedTasksValue]))
        }
        
        return reviewResult
    }
    
    private func generateReviewComments(code: String) async -> [String] {
        var comments: [String] = []
        
        if code.isEmpty {
            comments.append("Code is empty")
        }
        
        if code.count < 10 {
            comments.append("Code is too short")
        }
        
        if !code.contains("func") && !code.contains("function") && !code.contains("def") {
            comments.append("No function definitions found")
        }
        
        if comments.isEmpty {
            comments.append("Code looks good")
        }
        
        return comments
    }
    
    private func shouldApprove(comments: [String]) async -> Bool {
        let criticalComments = comments.filter { comment in
            comment.contains("empty") || comment.contains("too short") || comment.contains("No function")
        }
        
        return criticalComments.isEmpty
    }
    
    public func approveCode(taskID: String, coder: String = "coder") async throws -> String {
        guard let review = await storage.findInReviewHistory(taskID: taskID) else {
            throw ReviewError.reviewNotFound
        }
        
        let message = MessageBuilder.createApprovalMessage(
            fromAI: roleConfig.name,
            toAI: coder,
            taskID: taskID,
            approved: true,
            reason: "Code meets quality standards"
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    public func rejectCode(taskID: String, reason: String, coder: String = "coder") async throws -> String {
        guard let review = await storage.findInReviewHistory(taskID: taskID) else {
            throw ReviewError.reviewNotFound
        }
        
        let message = MessageBuilder.createApprovalMessage(
            fromAI: roleConfig.name,
            toAI: coder,
            taskID: taskID,
            approved: false,
            reason: reason
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    public func requestChanges(taskID: String, feedback: String, coder: String = "coder") async throws -> String {
        let message = MessageBuilder.createFeedbackMessage(
            fromAI: roleConfig.name,
            toAI: coder,
            taskID: taskID,
            feedback: feedback,
            actionRequired: true
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    public func assignTask(taskID: String, coder: String = "coder", description: String, taskType: String = "coding") async throws -> String {
        let message = MessageBuilder.createTaskMessage(
            fromAI: roleConfig.name,
            toAI: coder,
            taskID: taskID,
            taskDescription: description,
            taskType: taskType,
            priority: 1
        )
        
        try? await addKnowledge(
            category: "assigned_tasks",
            key: taskID,
            value: [
                "description": description,
                "type": taskType,
                "assigned_to": coder,
                "assigned_at": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    public nonisolated func getCapabilities() -> [String] {
        return [
            "review_code",
            "approve_code",
            "reject_code",
            "request_changes",
            "assign_tasks",
            "monitor_progress",
            "provide_feedback"
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
        let reviewQueueCount = await storage.getReviewQueueCount()
        let reviewHistoryCount = await storage.getReviewHistoryCount()
        let approvedTasksCount = await storage.getApprovedTasksCount()
        let rejectedTasksCount = await storage.getRejectedTasksCount()
        
        let status: [String: Any] = [
            "role": "OverseerAI",
            "review_queue_count": reviewQueueCount,
            "review_history_count": reviewHistoryCount,
            "approved_tasks_count": approvedTasksCount,
            "rejected_tasks_count": rejectedTasksCount,
            "capabilities": getCapabilities()
        ]
        return TaskData(status)
    }
}

public enum ReviewError: Error, LocalizedError {
    case reviewNotFound
    case invalidTaskID
    case reviewInProgress
    
    public var errorDescription: String? {
        switch self {
        case .reviewNotFound:
            return "Review not found for the specified task"
        case .invalidTaskID:
            return "Invalid task ID provided"
        case .reviewInProgress:
            return "Review is already in progress for this task"
        }
    }
}
