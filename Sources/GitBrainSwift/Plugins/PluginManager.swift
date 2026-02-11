import Foundation

public protocol GitBrainPlugin: Sendable {
    var pluginName: String { get }
    var pluginVersion: String { get }
    var pluginDescription: String { get }
    
    func onInitialize() async throws
    func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent?
    func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent?
    func onShutdown() async throws
}

public extension GitBrainPlugin {
    func onInitialize() async throws {}
    func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? { nil }
    func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent? { nil }
    func onShutdown() async throws {}
}

public actor PluginManager {
    private var plugins: [String: GitBrainPlugin] = [:]
    private var isInitialized = false
    
    public init() {}
    
    public func registerPlugin(_ plugin: GitBrainPlugin) async throws {
        guard plugins[plugin.pluginName] == nil else {
            throw PluginError.pluginAlreadyRegistered(plugin.pluginName)
        }
        
        plugins[plugin.pluginName] = plugin
        
        if isInitialized {
            try await plugin.onInitialize()
        }
    }
    
    public func unregisterPlugin(named name: String) async throws {
        guard let plugin = plugins.removeValue(forKey: name) else {
            throw PluginError.pluginNotFound(name)
        }
        
        try await plugin.onShutdown()
    }
    
    public func initializeAll() async throws {
        for (name, plugin) in plugins {
            do {
                try await plugin.onInitialize()
                GitBrainLogger.info("✓ Plugin '\(name)' initialized")
            } catch {
                GitBrainLogger.error("✗ Failed to initialize plugin '\(name)': \(error.localizedDescription)")
                throw error
            }
        }
        isInitialized = true
    }
    
    public func shutdownAll() async throws {
        for (name, plugin) in plugins {
            do {
                try await plugin.onShutdown()
                GitBrainLogger.info("✓ Plugin '\(name)' shutdown")
            } catch {
                GitBrainLogger.error("✗ Failed to shutdown plugin '\(name)': \(error.localizedDescription)")
            }
        }
        plugins.removeAll()
        isInitialized = false
    }
    
    public func processIncomingMessage(_ message: SendableContent, from: String) async throws -> SendableContent {
        var currentMessage = message
        
        for (name, plugin) in plugins {
            do {
                if let modifiedMessage = try await plugin.onMessageReceived(currentMessage, from: from) {
                    currentMessage = modifiedMessage
                    GitBrainLogger.debug("Plugin '\(name)' modified incoming message")
                }
            } catch {
                GitBrainLogger.warning("Plugin '\(name)' error processing incoming message: \(error.localizedDescription)")
            }
        }
        
        return currentMessage
    }
    
    public func processOutgoingMessage(_ message: SendableContent, to: String) async throws -> SendableContent {
        var currentMessage = message
        
        for (name, plugin) in plugins {
            do {
                if let modifiedMessage = try await plugin.onMessageSending(currentMessage, to: to) {
                    currentMessage = modifiedMessage
                    GitBrainLogger.debug("Plugin '\(name)' modified outgoing message")
                }
            } catch {
                GitBrainLogger.warning("Plugin '\(name)' error processing outgoing message: \(error.localizedDescription)")
            }
        }
        
        return currentMessage
    }
    
    public func getRegisteredPlugins() async -> [String] {
        return plugins.keys.sorted()
    }
    
    public func getPlugin(named name: String) async -> GitBrainPlugin? {
        return plugins[name]
    }
}

public enum PluginError: Error, LocalizedError {
    case pluginAlreadyRegistered(String)
    case pluginNotFound(String)
    case pluginInitializationFailed(String, Error)
    case pluginExecutionFailed(String, Error)
    
    public var errorDescription: String? {
        switch self {
        case .pluginAlreadyRegistered(let name):
            return "Plugin '\(name)' is already registered"
        case .pluginNotFound(let name):
            return "Plugin '\(name)' not found"
        case .pluginInitializationFailed(let name, let error):
            return "Plugin '\(name)' initialization failed: \(error.localizedDescription)"
        case .pluginExecutionFailed(let name, let error):
            return "Plugin '\(name)' execution failed: \(error.localizedDescription)"
        }
    }
}
