import Foundation

public struct FileReference: Codable, Sendable, Equatable, Hashable {
    public let path: String
    public let version: String?
    public let metadata: [String: String]?
    
    public init(path: String, version: String? = nil, metadata: [String: String]? = nil) {
        self.path = path
        self.version = version
        self.metadata = metadata
    }
}
