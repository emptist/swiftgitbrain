import Fluent
import Foundation

public enum DatabaseError: Error {
    case connectionFailed
    case initializationFailed
    case migrationFailed
}

public actor MigrationManager {
    private let databases: Databases
    private let eventLoopGroup: any EventLoopGroup
    
    public init(databases: Databases, eventLoopGroup: any EventLoopGroup) {
        self.databases = databases
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func migrate() async throws {
        let migrations: [AsyncMigration] = [
            CreateKnowledgeItems(),
            CreateBrainStates()
        ]
        
        guard let database = databases.database(
            .init(string: "gitbrain"),
            logger: .init(label: "gitbrain.database"),
            on: eventLoopGroup.any()
        ) else {
            throw DatabaseError.migrationFailed
        }
        
        for migration in migrations {
            try await migration.prepare(on: database)
            GitBrainLogger.info("Migration completed: \(type(of: migration))")
        }
    }
    
    public func revert() async throws {
        let migrations: [AsyncMigration] = [
            CreateBrainStates(),
            CreateKnowledgeItems()
        ]
        
        guard let database = databases.database(
            .init(string: "gitbrain"),
            logger: .init(label: "gitbrain.database"),
            on: eventLoopGroup.any()
        ) else {
            throw DatabaseError.migrationFailed
        }
        
        for migration in migrations {
            try await migration.revert(on: database)
            GitBrainLogger.info("Migration reverted: \(type(of: migration))")
        }
    }
}
