import Foundation

public struct Message: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let content: SendableContent
    public var status: MessageStatus
    public let priority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        content: SendableContent,
        status: MessageStatus = .unread,
        priority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.content = content
        self.status = status
        self.priority = priority
    }
    
    public init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let from = dict["from"] as? String,
              let to = dict["to"] as? String,
              let timestamp = dict["timestamp"] as? String,
              let contentDict = dict["content"] as? [String: Any],
              let statusString = dict["status"] as? String,
              let status = MessageStatus(rawValue: statusString),
              let priorityInt = dict["priority"] as? Int,
              let priority = MessagePriority(rawValue: priorityInt) else {
            return nil
        }
        
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.content = SendableContent(contentDict)
        self.status = status
        self.priority = priority
    }
    
    public func toDict() -> [String: Any] {
        return [
            "id": id,
            "from": from,
            "to": to,
            "timestamp": timestamp,
            "content": content.toAnyDict(),
            "status": status.rawValue,
            "priority": priority.rawValue
        ]
    }
}

public enum MessageStatus: String, Codable, Sendable {
    case unread = "unread"
    case read = "read"
    case processed = "processed"
    case sent = "sent"
    case delivered = "delivered"
}

public enum MessagePriority: Int, Codable, Sendable {
    case critical = 1
    case high = 2
    case normal = 3
    case low = 4
}
