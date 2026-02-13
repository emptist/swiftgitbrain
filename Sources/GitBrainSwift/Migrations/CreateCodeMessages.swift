import Fluent

public struct CreateCodeMessages: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("code_messages")
            .id()
            .field("message_id", .uuid, .required)
            .field("from_ai", .string, .required)
            .field("to_ai", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("code_id", .string, .required)
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("files", .array(of: .string), .required)
            .field("branch", .string)
            .field("commit_sha", .string)
            .field("status", .string, .required)
            .field("message_priority", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "message_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("code_messages").delete()
    }
}
