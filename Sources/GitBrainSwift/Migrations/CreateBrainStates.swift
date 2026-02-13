import Fluent
import Foundation

struct CreateBrainStates: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("brain_states")
            .id()
            .field("ai_name", .string, .required)
            .field("role", .string, .required)
            .field("state", .string, .required)
            .field("timestamp", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("brain_states").delete()
    }
}
