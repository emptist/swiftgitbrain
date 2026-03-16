import Foundation

public enum WorkType: String, Codable, Sendable, CaseIterable {
    case coding = "coding"
    case review = "review"
    case testing = "testing"
    case documentation = "documentation"
    case research = "research"
    case analysis = "analysis"
    case writing = "writing"
    case translation = "translation"
}
