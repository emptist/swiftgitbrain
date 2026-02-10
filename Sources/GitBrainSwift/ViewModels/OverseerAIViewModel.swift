import Foundation
import Combine
import Observation

@Observable
public class OverseerAIViewModel: @unchecked Sendable {
    public private(set) var overseer: OverseerAI
    public private(set) var reviewQueue: [[String: Any]]
    public private(set) var reviewHistory: [[String: Any]]
    public private(set) var approvedTasks: [[String: Any]]
    public private(set) var rejectedTasks: [[String: Any]]
    public private(set) var status: String = "Idle"
    public private(set) var capabilities: [String]
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(overseer: OverseerAI) {
        self.overseer = overseer
        self.reviewQueue = []
        self.reviewHistory = []
        self.approvedTasks = []
        self.rejectedTasks = []
        self.capabilities = []
    }
    
    public func initialize() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        try await overseer.initialize()
        capabilities = await overseer.getCapabilities()
        status = "Initialized"
    }
    
    public func loadMessages() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        let messages = try await overseer.receiveMessages()
        
        for message in messages {
            await overseer.processMessage(message)
        }
        
        await refreshStatus()
    }
    
    public func reviewCode(taskID: String) async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Reviewing code..."
        
        if let result = await overseer.reviewCode(taskID: taskID) {
            let resultDict = result.toAnyDict()
            status = resultDict["approved"] as? Bool == true ? "Code approved" : "Code rejected"
        } else {
            errorMessage = "Task not found in review queue"
            status = "Error"
        }
        
        await refreshStatus()
    }
    
    public func approveCode(taskID: String, coder: String = "coder") async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Approving code..."
        
        _ = try await overseer.approveCode(taskID: taskID, coder: coder)
        status = "Code approved"
        
        await refreshStatus()
    }
    
    public func rejectCode(taskID: String, reason: String, coder: String = "coder") async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Rejecting code..."
        
        _ = try await overseer.rejectCode(taskID: taskID, reason: reason, coder: coder)
        status = "Code rejected"
        
        await refreshStatus()
    }
    
    public func requestChanges(taskID: String, feedback: String, coder: String = "coder") async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Requesting changes..."
        
        _ = try await overseer.requestChanges(taskID: taskID, feedback: feedback, coder: coder)
        status = "Changes requested"
        
        await refreshStatus()
    }
    
    public func assignTask(taskID: String, coder: String = "coder", description: String, taskType: String = "coding") async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Assigning task..."
        
        _ = try await overseer.assignTask(
            taskID: taskID,
            coder: coder,
            description: description,
            taskType: taskType
        )
        status = "Task assigned"
    }
    
    public func refreshStatus() async {
        let overseerStatus = await overseer.getStatus()
        let overseerStatusDict = overseerStatus.toAnyDict()
        reviewQueue = []
        reviewHistory = overseerStatusDict["review_history"] as? [[String: Any]] ?? []
        approvedTasks = overseerStatusDict["approved_tasks"] as? [[String: Any]] ?? []
        rejectedTasks = overseerStatusDict["rejected_tasks"] as? [[String: Any]] ?? []
        capabilities = overseerStatusDict["capabilities"] as? [String] ?? []
        status = overseerStatusDict["role"] as? String ?? "OverseerAI"
    }
    
    public func getBrainStateValue(key: String) async -> Any? {
        if let result = try? await overseer.getBrainStateValue(key: key, defaultValue: nil) {
            return result.toAnyDict()
        }
        return nil
    }
    
    public func saveMemory(key: String, value: Any) async {
        let wrappedValue: [String: Any]
        if let dictValue = value as? [String: Any] {
            wrappedValue = dictValue
        } else {
            wrappedValue = ["value": value]
        }
        await overseer.saveMemory(key: key, value: SendableContent(wrappedValue))
    }
    
    public func loadMemory(key: String) async -> Any? {
        if let result = await overseer.loadMemory(key: key, defaultValue: nil) {
            return result.toAnyDict()
        }
        return nil
    }
    
    public func addKnowledge(category: String, key: String, value: [String: Any]) async throws {
        try await overseer.addKnowledge(category: category, key: key, value: SendableContent(value))
    }
    
    public func getKnowledge(category: String, key: String) async throws -> [String: Any]? {
        let result = try await overseer.getKnowledge(category: category, key: key)
        return result?.toAnyDict()
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [[String: Any]] {
        let results = try await overseer.searchKnowledge(category: category, query: query)
        return results.map { $0.toAnyDict() }
    }
    
    public func cleanup() async {
        await overseer.cleanup()
        cancellables.removeAll()
    }
}
