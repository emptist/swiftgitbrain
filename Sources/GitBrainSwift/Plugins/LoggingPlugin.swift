import Foundation

public enum LoggingPluginError: LocalizedError {
    case encodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode string to UTF-8 data. Please check that the message contains valid UTF-8 characters."
        }
    }
}

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
            do {
                try logEntry.appendLine(to: logFileURL)
            } catch {
                GitBrainLogger.warning("Failed to write log entry to file: \(error.localizedDescription)")
            }
        }
        GitBrainLogger.info("✓ LoggingPlugin initialized")
    }
    
    public func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = """
        
        [\(timestamp)] INCOMING MESSAGE from: \(from)
        Content: \(message.toAnyDict())
        
        """
        
        if let logFileURL = logFileURL {
            do {
                try logEntry.appendLine(to: logFileURL)
            } catch {
                GitBrainLogger.warning("Failed to write log entry to file: \(error.localizedDescription)")
            }
        } else {
            GitBrainLogger.debug(logEntry)
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
            do {
                try logEntry.appendLine(to: logFileURL)
            } catch {
                GitBrainLogger.warning("Failed to write log entry to file: \(error.localizedDescription)")
            }
        } else {
            GitBrainLogger.debug(logEntry)
        }
        
        return nil
    }
    
    public func onShutdown() async throws {
        if let logFileURL = logFileURL {
            let logEntry = """
            
            === GitBrain Logging Plugin Stopped ===
            Timestamp: \(ISO8601DateFormatter().string(from: Date()))
            
            """
            do {
                try logEntry.appendLine(to: logFileURL)
            } catch {
                GitBrainLogger.warning("Failed to write log entry to file: \(error.localizedDescription)")
            }
        }
        GitBrainLogger.info("✓ LoggingPlugin shutdown")
    }
}

extension String {
    func appendLine(to url: URL) throws {
        guard let data = self.data(using: .utf8) else {
            throw LoggingPluginError.encodingFailed
        }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: url)
                defer {
                    do {
                        try fileHandle.close()
                    } catch {
                        GitBrainLogger.warning("Failed to close file handle: \(error.localizedDescription)")
                    }
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            } catch {
                GitBrainLogger.warning("Failed to open file handle: \(error.localizedDescription)")
                throw error
            }
        } else {
            do {
                try data.write(to: url)
            } catch {
                GitBrainLogger.warning("Failed to write file: \(error.localizedDescription)")
                throw error
            }
        }
    }
}
