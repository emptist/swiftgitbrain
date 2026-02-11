import Foundation

public struct SendableContent: Codable, Sendable {
    public let data: [String: String]
    
    public init(_ dict: [String: Any]) {
        self.data = dict.reduce(into: [:]) { result, pair in
            result[pair.key] = Self.stringify(value: pair.value)
        }
    }
    
    private static func stringify(value: Any) -> String {
        if let stringValue = value as? String {
            return stringValue
        } else if let boolValue = value as? Bool {
            return boolValue ? "true" : "false"
        } else if let intValue = value as? Int {
            return String(intValue)
        } else if let doubleValue = value as? Double {
            return String(doubleValue)
        } else if let arrayValue = value as? [Any] {
            return arrayValue.map { stringify(value: $0) }.joined(separator: ",")
        } else if let dictValue = value as? [String: Any] {
            return dictValue.map { "\($0.key):\($0.value)" }.joined(separator: ",")
        }
        return String(describing: value)
    }
    
    public func toAnyDict() -> [String: Any] {
        return data.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = Self.parse(value: pair.value)
        }
    }
    
    private static func parse(value: String) -> Any {
        if value == "true" {
            return true
        } else if value == "false" {
            return false
        } else if let intValue = Int(value) {
            return intValue
        } else if let doubleValue = Double(value) {
            return doubleValue
        }
        return value
    }
}

public struct Message: Codable, Identifiable, Sendable {
    public let id: String
    public let fromAI: String
    public let toAI: String
    public let messageType: MessageType
    public let content: SendableContent
    public let timestamp: String
    public let priority: Int
    public let metadata: [String: String]
    
    public init(
        id: String,
        fromAI: String,
        toAI: String,
        messageType: MessageType,
        content: [String: Any],
        timestamp: String = ISO8601DateFormatter().string(from: Date()),
        priority: Int = 0,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.fromAI = fromAI
        self.toAI = toAI
        self.messageType = messageType
        self.content = SendableContent(content)
        self.timestamp = timestamp
        self.priority = priority
        self.metadata = metadata
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromAI = "from_ai"
        case toAI = "to_ai"
        case messageType = "message_type"
        case content
        case timestamp
        case priority
        case metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fromAI = try container.decode(String.self, forKey: .fromAI)
        toAI = try container.decode(String.self, forKey: .toAI)
        messageType = try container.decode(MessageType.self, forKey: .messageType)
        
        let contentData = try container.decode([String: String].self, forKey: .content)
        content = SendableContent(contentData.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value
        })
        
        timestamp = try container.decode(String.self, forKey: .timestamp)
        priority = try container.decode(Int.self, forKey: .priority)
        metadata = try container.decode([String: String].self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fromAI, forKey: .fromAI)
        try container.encode(toAI, forKey: .toAI)
        try container.encode(messageType, forKey: .messageType)
        try container.encode(content.data, forKey: .content)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(priority, forKey: .priority)
        try container.encode(metadata, forKey: .metadata)
    }
}
