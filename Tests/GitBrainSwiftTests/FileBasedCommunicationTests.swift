import Testing
import Foundation
@testable import GitBrainSwift

private func createTempDirectory() throws -> URL {
    let tempDir = FileManager.default.temporaryDirectory
    let uniqueDir = tempDir.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: uniqueDir, withIntermediateDirectories: true)
    return uniqueDir
}

@Test
func testFileBasedCommunicationSendMessageToOverseer() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let content = SendableContent(["type": "status", "status": "working", "message": "hello"])
    let messagePath = try await comm.sendMessageToOverseer(content)
    
    #expect(FileManager.default.fileExists(atPath: messagePath.path))
}

@Test
func testFileBasedCommunicationSendMessageToCoder() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let coderFolder = tempDir.appendingPathComponent("Coder")
    try FileManager.default.createDirectory(at: coderFolder, withIntermediateDirectories: true)
    
    let content = SendableContent(["type": "status", "status": "working", "message": "hello"])
    let messagePath = try await comm.sendMessageToCoder(content, coderFolder: coderFolder)
    
    #expect(messagePath.path.contains("Coder"))
    #expect(FileManager.default.fileExists(atPath: messagePath.path))
}

@Test
func testFileBasedCommunicationGetMessagesForCoder() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let coderFolder = tempDir.appendingPathComponent("Coder")
    try FileManager.default.createDirectory(at: coderFolder, withIntermediateDirectories: true)
    
    let content1 = SendableContent(["type": "status", "status": "working", "message": "hello1"])
    let content2 = SendableContent(["type": "status", "status": "working", "message": "hello2"])
    
    _ = try await comm.sendMessageToCoder(content1, coderFolder: coderFolder)
    _ = try await comm.sendMessageToCoder(content2, coderFolder: coderFolder)
    
    let messages = try await comm.getMessagesForCoder(coderFolder: coderFolder)
    
    #expect(messages.count == 2)
}

@Test
func testFileBasedCommunicationGetMessagesForOverseer() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let content1 = SendableContent(["type": "status", "status": "working", "message": "hello1"])
    let content2 = SendableContent(["type": "status", "status": "working", "message": "hello2"])
    
    _ = try await comm.sendMessageToOverseer(content1)
    _ = try await comm.sendMessageToOverseer(content2)
    
    let messages = try await comm.getMessagesForOverseer()
    
    #expect(messages.count == 2)
}

@Test
func testFileBasedCommunicationClearCoderMessages() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let coderFolder = tempDir.appendingPathComponent("Coder")
    try FileManager.default.createDirectory(at: coderFolder, withIntermediateDirectories: true)
    
    let content = SendableContent(["type": "status", "status": "working", "message": "hello"])
    _ = try await comm.sendMessageToCoder(content, coderFolder: coderFolder)
    
    var messages = try await comm.getMessagesForCoder(coderFolder: coderFolder)
    #expect(messages.count == 1)
    
    try await comm.clearCoderMessages(coderFolder: coderFolder)
    
    messages = try await comm.getMessagesForCoder(coderFolder: coderFolder)
    #expect(messages.count == 0)
}

@Test
func testFileBasedCommunicationClearOverseerMessages() async throws {
    let tempDir = try createTempDirectory()
    let comm = FileBasedCommunication(overseerFolder: tempDir)
    
    let content = SendableContent(["type": "status", "status": "working", "message": "hello"])
    _ = try await comm.sendMessageToOverseer(content)
    
    var messages = try await comm.getMessagesForOverseer()
    #expect(messages.count == 1)
    
    try await comm.clearOverseerMessages()
    
    messages = try await comm.getMessagesForOverseer()
    #expect(messages.count == 0)
}
