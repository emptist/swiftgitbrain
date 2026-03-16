import Foundation

public struct MessageID: Codable, Sendable, Equatable, Hashable {
    public let rawValue: String
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct WorkItemID: Codable, Sendable, Equatable, Hashable {
    public let rawValue: String
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
