import Foundation

public struct ReviewComment: Codable, Sendable, Equatable {
    public let file: String
    public let line: Int
    public let type: CommentType
    public let message: String
    
    public enum CommentType: String, Codable, Sendable, CaseIterable {
        case error = "error"
        case warning = "warning"
        case suggestion = "suggestion"
        case info = "info"
    }
    
    public init(file: String, line: Int, type: CommentType, message: String) {
        self.file = file
        self.line = line
        self.type = type
        self.message = message
    }
}
