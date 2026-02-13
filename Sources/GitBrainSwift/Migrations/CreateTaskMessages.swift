import Fluent

public struct CreateTaskMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("task_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("task_id", .string, .required)
            .field("description", .string, .required)
            .field("task_type", .string, .required)
            .field("priority", .int, .required)
            .field("files", .array(of: .string))
            .field("deadline", .datetime)
            .field("status", .string, .required)
            .field("message_priority", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("task_messages").delete()
    }
}
