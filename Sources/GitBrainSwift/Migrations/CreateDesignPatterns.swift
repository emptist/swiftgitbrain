import Fluent
import Foundation

struct CreateDesignPatterns: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("design_patterns")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("pattern_name", .string, .required)
            .field("pattern_type", .string, .required)
            .field("description", .string, .required)
            .field("intent", .string)
            .field("motivation", .string)
            .field("applicability", .string)
            .field("structure", .string)
            .field("participants", .array(of: .string))
            .field("collaborations", .string)
            .field("consequences", .array(of: .string))
            .field("implementation", .string)
            .field("sample_code", .string)
            .field("known_uses", .array(of: .string))
            .field("related_patterns", .array(of: .string))
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("design_patterns").delete()
    }
}
