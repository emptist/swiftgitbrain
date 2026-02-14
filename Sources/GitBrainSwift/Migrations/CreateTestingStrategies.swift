import Fluent
import Foundation

struct CreateTestingStrategies: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("testing_strategies")
            .id()
            .field("knowledge_id", .uuid, .required)
            .field("category", .string, .required)
            .field("key", .string, .required)
            .field("strategy_name", .string, .required)
            .field("testing_type", .string, .required)
            .field("description", .string, .required)
            .field("scope", .string)
            .field("techniques", .array(of: .string))
            .field("tools", .array(of: .string))
            .field("best_practices", .array(of: .string))
            .field("coverage_goals", .string)
            .field("automation_level", .string)
            .field("test_data_strategy", .string)
            .field("ci_cd_integration", .string)
            .field("examples", .string)
            .field("created_by", .string, .required)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "knowledge_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("testing_strategies").delete()
    }
}
