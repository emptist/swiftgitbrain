import Fluent
import Foundation

struct CreateApiReferences: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("api_references")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("api_name", .string, .required)
            .field("api_type", .string, .required)
            .field("endpoint", .string)
            .field("method", .string)
            .field("parameters", .string)
            .field("response_schema", .string)
            .field("authentication", .string)
            .field("rate_limiting", .string)
            .field("examples", .string)
            .field("version", .string)
            .field("deprecated", .bool, .required)
            .field("deprecation_note", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("api_references").delete()
    }
}
