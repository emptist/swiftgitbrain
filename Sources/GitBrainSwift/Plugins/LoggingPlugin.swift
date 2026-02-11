import Foundation

public struct LoggingPlugin: GitBrainPlugin, Sendable {
    public let pluginName = "LoggingPlugin"
    public let pluginVersion = "1.0.0"
    public let pluginDescription = "Logs all messages sent and received"
    
    private var logFileURL: URL?
    
    public init(logFileURL: URL? = nil) {
        self.logFileURL = logFileURL
    }
    
    public func onInitialize() async throws {
        if let logFileURL = logFileURL {
            let logEntry = """
            
            === GitBrain Logging Plugin Started ===
            Timestamp: \(ISO8601DateFormatter().string(from: Date()))
            Version: \(pluginVersion)
            
            """
            try? logEntry.appendLine(to: logFileURL)
        }
        print("✓ LoggingPlugin initialized")
    }
    
    public func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = """
        
        [\(timestamp)] INCOMING MESSAGE from: \(from)
        Content: \(message.toAnyDict())
        
        """
        
        if let logFileURL = logFileURL {
            try? logEntry.appendLine(to: logFileURL)
        } else {
            print(logEntry)
        }
        
        return nil
    }
    
    public func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent? {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = """
        
        [\(timestamp)] OUTGOING MESSAGE to: \(to)
        Content: \(message.toAnyDict())
        
        """
        
        if let logFileURL = logFileURL {
            try? logEntry.appendLine(to: logFileURL)
        } else {
            print(logEntry)
        }
        
        return nil
    }
    
    public func onShutdown() async throws {
        if let logFileURL = logFileURL {
            let logEntry = """
            
            === GitBrain Logging Plugin Stopped ===
            Timestamp: \(ISO8601DateFormatter().string(from: Date()))
            
            """
            try? logEntry.appendLine(to: logFileURL)
        }
        print("✓ LoggingPlugin shutdown")
    }
}

extension String {
    func appendLine(to url: URL) throws {
        let data = self.data(using: .utf8)!
        if FileManager.default.fileExists(atPath: url.path) {
            if let fileHandle = try? FileHandle(forWritingTo: url) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try data.write(to: url)
        }
    }
}
