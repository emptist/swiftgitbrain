import Fluent
import Foundation

struct CreateCodeExamples: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("code_examples")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("title", .string, .required)
            .field("description", .string)
            .field("language", .string, .required)
            .field("code", .string, .required)
            .field("input_example", .string)
            .field("output_example", .string)
            .field("explanation", .string)
            .field("complexity", .string)
            .field("dependencies", .array(of: .string))
            .field("related_snippets", .array(of: .string))
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("code_examples").delete()
    }
}
