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

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([CodableAny].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: CodableAny].self) {
            self = .dictionary(value)
        } else if container.decodeNil() {
            self = .null
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
}

extension CodableAny {
    public var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    public var intValue: Int? {
        if case .int(let value) = self {
            return value
        }
        return nil
    }

    public var doubleValue: Double? {
        if case .double(let value) = self {
            return value
        }
        return nil
    }

    public var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

    public var arrayValue: [CodableAny]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }

    public var dictionaryValue: [String: CodableAny]? {
        if case .dictionary(let value) = self {
            return value
        }
        return nil
    }

    public var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
}
