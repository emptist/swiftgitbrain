import Fluent
import Foundation

struct CreateKnowledgeItems: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("knowledge_items")
            .id()
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("value", .string, .required)
            .field("metadata", .string, .required)
            .field("timestamp", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("knowledge_items").delete()
    }
}
