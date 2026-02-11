import Foundation

public protocol CoderAIProtocol: BaseRoleProtocol {
    func handleTask(_ task: SendableContent) async
    func handleFeedback(_ feedback: SendableContent) async
    func handleApproval(_ approval: SendableContent) async
    func handleRejection(_ rejection: SendableContent) async
    func handleHeartbeat(_ heartbeat: SendableContent) async
    
    func implementTask() async -> SendableContent?
    func submitCode(reviewer: String) async throws -> URL
    func generateCode(description: String) async -> String
}
