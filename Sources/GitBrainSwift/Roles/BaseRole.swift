import Foundation

public protocol CommunicationProtocol: Sendable {
    func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
    func receiveMessages(for role: String) async throws -> [Message]
    func getMessageCount(for role: String) async throws -> Int
    func clearMessages(for role: String) async throws -> Int
}

public struct TaskData: @unchecked Sendable {
    public let data: [String: Any]
    
    public init(_ data: [String: Any]) {
        self.data = data
    }
    
    public subscript<T>(key: String) -> T? {
        return data[key] as? T
    }
}

public protocol BaseRole: Sendable {
    var system: SystemConfig { get }
    var roleConfig: RoleConfig { get }
    var communication: any CommunicationProtocol { get }
    var memoryManager: any BrainStateManagerProtocol { get }
    var memoryStore: any MemoryStoreProtocol { get }
    var knowledgeBase: any KnowledgeBaseProtocol { get }
    
    func processMessage(_ message: Message) async
    func handleTask(_ task: SendableContent) async
    func handleFeedback(_ feedback: SendableContent) async
    func handleApproval(_ approval: SendableContent) async
    func handleRejection(_ rejection: SendableContent) async
    func handleHeartbeat(_ heartbeat: SendableContent) async
    
    func sendMessage(_ message: Message) async throws -> URL
    func receiveMessages() async throws -> [Message]
    func updateBrainState(key: String, value: SendableContent) async throws
    func getBrainStateValue(key: String, defaultValue: SendableContent?) async throws -> SendableContent?
    func saveMemory(key: String, value: SendableContent) async
    func loadMemory(key: String, defaultValue: SendableContent?) async -> SendableContent?
    func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent?) async throws
    func getKnowledge(category: String, key: String) async throws -> SendableContent?
    func searchKnowledge(category: String, query: String) async throws -> [SendableContent]
    func getStatus() async -> SendableContent
    func cleanup() async
}

public extension BaseRole {
    func sendMessage(_ message: Message) async throws -> URL {
        return try await communication.sendMessage(message, from: roleConfig.name, to: message.toAI)
    }
    
    func receiveMessages() async throws -> [Message] {
        return try await communication.receiveMessages(for: roleConfig.name)
    }
    
    func updateBrainState(key: String, value: SendableContent) async throws {
        try await memoryManager.updateBrainState(aiName: roleConfig.name, key: key, value: value)
    }
    
    func getBrainStateValue(key: String, defaultValue: SendableContent? = nil) async throws -> SendableContent? {
        return try await memoryManager.getBrainStateValue(aiName: roleConfig.name, key: key, defaultValue: defaultValue)
    }
    
    func saveMemory(key: String, value: SendableContent) async {
        await memoryStore.set(key, value: value)
    }
    
    func loadMemory(key: String, defaultValue: SendableContent? = nil) async -> SendableContent? {
        return await memoryStore.get(key, defaultValue: defaultValue)
    }
    
    func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws {
        try await knowledgeBase.addKnowledge(category: category, key: key, value: value, metadata: metadata)
    }
    
    func getKnowledge(category: String, key: String) async throws -> SendableContent? {
        return try await knowledgeBase.getKnowledge(category: category, key: key)
    }
    
    func searchKnowledge(category: String, query: String) async throws -> [SendableContent] {
        return try await knowledgeBase.searchKnowledge(category: category, query: query)
    }
    
    func cleanup() async {
        await memoryStore.clear()
    }
}