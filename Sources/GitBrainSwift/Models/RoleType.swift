import Foundation

public enum RoleType: String, Codable, Sendable, CaseIterable {
    case coder = "coder"
    // case reviewer = "reviewer"
    case overseer = "overseer"
}
