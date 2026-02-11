import Testing
@testable import GitBrainSwift

struct MockPlugin: GitBrainPlugin, Sendable {
    public let pluginName: String
    public let pluginVersion: String
    public let pluginDescription: String
    
    public init(
        pluginName: String = "MockPlugin",
        pluginVersion: String = "1.0.0",
        pluginDescription: String = "Mock plugin for testing"
    ) {
        self.pluginName = pluginName
        self.pluginVersion = pluginVersion
        self.pluginDescription = pluginDescription
    }
    
    public func onInitialize() async throws {
    }
    
    public func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? {
        return nil
    }
    
    public func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent? {
        return nil
    }
    
    public func onShutdown() async throws {
    }
}

@Test
func testPluginManagerRegisterPlugin() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    
    let registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 1)
    #expect(registeredPlugins.contains("MockPlugin"))
}

@Test
func testPluginManagerRegisterMultiplePlugins() async throws {
    let manager = PluginManager()
    let plugin1 = MockPlugin(pluginName: "Plugin1")
    let plugin2 = MockPlugin(pluginName: "Plugin2")
    let plugin3 = MockPlugin(pluginName: "Plugin3")
    
    try await manager.registerPlugin(plugin1)
    try await manager.registerPlugin(plugin2)
    try await manager.registerPlugin(plugin3)
    
    let registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 3)
    #expect(registeredPlugins.contains("Plugin1"))
    #expect(registeredPlugins.contains("Plugin2"))
    #expect(registeredPlugins.contains("Plugin3"))
}

@Test
func testPluginManagerUnregisterPlugin() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    
    var registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 1)
    
    try await manager.unregisterPlugin(named: "MockPlugin")
    
    registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 0)
}

@Test
func testPluginManagerGetPlugin() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    
    let retrievedPlugin = await manager.getPlugin(named: "MockPlugin")
    #expect(retrievedPlugin != nil)
    #expect(retrievedPlugin?.pluginName == "MockPlugin")
}

@Test
func testPluginManagerInitializeAll() async throws {
    let manager = PluginManager()
    let plugin1 = MockPlugin(pluginName: "Plugin1")
    let plugin2 = MockPlugin(pluginName: "Plugin2")
    
    try await manager.registerPlugin(plugin1)
    try await manager.registerPlugin(plugin2)
    
    try await manager.initializeAll()
    
    let registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 2)
}

@Test
func testPluginManagerShutdownAll() async throws {
    let manager = PluginManager()
    let plugin1 = MockPlugin(pluginName: "Plugin1")
    let plugin2 = MockPlugin(pluginName: "Plugin2")
    
    try await manager.registerPlugin(plugin1)
    try await manager.registerPlugin(plugin2)
    
    try await manager.initializeAll()
    try await manager.shutdownAll()
    
    let registeredPlugins = await manager.getRegisteredPlugins()
    #expect(registeredPlugins.count == 0)
}

@Test
func testPluginManagerProcessIncomingMessage() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    try await manager.initializeAll()
    
    let message = SendableContent(["type": "test", "content": "test message"])
    let processedMessage = try await manager.processIncomingMessage(message, from: "test_sender")
    
    #expect(processedMessage.toAnyDict()["type"] as? String == "test")
    #expect(processedMessage.toAnyDict()["content"] as? String == "test message")
}

@Test
func testPluginManagerProcessOutgoingMessage() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    try await manager.initializeAll()
    
    let message = SendableContent(["type": "test", "content": "test message"])
    let processedMessage = try await manager.processOutgoingMessage(message, to: "test_recipient")
    
    #expect(processedMessage.toAnyDict()["type"] as? String == "test")
    #expect(processedMessage.toAnyDict()["content"] as? String == "test message")
}

@Test
func testPluginManagerUnregisterNonExistentPlugin() async throws {
    let manager = PluginManager()
    
    do {
        try await manager.unregisterPlugin(named: "NonExistentPlugin")
        #expect(Bool(false), "Should throw error for non-existent plugin")
    } catch {
    }
}

@Test
func testPluginManagerRegisterDuplicatePlugin() async throws {
    let manager = PluginManager()
    let plugin = MockPlugin()
    
    try await manager.registerPlugin(plugin)
    
    do {
        try await manager.registerPlugin(plugin)
        #expect(Bool(false), "Should throw error for duplicate plugin")
    } catch {
    }
}
