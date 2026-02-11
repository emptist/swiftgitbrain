import Foundation

public protocol BrainStateManagerProtocol: Sendable {
    func createBrainState(aiName: String, role: RoleType, initialState: SendableContent?) async throws -> BrainState
    func loadBrainState(aiName: String) async throws -> BrainState?
    func saveBrainState(_ brainState: BrainState) async throws
    func updateBrainState(aiName: String, key: String, value: SendableContent) async throws -> Bool
    func getBrainStateValue(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent?
    func deleteBrainState(aiName: String) async throws -> Bool
    func listBrainStates() async throws -> [String]
    func backupBrainState(aiName: String, backupSuffix: String?) async throws -> String?
    func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool
}
