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
    func handleTask(_ task: TaskData) async
    func handleFeedback(_ feedback: TaskData) async
    func handleApproval(_ approval: TaskData) async
    func handleRejection(_ rejection: TaskData) async
    func handleHeartbeat(_ heartbeat: TaskData) async
    
    func sendMessage(_ message: Message) async throws -> URL
    func receiveMessages() async throws -> [Message]
    func updateBrainState(key: String, value: Any) async throws
    func getBrainStateValue(key: String, defaultValue: Any?) async throws -> Any?
    func saveMemory(key: String, value: Any) async
    func loadMemory(key: String, defaultValue: Any?) async -> Any?
    func addKnowledge(category: String, key: String, value: [String: Any], metadata: [String: Any]?) async throws
    func getKnowledge(category: String, key: String) async throws -> TaskData?
    func searchKnowledge(category: String, query: String) async throws -> [TaskData]
    func getStatus() async -> TaskData
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
        try await memoryManager.updateBrainState(aiName: roleConfig.name, key: key, value: TaskData([key: value]))
    }
    
    func getBrainStateValue(key: String, defaultValue: Any? = nil) async throws -> Any? {
        let result = try await memoryManager.getBrainStateValue(aiName: roleConfig.name, key: key, defaultValue: defaultValue.map { TaskData(["default": $0]) })
        return result?.data[key] ?? result?.data["default"]
    }
    
    func saveMemory(key: String, value: Any) async {
        await memoryStore.set(key, value: value)
    }
    
    func loadMemory(key: String, defaultValue: Any? = nil) async -> Any? {
        return await memoryStore.get(key, defaultValue: defaultValue)
    }
    
    func addKnowledge(category: String, key: String, value: [String: Any], metadata: [String: Any]? = nil) async throws {
        try await knowledgeBase.addKnowledge(category: category, key: key, value: TaskData(value), metadata: metadata.map { TaskData($0) })
    }
    
    func getKnowledge(category: String, key: String) async throws -> TaskData? {
        return try await knowledgeBase.getKnowledge(category: category, key: key)
    }
    
    func searchKnowledge(category: String, query: String) async throws -> [TaskData] {
        return try await knowledgeBase.searchKnowledge(category: category, query: query)
    }
    
    func cleanup() async {
        await memoryStore.clear()
    }
}