import Fluent
import Foundation

struct CreateTroubleshootingGuides: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("troubleshooting_guides")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("issue_title", .string, .required)
            .field("issue_description", .string, .required)
            .field("symptoms", .array(of: .string))
            .field("root_cause", .string)
            .field("solutions", .string)
            .field("prevention", .string)
            .field("related_issues", .array(of: .string))
            .field("severity", .string)
            .field("frequency", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("troubleshooting_guides").delete()
    }
}
