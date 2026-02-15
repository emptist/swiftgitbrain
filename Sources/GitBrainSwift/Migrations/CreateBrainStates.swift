import Fluent
import Foundation

struct CreateBrainStates: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("brain_states")
            .id()
            .field("brain_state_id", .string, .required)
            .field("ai_name", .string, .required)
            .field("role", .string, .required)
            .field("state", .string, .required)
            .field("timestamp", .datetime)
            .unique(on: "ai_name")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("brain_states").delete()
    }
}
