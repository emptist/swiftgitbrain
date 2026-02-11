import Foundation

public actor FileBasedCommunication {
    private let overseerFolder: URL
    private let fileManager: FileManager
    private let validator = MessageValidator()
    private let pluginManager = PluginManager()
    
    public init(overseerFolder: URL) {
        self.overseerFolder = overseerFolder
        self.fileManager = FileManager.default
        
        try? fileManager.createDirectory(at: overseerFolder, withIntermediateDirectories: true)
    }
    
    public func sendMessageToOverseer(_ content: SendableContent) async throws -> URL {
        let processedContent = try await pluginManager.processOutgoingMessage(content, to: "overseer")
        try await validator.validate(content: processedContent)
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(timestamp)_\(UUID().uuidString).json"
        let fileURL = overseerFolder.appendingPathComponent(filename)
        
        let messageData: [String: Any] = [
            "from": "coder",
            "to": "overseer",
            "timestamp": timestamp,
            "content": processedContent.toAnyDict()
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: messageData)
        try jsonData.write(to: fileURL)
        
        return fileURL
    }
    
    public func sendMessageToCoder(_ content: SendableContent, coderFolder: URL) async throws -> URL {
        let processedContent = try await pluginManager.processOutgoingMessage(content, to: "coder")
        try await validator.validate(content: processedContent)
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(timestamp)_\(UUID().uuidString).json"
        let fileURL = coderFolder.appendingPathComponent(filename)
        
        let messageData: [String: Any] = [
            "from": "overseer",
            "to": "coder",
            "timestamp": timestamp,
            "content": processedContent.toAnyDict()
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: messageData)
        try jsonData.write(to: fileURL)
        
        return fileURL
    }
    
    public func getMessagesForCoder(coderFolder: URL) async throws -> [SendableContent] {
        let messages = try getMessages(in: coderFolder)
        return messages.map { SendableContent($0) }
    }
    
    public func getMessagesForOverseer() async throws -> [SendableContent] {
        let messages = try getMessages(in: overseerFolder)
        return messages.map { SendableContent($0) }
    }
    
    private func getMessages(in folder: URL) throws -> [[String: Any]] {
        guard let files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return []
        }
        
        var messages: [[String: Any]] = []
        
        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let message = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }
            messages.append(message)
        }
        
        return messages.sorted { message1, message2 in
            guard let time1 = message1["timestamp"] as? String,
                  let time2 = message2["timestamp"] as? String else {
                return false
            }
            return time1 < time2
        }
    }
    
    public func clearCoderMessages(coderFolder: URL) async throws {
        try clearMessages(in: coderFolder)
    }
    
    public func clearOverseerMessages() async throws {
        try clearMessages(in: overseerFolder)
    }
    
    private func clearMessages(in folder: URL) throws {
        guard let files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files where file.pathExtension == "json" {
            try? fileManager.removeItem(at: file)
        }
    }
    
    public func registerPlugin(_ plugin: GitBrainPlugin) async throws {
        try await pluginManager.registerPlugin(plugin)
    }
    
    public func unregisterPlugin(named name: String) async throws {
        try await pluginManager.unregisterPlugin(named: name)
    }
    
    public func initializePlugins() async throws {
        try await pluginManager.initializeAll()
    }
    
    public func shutdownPlugins() async throws {
        try await pluginManager.shutdownAll()
    }
    
    public func getRegisteredPlugins() async -> [String] {
        return await pluginManager.getRegisteredPlugins()
    }
}
