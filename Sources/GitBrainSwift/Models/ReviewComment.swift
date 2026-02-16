import Foundation

public struct ReviewComment: Codable, Sendable, Equatable {
    public let id: UUID
    public let file: GitFileReference
    public let startLine: Int
    public let endLine: Int
    public let type: CommentType
    public let severity: CommentSeverity
    public let message: String
    public let suggestion: String?
    
    public var lineRange: ClosedRange<Int> {
        startLine...endLine
    }
    
    public init(
        id: UUID = UUID(),
        file: GitFileReference,
        startLine: Int,
        endLine: Int,
        type: CommentType,
        severity: CommentSeverity = .major,
        message: String,
        suggestion: String? = nil
    ) {
        self.id = id
        self.file = file
        self.startLine = startLine
        self.endLine = endLine
        self.type = type
        self.severity = severity
        self.message = message
        self.suggestion = suggestion
    }
}

public enum CommentType: String, Codable, Sendable, CaseIterable {
    case error = "error"
    case warning = "warning"
    case suggestion = "suggestion"
    case info = "info"
}

public enum CommentSeverity: String, Codable, Sendable, CaseIterable {
    case critical = "critical"
    case major = "major"
    case minor = "minor"
    case nitpick = "nitpick"
}
