import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testBrainStateManagerCreateAndLoad() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    let brainState = try await manager.createBrainState(
        aiName: "test_ai",
        role: .coder,
        initialState: SendableContent(["test_key": "test_value"])
    )
    
    #expect(brainState.aiName == "test_ai")
    #expect(brainState.role == .coder)
    
    let loaded = try await manager.loadBrainState(aiName: "test_ai")
    
    #expect(loaded != nil)
    #expect(loaded?.aiName == "test_ai")
    #expect(loaded?.role == .coder)
    
    try FileManager.default.removeItem(at: brainstateBase)
}

@Test
func testBrainStateManagerUpdate() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: .coder)
    
    let updated = try await manager.updateBrainState(aiName: "test_ai", key: "new_key", value: SendableContent(["new_key": "new_value"]))
    
    #expect(updated == true)
    
    let value = try await manager.getBrainStateValue(aiName: "test_ai", key: "new_key")
    
    if let dictValue = value?.toAnyDict()["new_key"] as? [String: Any] {
        #expect(dictValue["new_key"] as? String == "new_value")
    }
    
    try FileManager.default.removeItem(at: brainstateBase)
}

@Test
func testBrainStateManagerGetWithDefault() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: .coder)
    
    let value = try await manager.getBrainStateValue(aiName: "test_ai", key: "nonexistent", defaultValue: SendableContent(["default": "default"]))
    
    #expect(value?.toAnyDict()["default"] as? String == "default")
    
    try FileManager.default.removeItem(at: brainstateBase)
}

@Test
func testBrainStateManagerDelete() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: .coder)
    
    let deleted = try await manager.deleteBrainState(aiName: "test_ai")
    
    #expect(deleted == true)
    
    let loaded = try await manager.loadBrainState(aiName: "test_ai")
    
    #expect(loaded == nil)
    
    try FileManager.default.removeItem(at: brainstateBase)
}

@Test
func testBrainStateManagerList() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    _ = try await manager.createBrainState(aiName: "ai1", role: .coder)
    _ = try await manager.createBrainState(aiName: "ai2", role: .overseer)
    _ = try await manager.createBrainState(aiName: "ai3", role: .coder)
    
    let list = try await manager.listBrainStates()
    
    #expect(list.count == 3)
    #expect(list.contains("ai1"))
    #expect(list.contains("ai2"))
    #expect(list.contains("ai3"))
    
    try FileManager.default.removeItem(at: brainstateBase)
}

@Test
func testBrainStateManagerBackupAndRestore() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let brainstateBase = tempDir.appendingPathComponent("test_brainstates_\(UUID().uuidString)")
    
    let manager = BrainStateManager(brainstateBase: brainstateBase)
    
    let original = try await manager.createBrainState(
        aiName: "test_ai",
        role: .coder,
        initialState: SendableContent(["original_key": "original_value"])
    )
    
    let backupPath = try await manager.backupBrainState(aiName: "test_ai")
    
    #expect(backupPath != nil)
    
    _ = try await manager.updateBrainState(aiName: "test_ai", key: "modified_key", value: SendableContent(["modified_key": "modified_value"]))
    
    let restored = try await manager.restoreBrainState(aiName: "test_ai", backupFile: URL(fileURLWithPath: backupPath!).lastPathComponent)
    
    #expect(restored == true)
    
    let loaded = try await manager.loadBrainState(aiName: "test_ai")
    
    #expect(loaded?.state.toAnyDict()["original_key"] as? String == "original_value")
    
    try FileManager.default.removeItem(at: brainstateBase)
}
