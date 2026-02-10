import Foundation

public actor SharedWorktreeCommunication {
    private let sharedWorktree: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(sharedWorktree: URL) {
        self.sharedWorktree = sharedWorktree
        self.fileManager = FileManager.default
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = .prettyPrinted
        self.decoder = JSONDecoder()
    }
    
    public func sendMessage(
        _ message: Message,
        from: String,
        to: String
    ) async throws -> URL {
        let recipientDir = sharedWorktree.appendingPathComponent(to)
        
        if !fileManager.fileExists(atPath: recipientDir.path) {
            try fileManager.createDirectory(at: recipientDir, withIntermediateDirectories: true)
        }
        
        let inboxDir = recipientDir.appendingPathComponent("inbox")
        if !fileManager.fileExists(atPath: inboxDir.path) {
            try fileManager.createDirectory(at: inboxDir, withIntermediateDirectories: true)
        }
        
        let messageData = try encoder.encode(message)
        let messageJSON = String(data: messageData, encoding: .utf8)!
        
        let filename = "\(Int(Date().timeIntervalSince1970 * 1000))_\(UUID().uuidString).json"
        let messagePath = inboxDir.appendingPathComponent(filename)
        
        try messageJSON.write(to: messagePath, atomically: true, encoding: .utf8)
        
        return messagePath
    }
    
    public func receiveMessages(for role: String) async throws -> [Message] {
        let roleDir = sharedWorktree.appendingPathComponent(role)
        
        guard fileManager.fileExists(atPath: roleDir.path) else {
            return []
        }
        
        let inboxDir = roleDir.appendingPathComponent("inbox")
        guard fileManager.fileExists(atPath: inboxDir.path) else {
            return []
        }
        
        guard let files = try? fileManager.contentsOfDirectory(at: inboxDir, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles]) else {
            return []
        }
        
        var messages: [Message] = []
        var processedFiles: [URL] = []
        
        for file in files where file.pathExtension == "json" {
            do {
                let messageData = try Data(contentsOf: file)
                let message = try decoder.decode(Message.self, from: messageData)
                messages.append(message)
                processedFiles.append(file)
            } catch {
                print("Error parsing message \(file.lastPathComponent): \(error)")
            }
        }
        
        let processedDir = roleDir.appendingPathComponent("processed")
        if !fileManager.fileExists(atPath: processedDir.path) {
            try fileManager.createDirectory(at: processedDir, withIntermediateDirectories: true)
        }
        
        for file in processedFiles {
            let destination = processedDir.appendingPathComponent(file.lastPathComponent)
            try? fileManager.moveItem(at: file, to: destination)
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    public func getMessageCount(for role: String) async throws -> Int {
        let roleDir = sharedWorktree.appendingPathComponent(role)
        
        guard fileManager.fileExists(atPath: roleDir.path) else {
            return 0
        }
        
        let inboxDir = roleDir.appendingPathComponent("inbox")
        guard fileManager.fileExists(atPath: inboxDir.path) else {
            return 0
        }
        
        guard let files = try? fileManager.contentsOfDirectory(at: inboxDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return 0
        }
        
        return files.filter { $0.pathExtension == "json" }.count
    }
    
    public func clearMessages(for role: String) async throws -> Int {
        let roleDir = sharedWorktree.appendingPathComponent(role)
        
        guard fileManager.fileExists(atPath: roleDir.path) else {
            return 0
        }
        
        var count = 0
        let subdirs = ["inbox", "processed"]
        
        for subdir in subdirs {
            let dirPath = roleDir.appendingPathComponent(subdir)
            if fileManager.fileExists(atPath: dirPath.path) {
                if let files = try? fileManager.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                    for file in files where file.pathExtension == "json" {
                        try fileManager.removeItem(at: file)
                        count += 1
                    }
                }
            }
        }
        
        return count
    }
    
    public func setupRoleDirectory(for role: String) async throws -> URL {
        let roleDir = sharedWorktree.appendingPathComponent(role)
        
        if !fileManager.fileExists(atPath: roleDir.path) {
            try fileManager.createDirectory(at: roleDir, withIntermediateDirectories: true)
        }
        
        let inboxDir = roleDir.appendingPathComponent("inbox")
        if !fileManager.fileExists(atPath: inboxDir.path) {
            try fileManager.createDirectory(at: inboxDir, withIntermediateDirectories: true)
        }
        
        let processedDir = roleDir.appendingPathComponent("processed")
        if !fileManager.fileExists(atPath: processedDir.path) {
            try fileManager.createDirectory(at: processedDir, withIntermediateDirectories: true)
        }
        
        let outboxDir = roleDir.appendingPathComponent("outbox")
        if !fileManager.fileExists(atPath: outboxDir.path) {
            try fileManager.createDirectory(at: outboxDir, withIntermediateDirectories: true)
        }
        
        return roleDir
    }
    
    public func getSharedWorktreePath() -> URL {
        return sharedWorktree
    }
}