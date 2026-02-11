import Foundation

public protocol CommunicationProtocol: Sendable {
    func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
    func receiveMessages(for role: String) async throws -> [Message]
    func getMessageCount(for role: String) async throws -> Int
    func clearMessages(for role: String) async throws -> Int
}
