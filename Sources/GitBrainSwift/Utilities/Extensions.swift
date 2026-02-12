import Foundation

public extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }
    
    var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func appendingPathComponents(_ components: [String]) -> URL {
        var result = self
        for component in components {
            result = result.appendingPathComponent(component)
        }
        return result
    }
    
    func createDirectoryIfNeeded() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(at: self, withIntermediateDirectories: true)
        }
    }
}

public extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    static func fromISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    var timeAgo: String {
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
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if caseSensitive {
            return range(of: substring) != nil
        } else {
            return range(of: substring, options: .caseInsensitive) != nil
        }
    }
    
    func splitLines() -> [String] {
        return components(separatedBy: .newlines)
    }
    
    var lines: [String] {
        return splitLines()
    }
    
    func toURL() -> URL? {
        return URL(string: self)
    }
    
    func toFileURL() -> URL {
        return URL(fileURLWithPath: self)
    }
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public extension Dictionary where Key == String, Value == Any {
    func toJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func getValue<T>(_ key: String, as type: T.Type) -> T? {
        return self[key] as? T
    }
    
    func getString(_ key: String) -> String? {
        return self[key] as? String
    }
    
    func getInt(_ key: String) -> Int? {
        return self[key] as? Int
    }
    
    func getBool(_ key: String) -> Bool? {
        return self[key] as? Bool
    }
    
    func getArray<T>(_ key: String, as type: T.Type) -> [T]? {
        return self[key] as? [T]
    }
    
    func getDictionary(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}

public extension Array where Element: Sendable {
    func toJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    func unique() -> [Element] {
        return NSOrderedSet(array: self).array as? [Element] ?? self
    }
}

public extension Data {
    var jsonString: String? {
        return String(data: self, encoding: .utf8)
    }
    
    var base64EncodedString: String {
        return base64EncodedString(options: [])
    }
    
    func decodeJSON<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

public extension Encodable {
    func toJSONData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func toJSONString() throws -> String {
        let data = try toJSONData()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

public extension Decodable {
    static func fromJSON(_ jsonString: String) -> Self? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
    
    static func fromJSONData(_ data: Data) -> Self? {
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}