import Foundation

public protocol CommunicationProtocol: Sendable {
    func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
    func receiveMessages(for role: String) async throws -> [Message]
    func getMessageCount(for role: String) async throws -> Int
    func clearMessages(for role: String) async throws -> Int
}

public protocol BaseRole: Sendable {
    var system: SystemConfig { get }
    var roleConfig: RoleConfig { get }
    var communication: any CommunicationProtocol { get }
    var memoryManager: any BrainStateManagerProtocol { get }
    var memoryStore: any MemoryStoreProtocol { get }
    var knowledgeBase: any KnowledgeBaseProtocol { get }
    
    func processMessage(_ message: Message) async
    func handleTask(_ task: [String: Any]) async
    func handleFeedback(_ feedback: [String: Any]) async
    func handleApproval(_ approval: [String: Any]) async
    func handleRejection(_ rejection: [String: Any]) async
    func handleHeartbeat(_ heartbeat: [String: Any]) async
    
    func sendMessage(_ message: Message) async throws -> URL
    func receiveMessages() async throws -> [Message]
    func updateBrainState(key: String, value: Any) async throws
    func getBrainStateValue(key: String, defaultValue: Any?) async throws -> Any?
    func saveMemory(key: String, value: Any) async
    func loadMemory(key: String, defaultValue: Any?) async -> Any?
    func addKnowledge(category: String, key: String, value: [String: Any], metadata: [String: Any]?) async throws
    func getKnowledge(category: String, key: String) async throws -> [String: Any]?
    func searchKnowledge(category: String, query: String) async throws -> [[String: Any]]
    func getStatus() async -> [String: Any]
    func cleanup() async
}

public extension BaseRole {
    func sendMessage(_ message: Message) async throws -> URL {
        return try await communication.sendMessage(message, from: roleConfig.name, to: message.toAI)
    }
    
    func receiveMessages() async throws -> [Message] {
        return try await communication.receiveMessages(for: roleConfig.name)
    }
    
    func updateBrainState(key: String, value: Any) async throws {
        try await memoryManager.updateBrainState(aiName: roleConfig.name, key: key, value: value)
    }
    
    func getBrainStateValue(key: String, defaultValue: Any? = nil) async throws -> Any? {
        return try await memoryManager.getBrainStateValue(aiName: roleConfig.name, key: key, defaultValue: defaultValue)
    }
    
    func saveMemory(key: String, value: Any) async {
        await memoryStore.set(key, value: value)
    }
    
    func loadMemory(key: String, defaultValue: Any? = nil) async -> Any? {
        return await memoryStore.get(key, defaultValue: defaultValue)
    }
    
    func addKnowledge(category: String, key: String, value: [String: Any], metadata: [String: Any]? = nil) async throws {
        try await knowledgeBase.addKnowledge(category: category, key: key, value: value, metadata: metadata)
    }
    
    func getKnowledge(category: String, key: String) async throws -> [String: Any]? {
        return try await knowledgeBase.getKnowledge(category: category, key: key)
    }
    
    func searchKnowledge(category: String, query: String) async throws -> [[String: Any]] {
        return try await knowledgeBase.searchKnowledge(category: category, query: query)
    }
    
    func cleanup() async {
        await memoryStore.clear()
    }
}