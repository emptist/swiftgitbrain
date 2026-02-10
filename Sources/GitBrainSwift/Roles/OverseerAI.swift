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
        let initialized = try await getBrainStateValue(key: "initialized", defaultValue: SendableContent(["value": false]))?.toAnyDict()["value"] as? Bool ?? false
        
        if !initialized {
            try await updateBrainState(key: "initialized", value: SendableContent(["value": true]))
            try await updateBrainState(key: "review_queue", value: SendableContent(["value": []]))
            try await updateBrainState(key: "review_history", value: SendableContent(["value": []]))
            try await updateBrainState(key: "approved_tasks", value: SendableContent(["value": []]))
            try await updateBrainState(key: "rejected_tasks", value: SendableContent(["value": []]))
            try await updateBrainState(key: "review_criteria", value: SendableContent([
                "code_quality": true,
                "correctness": true,
                "best_practices": true,
                "documentation": true,
                "testing": true
            ]))
            try await updateBrainState(key: "strictness", value: SendableContent(["value": "medium"]))
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
    
    public func handleTask(_ task: SendableContent) async {
    }
    
    public func handleFeedback(_ feedback: SendableContent) async {
    }
    
    public func handleApproval(_ approval: SendableContent) async {
    }
    
    public func handleRejection(_ rejection: SendableContent) async {
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
    
    private func handleCodeSubmission(_ message: Message) async {
        let contentDict = message.content.toAnyDict()
        guard let taskID = contentDict["task_id"] as? String else {
            return
        }
        
        let submission: [String: Any] = [
            "task_id": taskID,
            "code": contentDict["code"] as? String ?? "",
            "language": contentDict["language"] as? String ?? "swift",
            "files": contentDict["files"] as? [String] ?? [],
            "from_ai": message.fromAI,
            "message_id": message.id,
            "timestamp": message.timestamp,
            "status": "pending"
        ]
        
        reviewQueue.append(reviewItem)
        try? await updateBrainState(key: "review_queue", value: SendableContent(["value": reviewQueue]))
    }
    
    private func handleStatusUpdate(_ message: Message) async {
        let contentDict = message.content.toAnyDict()
        guard let status = contentDict["status"] as? String else {
            return
        }
        
        try? await addKnowledge(
            category: "status_updates",
            key: message.id,
            value: SendableContent([
                "from_ai": message.fromAI,
                "status": status,
                "details": contentDict["details"] as? [String: Any] ?? [:],
                "timestamp": message.timestamp
            ])
        )
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
    
    public func reviewCode(taskID: String) async -> SendableContent? {
        guard let index = reviewQueue.firstIndex(where: { ($0["task_id"] as? String) == taskID }) else {
            return nil
        }
        
        var reviewItem = reviewQueue[index]
        reviewItem["status"] = "reviewing"
        try? await updateBrainState(key: "review_queue", value: SendableContent(["value": reviewQueue]))
        
        let reviewResult = await performReview(reviewItem)
        let reviewResultTaskData = TaskData(reviewResult)
        
        reviewQueue.remove(at: index)
        reviewHistory.append(reviewResult)
        try? await updateBrainState(key: "review_queue", value: SendableContent(["value": reviewQueue]))
        try? await updateBrainState(key: "review_history", value: SendableContent(["value": reviewHistory]))
        
        return SendableContent(reviewResult)
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
            approvedTasks.append(reviewResult)
            try? await updateBrainState(key: "approved_tasks", value: SendableContent(["value": approvedTasks]))
        } else {
            rejectedTasks.append(reviewResult)
            try? await updateBrainState(key: "rejected_tasks", value: SendableContent(["value": rejectedTasks]))
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
    
    private func shouldApprove(comments: [[String: Any]]) async -> Bool {
        let defaultValue = SendableContent(["value": "medium"])
        let strictnessContent = (try? await getBrainStateValue(key: "strictness", defaultValue: defaultValue)) ?? defaultValue
        let strictness = strictnessContent.data["value"] as? String ?? "medium"
        
        let hasWarnings = comments.contains { ($0["type"] as? String) == "warning" }
        let hasErrors = comments.contains { ($0["type"] as? String) == "error" }
        
        if hasErrors {
            return false
        }
        
        return criticalComments.isEmpty
    }
    
    public func approveCode(taskID: String, coder: String = "coder") async throws -> URL {
        guard let review = reviewHistory.first(where: { ($0["task_id"] as? String) == taskID }) else {
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
    
    public func rejectCode(taskID: String, reason: String, coder: String = "coder") async throws -> URL {
        guard let review = reviewHistory.first(where: { ($0["task_id"] as? String) == taskID }) else {
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
    
    public func requestChanges(taskID: String, feedback: String, coder: String = "coder") async throws -> URL {
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
    
    public func assignTask(taskID: String, coder: String = "coder", description: String, taskType: String = "coding") async throws -> URL {
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
            value: SendableContent([
                "description": description,
                "type": taskType,
                "assigned_to": coder,
                "assigned_at": ISO8601DateFormatter().string(from: Date())
            ])
        )
        
        let issueURL = try await sendMessage(message)
        return issueURL.absoluteString
    }
    
    public func getCapabilities() async -> [String] {
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
    
    public func getStatus() async -> SendableContent {
        return SendableContent([
            "role": "OverseerAI",
            "review_queue_count": reviewQueue.count,
            "review_history_count": reviewHistory.count,
            "approved_tasks_count": approvedTasks.count,
            "rejected_tasks_count": rejectedTasks.count,
            "capabilities": await getCapabilities()
        ])
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
