import Fluent
import Foundation

struct CreateCodeSnippets: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("code_snippets")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("language", .string, .required)
            .field("code", .string, .required)
            .field("description", .string)
            .field("usage_example", .string)
            .field("dependencies", .array(of: .string))
            .field("framework", .string)
            .field("version", .string)
            .field("complexity", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("code_snippets").delete()
    }
}
