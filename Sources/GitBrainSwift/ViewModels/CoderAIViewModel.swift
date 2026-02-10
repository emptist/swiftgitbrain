import Foundation
import Combine
import Observation

@Observable
public class CoderAIViewModel {
    public private(set) var coder: CoderAI
    public private(set) var currentTask: [String: Any]?
    public private(set) var taskHistory: [[String: Any]]
    public private(set) var codeHistory: [[String: Any]]
    public private(set) var status: String = "Idle"
    public private(set) var capabilities: [String]
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(coder: CoderAI) {
        self.coder = coder
        self.currentTask = nil
        self.taskHistory = []
        self.codeHistory = []
        self.capabilities = coder.getCapabilities()
    }
    
    public func initialize() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        try await coder.initialize()
        status = "Initialized"
    }
    
    public func loadMessages() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        let messages = try await coder.receiveMessages()
        
        for message in messages {
            await coder.processMessage(message)
        }
        
        await refreshStatus()
    }
    
    public func implementTask() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Implementing task..."
        
        if let result = await coder.implementTask() {
            currentTask = result
            status = "Task implemented"
        } else {
            errorMessage = "No current task to implement"
            status = "Error"
        }
    }
    
    public func submitCode(reviewer: String = "overseer") async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        status = "Submitting code..."
        
        _ = try await coder.submitCode(reviewer: reviewer)
        status = "Code submitted"
    }
    
    public func refreshStatus() async {
        let coderStatus = await coder.getStatus()
        currentTask = coderStatus["current_task"] as? [String: Any]
        taskHistory = coderStatus["task_history"] as? [[String: Any]] ?? []
        codeHistory = coderStatus["code_history"] as? [[String: Any]] ?? []
        capabilities = coderStatus["capabilities"] as? [String] ?? []
        status = coderStatus["role"] as? String ?? "CoderAI"
    }
    
    public func getBrainStateValue(key: String) async -> Any? {
        return try? await coder.getBrainStateValue(key: key)
    }
    
    public func saveMemory(key: String, value: Any) async {
        await coder.saveMemory(key: key, value: value)
    }
    
    public func loadMemory(key: String) async -> Any? {
        return await coder.loadMemory(key: key)
    }
    
    public func addKnowledge(category: String, key: String, value: [String: Any]) async throws {
        try await coder.addKnowledge(category: category, key: key, value: value)
    }
    
    public func getKnowledge(category: String, key: String) async throws -> [String: Any]? {
        return try await coder.getKnowledge(category: category, key: key)
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [[String: Any]] {
        return try await coder.searchKnowledge(category: category, query: query)
    }
    
    public func cleanup() async {
        await coder.cleanup()
        cancellables.removeAll()
    }
}
