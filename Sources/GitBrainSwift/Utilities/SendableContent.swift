import Foundation

public struct SendableContent: Codable, Sendable {
    public private(set) var data: [String: CodableAny]

    public init(_ dictionary: [String: Any]) {
        self.data = dictionary.mapValues { Self.convertToCodableAny($0) }
    }

    public init(data: [String: CodableAny]) {
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        self.data = try decoder.singleValueContainer().decode([String: CodableAny].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    public subscript(key: String) -> CodableAny? {
        get {
            return data[key]
        }
        set {
            data[key] = newValue ?? .null
        }
    }

    public func toAnyDict() -> [String: Any] {
        return data.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value.toAny()
        }
    }

    public mutating func merge(_ other: SendableContent) {
        other.data.forEach { key, value in
            self.data[key] = value
        }
    }

    public func keys() -> [String] {
        return Array(data.keys)
    }

    public func contains(key: String) -> Bool {
        return data[key] != nil
    }

    public mutating func remove(key: String) {
        data.removeValue(forKey: key)
    }

    public mutating func removeAll() {
        data.removeAll()
    }

    public var isEmpty: Bool {
        return data.isEmpty
    }

    public var count: Int {
        return data.count
    }

    private static func convertToCodableAny(_ value: Any) -> CodableAny {
        switch value {
        case let stringValue as String:
            return .string(stringValue)
        case let intValue as Int:
            return .int(intValue)
        case let doubleValue as Double:
            return .double(doubleValue)
        case let boolValue as Bool:
            return .bool(boolValue)
        case let arrayValue as [Any]:
            return .array(arrayValue.map { convertToCodableAny($0) })
        case let dictValue as [String: Any]:
            return .dictionary(dictValue.mapValues { convertToCodableAny($0) })
        default:
            return .null
        }
    }
}

extension CodableAny {
    func toAny() -> Any {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .array(let value):
            return value.map { $0.toAny() }
        case .dictionary(let value):
            return value.mapValues { $0.toAny() }
        case .null:
            return NSNull()
        }
    }
}
