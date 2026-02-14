import Fluent
import Foundation

struct CreateDocumentation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("documentation")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("summary", .string)
            .field("version", .string)
            .field("last_reviewed", .datetime)
            .field("review_status", .string)
            .field("related_topics", .array(of: .string))
            .field("external_links", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("documentation").delete()
    }
}
