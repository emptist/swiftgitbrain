import Foundation

public actor OverseerAI: BaseRole {
    public let system: SystemConfig
    public let roleConfig: RoleConfig
    public let communication: any CommunicationProtocol
    public let memoryManager: any BrainStateManagerProtocol
    public let memoryStore: any MemoryStoreProtocol
    public let knowledgeBase: any KnowledgeBaseProtocol
    
    private var reviewQueue: [[String: Any]] = []
    private var reviewHistory: [[String: Any]] = []
    private var approvedTasks: [[String: Any]] = []
    private var rejectedTasks: [[String: Any]] = []
    
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
            await handleHeartbeat(message.content)
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
        
        let reviewItem: [String: Any] = [
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
        
        let reviewItem = reviewQueue[index]
        reviewItem["status"] = "reviewing"
        try? await updateBrainState(key: "review_queue", value: SendableContent(["value": reviewQueue]))
        
        let reviewResult = await performReview(reviewItem)
        
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
            "comments": comments,
            "approved": approved,
            "reviewed_at": ISO8601DateFormatter().string(from: Date()),
            "reviewer": roleConfig.name
        ]
        
        if approved {
            approvedTasks.append(reviewResult)
            try? await updateBrainState(key: "approved_tasks", value: SendableContent(["value": approvedTasks]))
        } else {
            rejectedTasks.append(reviewResult)
            try? await updateBrainState(key: "rejected_tasks", value: SendableContent(["value": rejectedTasks]))
        }
        
        return reviewResult
    }
    
    private func generateReviewComments(code: String) async -> [[String: Any]] {
        var comments: [[String: Any]] = []
        
        let lines = code.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            if line.contains("TODO") || line.contains("FIXME") {
                comments.append([
                    "line": index + 1,
                    "type": "warning",
                    "message": "Found TODO/FIXME comment"
                ])
            }
            
            if line.contains("print(") && !line.contains("//") {
                comments.append([
                    "line": index + 1,
                    "type": "info",
                    "message": "Consider removing debug print statement"
                ])
            }
        }
        
        if comments.isEmpty {
            comments.append([
                "line": 1,
                "type": "info",
                "message": "Code looks good"
            ])
        }
        
        return comments
    }
    
    private func shouldApprove(comments: [[String: Any]]) async -> Bool {
        let strictness = (try? await getBrainStateValue(key: "strictness", defaultValue: "medium") as? String) ?? "medium"
        
        let hasWarnings = comments.contains { ($0["type"] as? String) == "warning" }
        let hasErrors = comments.contains { ($0["type"] as? String) == "error" }
        
        if hasErrors {
            return false
        }
        
        if strictness == "strict" && hasWarnings {
            return false
        }
        
        return true
    }
    
    public func approveCode(taskID: String, coder: String = "coder") async throws -> String {
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
        
        return try await sendMessage(message)
    }
    
    public func rejectCode(taskID: String, reason: String, coder: String = "coder") async throws -> String {
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
        
        return try await sendMessage(message)
    }
    
    public func requestChanges(taskID: String, feedback: String, coder: String = "coder") async throws -> String {
        let message = MessageBuilder.createFeedbackMessage(
            fromAI: roleConfig.name,
            toAI: coder,
            taskID: taskID,
            feedback: feedback,
            actionRequired: true
        )
        
        return try await sendMessage(message)
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
        
        return try await sendMessage(message)
    }
    
    public func getCapabilities() async -> [String] {
        return [
            "review_code",
            "approve_code",
            "reject_code",
            "request_changes",
            "provide_feedback",
            "assign_tasks",
            "monitor_progress",
            "enforce_quality_standards"
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

public enum ReviewError: Error {
    case reviewNotFound
    case invalidTaskID
    case codeSubmissionNotFound
}
