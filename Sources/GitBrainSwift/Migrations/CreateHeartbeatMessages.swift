import Fluent

public struct CreateHeartbeatMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("heartbeat_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("ai_role", .string, .required)
            .field("status", .string, .required)
            .field("current_task", .string)
            .field("metadata", .dictionary(of: .string))
            .field("created_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("heartbeat_messages").delete()
    }
}
