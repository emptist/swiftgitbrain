import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testMessageCreation() {
    let message = Message(
        id: "test_id",
        fromAI: "coder",
        toAI: "overseer",
        messageType: .task,
        content: ["task_id": "001", "description": "Test task"],
        priority: 1
    )
    
    #expect(message.id == "test_id")
    #expect(message.fromAI == "coder")
    #expect(message.toAI == "overseer")
    #expect(message.messageType == .task)
    #expect(message.priority == 1)
}

@Test
func testMessageBuilderCreateTaskMessage() {
    let message = MessageBuilder.createTaskMessage(
        fromAI: "overseer",
        toAI: "coder",
        taskID: "task_001",
        taskDescription: "Implement feature",
        taskType: "coding",
        priority: 1
    )
    
    #expect(message.messageType == .task)
    #expect(message.fromAI == "overseer")
    #expect(message.toAI == "coder")
    #expect(message.content["task_id"] as? String == "task_001")
    #expect(message.content["description"] as? String == "Implement feature")
}

@Test
func testMessageBuilderCreateCodeMessage() {
    let message = MessageBuilder.createCodeMessage(
        fromAI: "coder",
        toAI: "overseer",
        taskID: "task_001",
        code: "func main() {}",
        language: "swift",
        files: ["file.swift"]
    )
    
    #expect(message.messageType == .code)
    #expect(message.content["code"] as? String == "func main() {}")
    #expect(message.content["language"] as? String == "swift")
}

@Test
func testMessageBuilderCreateApprovalMessage() {
    let message = MessageBuilder.createApprovalMessage(
        fromAI: "overseer",
        toAI: "coder",
        taskID: "task_001",
        approved: true,
        reason: "Code meets standards"
    )
    
    #expect(message.messageType == .approval)
    #expect(message.content["approved"] as? Bool == true)
    #expect(message.content["reason"] as? String == "Code meets standards")
}

@Test
func testMessageBuilderCreateRejectionMessage() {
    let message = MessageBuilder.createApprovalMessage(
        fromAI: "overseer",
        toAI: "coder",
        taskID: "task_001",
        approved: false,
        reason: "Code does not meet standards"
    )
    
    #expect(message.messageType == .rejection)
    #expect(message.content["approved"] as? Bool == false)
}

@Test
func testMessageBuilderCreateStatusMessage() {
    let message = MessageBuilder.createStatusMessage(
        fromAI: "coder",
        toAI: "overseer",
        status: "Task completed",
        details: ["task_id": "task_001"]
    )
    
    #expect(message.messageType == .status)
    #expect(message.content["status"] as? String == "Task completed")
}
