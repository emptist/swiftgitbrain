import Foundation

public extension URL {
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }
    
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public func appendingPathComponents(_ components: [String]) -> URL {
        var result = self
        for component in components {
            result = result.appendingPathComponent(component)
        }
        return result
    }
    
    public func createDirectoryIfNeeded() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(at: self, withIntermediateDirectories: true)
        }
    }
}

public extension Date {
    public var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    public static func fromISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    public var timeAgo: String {
        let seconds = -timeIntervalSinceNow
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(Int(days)) day(s) ago"
        } else if hours > 0 {
            return "\(Int(hours)) hour(s) ago"
        } else if minutes > 0 {
            return "\(Int(minutes)) minute(s) ago"
        } else {
            return "\(Int(seconds)) second(s) ago"
        }
    }
}

public extension String {
    public var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    public func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if caseSensitive {
            return range(of: substring) != nil
        } else {
            return range(of: substring, options: .caseInsensitive) != nil
        }
    }
    
    public func splitLines() -> [String] {
        return components(separatedBy: .newlines)
    }
    
    public var lines: [String] {
        return splitLines()
    }
    
    public func toURL() -> URL? {
        return URL(string: self)
    }
    
    public func toFileURL() -> URL {
        return URL(fileURLWithPath: self)
    }
    
    public func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    public func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public extension Dictionary where Key == String, Value == Any {
    public func toJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public func getValue<T>(_ key: String, as type: T.Type) -> T? {
        return self[key] as? T
    }
    
    public func getString(_ key: String) -> String? {
        return self[key] as? String
    }
    
    public func getInt(_ key: String) -> Int? {
        return self[key] as? Int
    }
    
    public func getBool(_ key: String) -> Bool? {
        return self[key] as? Bool
    }
    
    public func getArray<T>(_ key: String, as type: T.Type) -> [T]? {
        return self[key] as? [T]
    }
    
    public func getDictionary(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}

public extension Array where Element: Sendable {
    public func toJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    public func unique() -> [Element] {
        return NSOrderedSet(array: self).array as? [Element] ?? self
    }
}

public extension Data {
    public var jsonString: String? {
        return String(data: self, encoding: .utf8)
    }
    
    public var base64EncodedString: String {
        return base64EncodedString(options: [])
    }
    
    public func decodeJSON<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

public extension Encodable {
    public func toJSONData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    public func toJSONString() throws -> String {
        let data = try toJSONData()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

public extension Decodable {
    public static func fromJSON(_ jsonString: String) -> Self? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
    
    public static func fromJSONData(_ data: Data) -> Self? {
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}