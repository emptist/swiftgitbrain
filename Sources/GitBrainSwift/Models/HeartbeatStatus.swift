import Foundation

public enum HeartbeatStatus: String, Codable, Sendable, CaseIterable {
    case active = "active"
    case idle = "idle"
    case busy = "busy"
    case sleeping = "sleeping"
    case error = "error"
}
