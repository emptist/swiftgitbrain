import Foundation
import GitBrainSwift

@main
struct PluginTest {
    static func main() async throws {
        print("=== GitBrain Plugin System Test ===\n")
        
        let overseerURL = URL(fileURLWithPath: "/tmp/test_gitbrain/Overseer")
        let communication = FileBasedCommunication(overseerFolder: overseerURL)
        
        let loggingPlugin = LoggingPlugin()
        let transformPlugin = MessageTransformPlugin()
        
        try await communication.registerPlugin(loggingPlugin)
        print("✓ Registered LoggingPlugin")
        
        try await communication.registerPlugin(transformPlugin)
        print("✓ Registered MessageTransformPlugin")
        
        try await communication.initializePlugins()
        print()
        
        let testMessage = SendableContent([
            "type": "task",
            "task_id": "plugin-test-001",
            "description": "Testing plugin system",
            "task_type": "coding",
            "priority": 5
        ])
        
        print("Sending test message...")
        let messageURL = try await communication.sendMessageToOverseer(testMessage)
        print("✓ Message sent to: \(messageURL.path)")
        
        print()
        print("Registered plugins:")
        let plugins = await communication.getRegisteredPlugins()
        for plugin in plugins {
            print("  - \(plugin)")
        }
        
        print()
        try await communication.shutdownPlugins()
        print("✓ All plugins shutdown")
        
        print("\n=== Plugin System Test Complete ===")
    }
}
