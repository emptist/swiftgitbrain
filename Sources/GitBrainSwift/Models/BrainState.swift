import Foundation

public struct BrainState: Codable, @unchecked Sendable {
    public let aiName: String
    public let role: RoleType
    public var version: String
    public var lastUpdated: String
    public var state: [String: Any]
    
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
        self.state = state
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
        
        let stateData = try container.decode([String: String].self, forKey: .state)
        state = stateData.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aiName, forKey: .aiName)
        try container.encode(role, forKey: .role)
        try container.encode(version, forKey: .version)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        
        let stringState = state.reduce(into: [String: String]()) { dict, pair in
            if let value = pair.value as? String {
                dict[pair.key] = value
            }
        }
        try container.encode(stringState, forKey: .state)
    }
    
    public mutating func updateState(key: String, value: Any) {
        state[key] = value
        lastUpdated = ISO8601DateFormatter().string(from: Date())
    }
    
    public mutating func updateState(taskData: TaskData) {
        for (key, value) in taskData.data {
            state[key] = value
        }
        lastUpdated = ISO8601DateFormatter().string(from: Date())
    }
    
    public func getState(key: String, defaultValue: Any? = nil) -> Any? {
        return state[key] ?? defaultValue
    }
}
