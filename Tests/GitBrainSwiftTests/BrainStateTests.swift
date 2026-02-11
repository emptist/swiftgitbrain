import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testBrainStateCreation() {
    let brainState = BrainState(
        aiName: "test_ai",
        role: .coder,
        version: "1.0.0",
        lastUpdated: ISO8601DateFormatter().string(from: Date()),
        state: ["test_key": "test_value"]
    )
    
    #expect(brainState.aiName == "test_ai")
    #expect(brainState.role == .coder)
    #expect(brainState.version == "1.0.0")
    #expect(brainState.state.toAnyDict()["test_key"] as? String == "test_value")
}

@Test
func testBrainStateUpdate() {
    var brainState = BrainState(
        aiName: "test_ai",
        role: .coder,
        state: [:]
    )
    
    brainState.updateState(key: "new_key", value: "new_value")
    
    #expect(brainState.getState(key: "new_key") as? String == "new_value")
}

@Test
func testBrainStateGetStateWithDefault() {
    let brainState = BrainState(
        aiName: "test_ai",
        role: .coder,
        state: [:]
    )
    
    let value = brainState.getState(key: "nonexistent", defaultValue: "default")
    
    #expect(value as? String == "default")
}

@Test
func testBrainStateCodable() throws {
    let original = BrainState(
        aiName: "test_ai",
        role: .coder,
        version: "1.0.0",
        state: ["key": "value"]
    )
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(original)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(BrainState.self, from: data)
    
    #expect(decoded.aiName == original.aiName)
    #expect(decoded.role == original.role)
    #expect(decoded.version == original.version)
}
