import Foundation
import CryptoKit

public struct BrainStateID: Codable, Sendable, Hashable, CustomStringConvertible {
    public let value: String
    public let aiName: String
    public let gitHash: String
    public let timestamp: Date
    
    public var description: String {
        value
    }
    
    public init(aiName: String, gitHash: String, timestamp: Date = Date()) {
        self.aiName = aiName
        self.gitHash = gitHash
        self.timestamp = timestamp
        
        let input = "\(aiName):\(gitHash):\(Int(timestamp.timeIntervalSince1970))"
        self.value = Self.hashInput(input)
    }
    
    public init?(fromString string: String) {
        let parts = string.split(separator: ":")
        guard parts.count == 3 else { return nil }
        
        self.value = string
        self.aiName = String(parts[0])
        self.gitHash = String(parts[1])
        
        guard let timeInterval = TimeInterval(parts[2]) else { return nil }
        self.timestamp = Date(timeIntervalSince1970: timeInterval)
    }
    
    public init?(fromHashed hashed: String) {
        guard hashed.count == 12 else { return nil }
        self.value = hashed
        self.aiName = ""
        self.gitHash = ""
        self.timestamp = Date()
    }
    
    private static func hashInput(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.prefix(12).joined()
    }
    
    public static func generate(aiName: String) async throws -> BrainStateID {
        let gitHash = try await Self.getCurrentGitHash()
        return BrainStateID(aiName: aiName, gitHash: gitHash)
    }
    
    public static func getCurrentGitHash() async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "--short", "HEAD"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            return "unknown"
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown"
    }
    
    public static func getCurrentGitHash() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "--short", "HEAD"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                return "unknown"
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown"
        } catch {
            return "unknown"
        }
    }
    
    public static func == (lhs: BrainStateID, rhs: BrainStateID) -> Bool {
        lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        if let id = BrainStateID(fromHashed: stringValue) {
            self = id
        } else if let id = BrainStateID(fromString: stringValue) {
            self = id
        } else {
            self.value = stringValue
            self.aiName = ""
            self.gitHash = ""
            self.timestamp = Date()
        }
    }
}
