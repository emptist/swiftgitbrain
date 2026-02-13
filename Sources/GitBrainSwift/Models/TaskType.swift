import Foundation

public enum TaskType: String, Codable, Sendable, CaseIterable {
    case coding = "coding"
    case review = "review"
    case testing = "testing"
    case documentation = "documentation"
}
