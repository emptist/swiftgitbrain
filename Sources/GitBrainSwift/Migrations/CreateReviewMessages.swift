import Fluent

public struct CreateReviewMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("review_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("task_id", .string, .required)
            .field("approved", .bool, .required)
            .field("reviewer", .string, .required)
            .field("comments", .json)
            .field("feedback", .string)
            .field("files_reviewed", .array(of: .string))
            .field("status", .string, .required)
            .field("message_priority", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("review_messages").delete()
    }
}
