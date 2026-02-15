import Foundation

public struct BrainState: Codable, Sendable {
    public let id: BrainStateID
    public let aiName: String
    public let role: RoleType
    public var version: String
    public var lastUpdated: String
    public var state: SendableContent
    
    public init(
        aiName: String,
        role: RoleType,
        version: String = "1.0.0",
        lastUpdated: String = ISO8601DateFormatter().string(from: Date()),
        state: [String: Any] = [:]
    ) {
        self.id = BrainStateID(aiName: aiName, gitHash: Self.getCurrentGitHash(), timestamp: Date())
        self.aiName = aiName
        self.role = role
        self.version = version
        self.lastUpdated = lastUpdated
        self.state = SendableContent(state)
    }
    
    public init(
        id: BrainStateID,
        aiName: String,
        role: RoleType,
        version: String = "1.0.0",
        lastUpdated: String = ISO8601DateFormatter().string(from: Date()),
        state: [String: Any] = [:]
    ) {
        self.id = id
        self.aiName = aiName
        self.role = role
        self.version = version
        self.lastUpdated = lastUpdated
        self.state = SendableContent(state)
    }
    
    private static func getCurrentGitHash() -> String {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case aiName = "ai_name"
        case role
        case version
        case lastUpdated = "last_updated"
        case state
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(BrainStateID.self, forKey: .id)
        aiName = try container.decode(String.self, forKey: .aiName)
        role = try container.decode(RoleType.self, forKey: .role)
        version = try container.decode(String.self, forKey: .version)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        
        state = try container.decode(SendableContent.self, forKey: .state)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(aiName, forKey: .aiName)
        try container.encode(role, forKey: .role)
        try container.encode(version, forKey: .version)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(state.data, forKey: .state)
    }
    
    public mutating func updateState(key: String, value: Any) {
        var stateDict = state.toAnyDict()
        stateDict[key] = value
        state = SendableContent(stateDict)
        lastUpdated = ISO8601DateFormatter().string(from: Date())
    }
    
    public func getState(key: String, defaultValue: Any? = nil) -> Any? {
        return state.toAnyDict()[key] ?? defaultValue
    }
}
