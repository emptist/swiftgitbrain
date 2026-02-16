import Foundation

public enum HeartbeatStatus: String, Codable, Sendable, CaseIterable {
    case active = "active"
    case idle = "idle"
    case busy = "busy"
    case sleeping = "sleeping"
    case error = "error"
}

public struct HeartbeatMessage: HeartbeatMessageProtocol {
    public let id: UUID
    public let from: RoleType
    public let to: RoleType
    public let createdAt: Date
    public let priority: MessagePriority
    public let status: HeartbeatStatus
    public let currentTask: String?
    public let metadata: [String: String]?
    
    public init(
        id: UUID = UUID(),
        from: RoleType,
        to: RoleType,
        createdAt: Date = Date(),
        priority: MessagePriority = .normal,
        status: HeartbeatStatus = .active,
        currentTask: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.priority = priority
        self.status = status
        self.currentTask = currentTask
        self.metadata = metadata
    }
}
