import Foundation

public enum RoleType: String, Codable, Sendable, CaseIterable {
    case creator = "creator"
    case monitor = "monitor"
}
