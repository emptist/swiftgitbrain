import Foundation

public protocol OverseerAIProtocol: BaseRoleProtocol {
    func reviewCode(taskID: String) async -> SendableContent?
    func approveCode(taskID: String, coder: String) async throws -> URL
    func rejectCode(taskID: String, reason: String, coder: String) async throws -> URL
    func requestChanges(taskID: String, feedback: String, coder: String) async throws -> URL
    func assignTask(taskID: String, coder: String, description: String, taskType: String) async throws -> URL
    func getCapabilities() async -> [String]
}
