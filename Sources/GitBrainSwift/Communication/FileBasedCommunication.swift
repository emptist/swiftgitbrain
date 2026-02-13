import Foundation

public actor FileBasedCommunication {
    private let overseerFolder: URL
    private let fileManager: FileManager
    private let validator = MessageValidator()
    private let pluginManager = PluginManager()
    private var fileLocks: [String: FileHandle] = [:]
    
    public init(overseerFolder: URL) {
        self.overseerFolder = overseerFolder
        self.fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(at: overseerFolder, withIntermediateDirectories: true)
        } catch {
            GitBrainLogger.warning("Failed to create overseer folder: \(error.localizedDescription)")
        }
    }
    
    private func acquireLock(for fileURL: URL) throws -> FileHandle {
        let lockFile = fileURL.appendingPathExtension("lock")
        
        FileManager.default.createFile(atPath: lockFile.path, contents: nil)
        
        let lockHandle = try FileHandle(forWritingTo: lockFile)
        
        if flock(lockHandle.fileDescriptor, LOCK_EX | LOCK_NB) != 0 {
            lockHandle.closeFile()
            throw CommunicationError.fileLocked(fileURL.path)
        }
        
        fileLocks[fileURL.path] = lockHandle
        return lockHandle
    }
    
    private func releaseLock(for fileURL: URL) {
        guard let lockHandle = fileLocks.removeValue(forKey: fileURL.path) else {
            return
        }
        
        flock(lockHandle.fileDescriptor, LOCK_UN)
        lockHandle.closeFile()
        
        let lockFile = fileURL.appendingPathExtension("lock")
        try? fileManager.removeItem(at: lockFile)
    }
    
    public func sendMessageToOverseer(_ content: SendableContent) async throws -> URL {
        let processedContent = try await pluginManager.processOutgoingMessage(content, to: "overseer")
        try await validator.validate(content: processedContent)
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(timestamp)_\(UUID().uuidString).json"
        let fileURL = overseerFolder.appendingPathComponent(filename)
        
        let messageData: [String: Any] = [
            "from": "coder",
            "to": "overseer",
            "timestamp": timestamp,
            "content": processedContent.toAnyDict()
        ]
        
        do {
            _ = try acquireLock(for: fileURL)
            defer { releaseLock(for: fileURL) }
            
            let jsonData = try JSONSerialization.data(withJSONObject: messageData)
            try jsonData.write(to: fileURL, options: .atomic)
            
            GitBrainLogger.info("Successfully sent message to overseer: \(filename)")
            return fileURL
        } catch let error as CommunicationError {
            GitBrainLogger.error("Failed to send message to overseer: \(error.localizedDescription)")
            throw error
        } catch {
            GitBrainLogger.error("Failed to write message file \(fileURL.path): \(error.localizedDescription)")
            throw CommunicationError.writeFailed(fileURL.path, underlyingError: error)
        }
    }
    
    public func sendMessageToCoder(_ content: SendableContent, coderFolder: URL) async throws -> URL {
        let processedContent = try await pluginManager.processOutgoingMessage(content, to: "coder")
        try await validator.validate(content: processedContent)
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(timestamp)_\(UUID().uuidString).json"
        let fileURL = coderFolder.appendingPathComponent(filename)
        
        let messageData: [String: Any] = [
            "from": "overseer",
            "to": "coder",
            "timestamp": timestamp,
            "content": processedContent.toAnyDict()
        ]
        
        do {
            _ = try acquireLock(for: fileURL)
            defer { releaseLock(for: fileURL) }
            
            let jsonData = try JSONSerialization.data(withJSONObject: messageData)
            try jsonData.write(to: fileURL, options: .atomic)
            
            GitBrainLogger.info("Successfully sent message to coder: \(filename)")
            return fileURL
        } catch let error as CommunicationError {
            GitBrainLogger.error("Failed to send message to coder: \(error.localizedDescription)")
            throw error
        } catch {
            GitBrainLogger.error("Failed to write message file \(fileURL.path): \(error.localizedDescription)")
            throw CommunicationError.writeFailed(fileURL.path, underlyingError: error)
        }
    }
    
    public func getMessagesForCoder(coderFolder: URL) async throws -> [SendableContent] {
        let messages = try getMessages(in: coderFolder)
        return messages.map { SendableContent($0) }
    }
    
    public func getMessagesForOverseer() async throws -> [SendableContent] {
        let messages = try getMessages(in: overseerFolder)
        return messages.map { SendableContent($0) }
    }
    
    private func getMessages(in folder: URL) throws -> [[String: Any]] {
        do {
            let files = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            
            var messages: [[String: Any]] = []
            
            for file in files where file.pathExtension == "json" {
                do {
                    _ = try acquireLock(for: file)
                    defer { releaseLock(for: file) }
                    
                    let data = try Data(contentsOf: file)
                    guard let message = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        GitBrainLogger.warning("Invalid message format in \(file.path)")
                        continue
                    }
                    messages.append(message)
                } catch let error as CommunicationError {
                    if case .fileLocked = error {
                        GitBrainLogger.debug("Message file is locked, skipping: \(file.path)")
                        continue
                    }
                    throw error
                } catch {
                    GitBrainLogger.warning("Failed to read message from \(file.path): \(error.localizedDescription)")
                }
            }
            
            return messages.sorted { message1, message2 in
                guard let time1 = message1["timestamp"] as? String,
                      let time2 = message2["timestamp"] as? String else {
                    return false
                }
                return time1 < time2
            }
        } catch {
            GitBrainLogger.error("Failed to read directory \(folder.path): \(error.localizedDescription)")
            throw CommunicationError.readFailed(folder.path, underlyingError: error)
        }
    }
    
    public func clearCoderMessages(coderFolder: URL) async throws {
        try clearMessages(in: coderFolder)
    }
    
    public func clearOverseerMessages() async throws {
        try clearMessages(in: overseerFolder)
    }
    
    private func clearMessages(in folder: URL) throws {
        do {
            let files = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            
            for file in files where file.pathExtension == "json" {
                do {
                    try fileManager.removeItem(at: file)
                } catch {
                    GitBrainLogger.warning("Failed to remove message file \(file.path): \(error.localizedDescription)")
                }
            }
        } catch {
            GitBrainLogger.warning("Failed to read directory \(folder.path): \(error.localizedDescription)")
        }
    }
    
    public func registerPlugin(_ plugin: GitBrainPlugin) async throws {
        try await pluginManager.registerPlugin(plugin)
    }
    
    public func unregisterPlugin(named name: String) async throws {
        try await pluginManager.unregisterPlugin(named: name)
    }
    
    public func initializePlugins() async throws {
        try await pluginManager.initializeAll()
    }
    
    public func shutdownPlugins() async throws {
        try await pluginManager.shutdownAll()
    }
    
    public func getRegisteredPlugins() async -> [String] {
        return await pluginManager.getRegisteredPlugins()
    }
}

public enum CommunicationError: Error, LocalizedError {
    case fileLocked(String)
    case writeFailed(String, underlyingError: Error)
    case readFailed(String, underlyingError: Error)
    case invalidMessageFormat(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileLocked(let path):
            return "Failed to access file: \(path). File is locked by another process. Please wait and try again."
        case .writeFailed(let path, let error):
            return "Failed to write to file: \(path). Error: \(error.localizedDescription). Check that you have permission to write to this location and sufficient disk space."
        case .readFailed(let path, let error):
            return "Failed to read from: \(path). Error: \(error.localizedDescription). Check that the file exists and you have permission to read it."
        case .invalidMessageFormat(let path):
            return "Invalid message format in file: \(path). The message does not conform to the expected schema. Please verify the message structure."
        }
    }
}
