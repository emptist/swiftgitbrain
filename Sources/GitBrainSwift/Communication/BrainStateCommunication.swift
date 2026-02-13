import Foundation
import Fluent

public actor BrainStateCommunication: @unchecked Sendable {
    private let brainStateManager: BrainStateManager
    private let database: Database
    
    public init(brainStateManager: BrainStateManager, database: Database) {
        self.brainStateManager = brainStateManager
        self.database = database
        GitBrainLogger.info("BrainStateCommunication initialized")
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        GitBrainLogger.debug("Sending message to \(recipient)")
        
        let recipientAIName = recipient
        
        guard let recipientState = try await brainStateManager.loadBrainState(aiName: recipientAIName) else {
            GitBrainLogger.warning("Creating brain state for recipient: \(recipientAIName)")
            _ = try await brainStateManager.createBrainState(aiName: recipientAIName, role: recipientAIName == "OverseerAI" ? .overseer : .coder)
            guard let state = try await brainStateManager.loadBrainState(aiName: recipientAIName) else {
                throw CommunicationError.recipientNotFound
            }
            var stateDict = state.state.toAnyDict()
            if var messages = stateDict["messages"] as? [String: Any] {
                var inbox = messages["inbox"] as? [[String: Any]] ?? []
                inbox.append(message.toDict())
                messages["inbox"] = inbox
            } else {
                stateDict["messages"] = ["inbox": [message.toDict()]]
            }
            let updatedState = SendableContent(stateDict)
            try await brainStateManager.saveBrainState(BrainState(
                aiName: recipientAIName,
                role: state.role,
                version: state.version,
                lastUpdated: ISO8601DateFormatter().string(from: Date()),
                state: updatedState.toAnyDict()
            ))
            try await sendNotification(to: recipientAIName, messageId: message.id)
            GitBrainLogger.info("Message sent to \(recipientAIName): \(message.id)")
            return
        }
        
        var stateDict = recipientState.state.toAnyDict()
        if var messages = stateDict["messages"] as? [String: Any] {
            var inbox = messages["inbox"] as? [[String: Any]] ?? []
            inbox.append(message.toDict())
            messages["inbox"] = inbox
        } else {
            stateDict["messages"] = ["inbox": [message.toDict()]]
        }
        
        let updatedState = SendableContent(stateDict)
        try await brainStateManager.saveBrainState(BrainState(
            aiName: recipientAIName,
            role: recipientState.role,
            version: recipientState.version,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: updatedState.toAnyDict()
        ))
        
        try await sendNotification(to: recipientAIName, messageId: message.id)
        
        GitBrainLogger.info("Message sent to \(recipientAIName): \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        GitBrainLogger.debug("Receiving messages for \(aiName)")
        
        guard let state = try await brainStateManager.loadBrainState(aiName: aiName) else {
            return []
        }
        
        guard let messages = state.state.toAnyDict()["messages"] as? [String: Any],
              let inbox = messages["inbox"] as? [[String: Any]] else {
            return []
        }
        
        let unreadMessages = inbox.compactMap { msgDict -> Message? in
            guard let status = msgDict["status"] as? String,
                  status == MessageStatus.unread.rawValue else {
                return nil
            }
            return Message(from: msgDict)
        }
        
        return unreadMessages
    }
    
    public func markAsRead(_ messageId: String, for aiName: String) async throws {
        GitBrainLogger.debug("Marking message as read: \(messageId)")
        
        guard let state = try await brainStateManager.loadBrainState(aiName: aiName) else {
            throw CommunicationError.brainStateNotFound
        }
        
        var stateDict = state.state.toAnyDict()
        if var messages = stateDict["messages"] as? [String: Any] {
            var inbox = messages["inbox"] as? [[String: Any]] ?? []
            for index in inbox.indices {
                if inbox[index]["id"] as? String == messageId {
                    inbox[index]["status"] = MessageStatus.read.rawValue
                    break
                }
            }
            messages["inbox"] = inbox
            stateDict["messages"] = messages
        }
        
        let updatedState = SendableContent(stateDict)
        try await brainStateManager.saveBrainState(BrainState(
            aiName: aiName,
            role: state.role,
            version: state.version,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: updatedState.toAnyDict()
        ))
        
        GitBrainLogger.info("Message marked as read: \(messageId)")
    }
    
    private func sendNotification(to recipient: String, messageId: String) async throws {
        GitBrainLogger.debug("Notification would be sent: \(recipient)|\(messageId)")
    }
}
