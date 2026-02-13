import Fluent

public struct CreateFeedbackMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("feedback_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("feedback_type", .string, .required)
            .field("subject", .string, .required)
            .field("content", .string, .required)
            .field("related_task_id", .string)
            .field("response", .string)
            .field("status", .string, .required)
            .field("message_priority", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("feedback_messages").delete()
    }
}
