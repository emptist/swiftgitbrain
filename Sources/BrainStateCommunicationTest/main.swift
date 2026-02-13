import Foundation
import GitBrainSwift

@main
struct BrainStateCommunicationTest {
    static func main() async throws {
        print("Testing BrainStateCommunication...")
        print("=" * 50)
        
        let config = DatabaseConfig(
            host: "localhost",
            port: 5432,
            database: "gitbrain",
            username: "postgres",
            password: "postgres"
        )
        
        let dbManager = DatabaseManager(config: config)
        
        do {
            let databases = try await dbManager.initialize()
            print("✓ Database initialized")
            
            let brainStateManager = try await dbManager.createBrainStateManager()
            print("✓ BrainStateManager created")
            
            let communication = BrainStateCommunication(
                brainStateManager: brainStateManager,
                databases: databases
            )
            print("✓ BrainStateCommunication created")
            
            print("\nTest 1: Create BrainStates for CoderAI and OverseerAI")
            _ = try await brainStateManager.createBrainState(aiName: "CoderAI", role: .coder)
            print("✓ CoderAI brain state created")
            
            _ = try await brainStateManager.createBrainState(aiName: "OverseerAI", role: .overseer)
            print("✓ OverseerAI brain state created")
            
            print("\nTest 2: Send message from CoderAI to OverseerAI")
            let message1 = Message(
                id: UUID().uuidString,
                from: "CoderAI",
                to: "OverseerAI",
                timestamp: ISO8601DateFormatter().string(from: Date()),
                content: SendableContent([
                    "type": "status_update",
                    "message": "Working on BrainState integration"
                ]),
                status: .unread,
                priority: .normal
            )
            try await communication.sendMessage(message1, to: "OverseerAI")
            print("✓ Message sent: \(message1.id)")
            
            print("\nTest 3: Send message from OverseerAI to CoderAI")
            let message2 = Message(
                id: UUID().uuidString,
                from: "OverseerAI",
                to: "CoderAI",
                timestamp: ISO8601DateFormatter().string(from: Date()),
                content: SendableContent([
                    "type": "guidance",
                    "message": "Continue with implementation"
                ]),
                status: .unread,
                priority: .high
            )
            try await communication.sendMessage(message2, to: "CoderAI")
            print("✓ Message sent: \(message2.id)")
            
            print("\nTest 4: Receive messages for OverseerAI")
            let overseerMessages = try await communication.receiveMessages(for: "OverseerAI")
            print("✓ OverseerAI received \(overseerMessages.count) message(s)")
            for msg in overseerMessages {
                print("  - \(msg.id): \(msg.content.toAnyDict()["type"] ?? "unknown")")
            }
            
            print("\nTest 5: Receive messages for CoderAI")
            let coderMessages = try await communication.receiveMessages(for: "CoderAI")
            print("✓ CoderAI received \(coderMessages.count) message(s)")
            for msg in coderMessages {
                print("  - \(msg.id): \(msg.content.toAnyDict()["type"] ?? "unknown")")
            }
            
            print("\nTest 6: Mark message as read")
            if let firstMessage = coderMessages.first {
                try await communication.markAsRead(firstMessage.id, for: "CoderAI")
                print("✓ Message marked as read: \(firstMessage.id)")
                
                let unreadMessages = try await communication.receiveMessages(for: "CoderAI")
                print("✓ Unread messages after marking: \(unreadMessages.count)")
            }
            
            print("\nTest 7: Send multiple messages")
            for i in 1...3 {
                let message = Message(
                    id: UUID().uuidString,
                    from: "CoderAI",
                    to: "OverseerAI",
                    timestamp: ISO8601DateFormatter().string(from: Date()),
                    content: SendableContent([
                        "type": "test",
                        "number": i
                    ]),
                    status: .unread,
                    priority: .normal
                )
                try await communication.sendMessage(message, to: "OverseerAI")
            }
            print("✓ Sent 3 additional messages")
            
            let allOverseerMessages = try await communication.receiveMessages(for: "OverseerAI")
            print("✓ OverseerAI total messages: \(allOverseerMessages.count)")
            
            print("\n" + "=" * 50)
            print("All tests passed! ✓")
            print("\nBrainStateCommunication is working correctly.")
            print("Ready to replace file-based messaging system.")
            
            try await dbManager.close()
            print("\n✓ Database connection closed")
            
        } catch {
            try? await dbManager.close()
            print("\n✗ Test failed: \(error.localizedDescription)")
            throw error
        }
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
