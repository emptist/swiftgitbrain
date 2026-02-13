import Fluent

public struct CreateScoreMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("score_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("task_id", .string, .required)
            .field("requested_score", .int, .required)
            .field("quality_justification", .string, .required)
            .field("awarded_score", .int)
            .field("award_reason", .string)
            .field("reject_reason", .string)
            .field("status", .string, .required)
            .field("message_priority", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("score_messages").delete()
    }
}
