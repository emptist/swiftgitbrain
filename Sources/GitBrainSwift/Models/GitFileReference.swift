import Foundation

public struct GitFileReference: Codable, Sendable, Equatable, Hashable {
    public let path: String
    public let commitHash: String?
    public let branch: String?
    
    public init(path: String, commitHash: String? = nil, branch: String? = nil) {
        self.path = path
        self.commitHash = commitHash
        self.branch = branch
    }
}
