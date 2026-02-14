import Fluent
import Foundation

struct CreateArchitecturePatterns: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("architecture_patterns")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("pattern_name", .string, .required)
            .field("description", .string, .required)
            .field("problem", .string)
            .field("solution", .string)
            .field("consequences", .array(of: .string))
            .field("use_cases", .array(of: .string))
            .field("related_patterns", .array(of: .string))
            .field("examples", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("architecture_patterns").delete()
    }
}
