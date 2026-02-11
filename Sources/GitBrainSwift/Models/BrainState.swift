import Foundation

public struct BrainState: Codable, @unchecked Sendable {
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
        self.aiName = aiName
        self.role = role
        self.version = version
        self.lastUpdated = lastUpdated
        self.state = SendableContent(state)
    }
    
    enum CodingKeys: String, CodingKey {
        case aiName = "ai_name"
        case role
        case version
        case lastUpdated = "last_updated"
        case state
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aiName = try container.decode(String.self, forKey: .aiName)
        role = try container.decode(RoleType.self, forKey: .role)
        version = try container.decode(String.self, forKey: .version)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        
        state = try container.decode(SendableContent.self, forKey: .state)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
