import Foundation

public protocol BaseRoleProtocol: Sendable {
    var roleConfig: RoleConfig { get }
    var communication: any CommunicationProtocol { get }
    var memoryManager: any BrainStateManagerProtocol { get }
    var memoryStore: any MemoryStoreProtocol { get }
    var knowledgeBase: any KnowledgeBaseProtocol { get }
    
    func processMessage(_ message: Message) async
    func getStatus() async -> SendableContent
    func cleanup() async
}

public extension BaseRoleProtocol {
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
}
