import Fluent
import Foundation

struct CreateBestPractices: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("best_practices")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("context", .string)
            .field("benefits", .array(of: .string))
            .field("anti_pattern", .string)
            .field("examples", .string)
            .field("references", .array(of: .string))
            .field("applicable_to", .array(of: .string))
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("best_practices").delete()
    }
}
