import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testSharedWorktreeCommunicationSendMessage() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let communication = SharedWorktreeCommunication(sharedWorktree: tempDir)
    
    let message = Message(
        id: "test_id",
        fromAI: "coder",
        toAI: "overseer",
        messageType: .task,
        content: ["task_id": "001", "description": "Test task"],
        timestamp: Date().iso8601String,
        priority: 1
    )
    
    let path = try await communication.sendMessage(message, from: "coder", to: "overseer")
    
    #expect(path.path.contains("overseer"))
    #expect(path.pathExtension == "json")
    #expect(FileManager.default.fileExists(atPath: path.path))
}

@Test
func testSharedWorktreeCommunicationReceiveMessages() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let communication = SharedWorktreeCommunication(sharedWorktree: tempDir)
    
    _ = try await communication.setupRoleDirectory(for: "coder")
    
    let message = Message(
        id: "test_id",
        fromAI: "overseer",
        toAI: "coder",
        messageType: .task,
        content: ["task_id": "001", "description": "Test task"],
        timestamp: Date().iso8601String,
        priority: 1
    )
    
    _ = try await communication.sendMessage(message, from: "overseer", to: "coder")
    
    let messages = try await communication.receiveMessages(for: "coder")
    
    #expect(messages.count == 1)
    #expect(messages[0].id == "test_id")
    #expect(messages[0].fromAI == "overseer")
    #expect(messages[0].toAI == "coder")
}

@Test
func testSharedWorktreeCommunicationGetMessageCount() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let communication = SharedWorktreeCommunication(sharedWorktree: tempDir)
    
    _ = try await communication.setupRoleDirectory(for: "coder")
    
    let count1 = try await communication.getMessageCount(for: "coder")
    #expect(count1 == 0)
    
    let message = Message(
        id: "test_id",
        fromAI: "overseer",
        toAI: "coder",
        messageType: .task,
        content: ["task_id": "001"],
        timestamp: Date().iso8601String,
        priority: 1
    )
    
    _ = try await communication.sendMessage(message, from: "overseer", to: "coder")
    
    let count2 = try await communication.getMessageCount(for: "coder")
    #expect(count2 == 1)
}

@Test
func testSharedWorktreeCommunicationClearMessages() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let communication = SharedWorktreeCommunication(sharedWorktree: tempDir)
    
    _ = try await communication.setupRoleDirectory(for: "coder")
    
    let message = Message(
        id: "test_id",
        fromAI: "overseer",
        toAI: "coder",
        messageType: .task,
        content: ["task_id": "001"],
        timestamp: Date().iso8601String,
        priority: 1
    )
    
    _ = try await communication.sendMessage(message, from: "overseer", to: "coder")
    
    let count1 = try await communication.getMessageCount(for: "coder")
    #expect(count1 == 1)
    
    let cleared = try await communication.clearMessages(for: "coder")
    #expect(cleared == 1)
    
    let count2 = try await communication.getMessageCount(for: "coder")
    #expect(count2 == 0)
}