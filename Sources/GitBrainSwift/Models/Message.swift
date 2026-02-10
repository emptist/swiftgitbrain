import Foundation

public struct Message: Codable, Identifiable, Sendable {
    public let id: String
    public let fromAI: String
    public let toAI: String
    public let messageType: MessageType
    public let content: [String: Any]
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
        self.content = content
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
        content = contentData.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value
        }
        
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
        
        let stringContent = content.reduce(into: [String: String]()) { dict, pair in
            if let value = pair.value as? String {
                dict[pair.key] = value
            }
        }
        try container.encode(stringContent, forKey: .content)
        
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(priority, forKey: .priority)
        try container.encode(metadata, forKey: .metadata)
    }
}
