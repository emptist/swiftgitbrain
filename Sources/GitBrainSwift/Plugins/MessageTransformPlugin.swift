import Foundation

public struct MessageTransformPlugin: GitBrainPlugin, Sendable {
    public let pluginName = "MessageTransformPlugin"
    public let pluginVersion = "1.0.0"
    public let pluginDescription = "Transforms messages by adding metadata and formatting"
    
    public init() {}
    
    public func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent? {
        var modifiedData = message.toAnyDict()
        
        modifiedData["sent_at"] = ISO8601DateFormatter().string(from: Date())
        modifiedData["recipient"] = to
        
        if let messageType = modifiedData["type"] as? String {
            modifiedData["message_type"] = messageType
        }
        
        return SendableContent(modifiedData)
    }
    
    public func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? {
        var modifiedData = message.toAnyDict()
        
        modifiedData["received_at"] = ISO8601DateFormatter().string(from: Date())
        modifiedData["sender"] = from
        
        return SendableContent(modifiedData)
    }
}
