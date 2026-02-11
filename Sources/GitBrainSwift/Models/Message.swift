import Foundation

public enum CodableAny: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([CodableAny])
    case dictionary([String: CodableAny])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            if doubleValue == doubleValue.rounded() {
                self = .int(Int(doubleValue))
            } else {
                self = .double(doubleValue)
            }
        } else if let arrayValue = try? container.decode([CodableAny].self) {
            self = .array(arrayValue)
        } else if let dictValue = try? container.decode([String: CodableAny].self) {
            self = .dictionary(dictValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "CodableAny value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    public var anyValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .array(let value): return value.map { $0.anyValue }
        case .dictionary(let value):
            return value.reduce(into: [String: Any]()) { dict, pair in
                dict[pair.key] = pair.value.anyValue
            }
        case .null: return NSNull()
        }
    }
    
    public static func from(_ value: Any) -> CodableAny {
        if let stringValue = value as? String {
            return .string(stringValue)
        } else if let intValue = value as? Int {
            return .int(intValue)
        } else if let doubleValue = value as? Double {
            return .double(doubleValue)
        } else if let boolValue = value as? Bool {
            return .bool(boolValue)
        } else if let arrayValue = value as? [Any] {
            return .array(arrayValue.map { from($0) })
        } else if let dictValue = value as? [String: Any] {
            return .dictionary(dictValue.mapValues { from($0) })
        } else if value is NSNull {
            return .null
        }
        return .string(String(describing: value))
    }
}

public struct SendableContent: Codable, Sendable {
    public let data: [String: CodableAny]
    
    public init(_ dict: [String: Any]) {
        self.data = dict.mapValues { CodableAny.from($0) }
    }
    
    public func toAnyDict() -> [String: Any] {
        return data.mapValues { $0.anyValue }
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
        
        let contentData = try container.decode([String: CodableAny].self, forKey: .content)
        content = SendableContent(contentData.mapValues { $0.anyValue })
        
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
