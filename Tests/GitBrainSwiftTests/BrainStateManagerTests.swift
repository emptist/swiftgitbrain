import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testBrainStateManagerCreateAndLoad() async throws {
    let repository = MockBrainStateRepository()
    let manager = BrainStateManager(repository: repository)
    
    let brainState = try await manager.createBrainState(
        aiName: "test_ai",
        role: RoleType.coder,
        initialState: SendableContent(["test_key": "test_value"])
    )
    
    #expect(brainState.aiName == "test_ai")
    #expect(brainState.role == RoleType.coder)
    
    let loaded = try await manager.loadBrainState(aiName: "test_ai")
    
    #expect(loaded != nil)
    #expect(loaded?.aiName == "test_ai")
    #expect(loaded?.role == RoleType.coder)
}

@Test
func testBrainStateManagerUpdate() async throws {
    let repository = MockBrainStateRepository()
    let manager = BrainStateManager(repository: repository)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: RoleType.coder)
    
    let updated = try await manager.updateBrainState(aiName: "test_ai", key: "new_key", value: SendableContent(["new_key": "new_value"]))
    
    #expect(updated == true)
    
    let value = try await manager.getBrainStateValue(aiName: "test_ai", key: "new_key")
    
    if let dictValue = value?.toAnyDict()["new_key"] as? [String: Any] {
        #expect(dictValue["new_key"] as? String == "new_value")
    }
}

@Test
func testBrainStateManagerGetWithDefault() async throws {
    let repository = MockBrainStateRepository()
    let manager = BrainStateManager(repository: repository)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: RoleType.coder)
    
    let value = try await manager.getBrainStateValue(aiName: "test_ai", key: "nonexistent", defaultValue: SendableContent(["default": "default"]))
    
    if let dictValue = value?.toAnyDict() {
        #expect(dictValue["default"] as? String == "default")
    }
}

@Test
func testBrainStateManagerDelete() async throws {
    let repository = MockBrainStateRepository()
    let manager = BrainStateManager(repository: repository)
    
    _ = try await manager.createBrainState(aiName: "test_ai", role: RoleType.coder)
    
    let deleted = try await manager.deleteBrainState(aiName: "test_ai")
    
    #expect(deleted == true)
    
    let loaded = try await manager.loadBrainState(aiName: "test_ai")
    
    #expect(loaded == nil)
}

@Test
func testBrainStateManagerList() async throws {
    let repository = MockBrainStateRepository()
    let manager = BrainStateManager(repository: repository)
    
    _ = try await manager.createBrainState(aiName: "ai1", role: RoleType.coder)
    _ = try await manager.createBrainState(aiName: "ai2", role: RoleType.overseer)
    _ = try await manager.createBrainState(aiName: "ai3", role: RoleType.coder)
    
    let list = try await manager.listBrainStates()
    
    #expect(list.count == 3)
    #expect(list.contains("ai1"))
    #expect(list.contains("ai2"))
    #expect(list.contains("ai3"))
}