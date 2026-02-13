import Fluent
import Foundation
import PostgresKit

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
            CreateBrainStates(),
            CreateTaskMessages(),
            CreateReviewMessages(),
            CreateCodeMessages(),
            CreateScoreMessages(),
            CreateFeedbackMessages(),
            CreateHeartbeatMessages()
        ]
        
        guard let database = databases.database(
            .init(string: "gitbrain"),
            logger: .init(label: "gitbrain.database"),
            on: eventLoopGroup.any()
        ) else {
            throw DatabaseError.migrationFailed
        }
        
        for migration in migrations {
            do {
                try await migration.prepare(on: database)
                GitBrainLogger.info("Migration completed: \(type(of: migration))")
            } catch {
                let errorString = String(reflecting: error)
                if errorString.contains("already exists") || errorString.contains("42P07") {
                    GitBrainLogger.info("Migration skipped (table exists): \(type(of: migration))")
                } else {
                    GitBrainLogger.error("Migration failed: \(type(of: migration)) - \(error)")
                    throw error
                }
            }
        }
    }
    
    public func revert() async throws {
        let migrations: [AsyncMigration] = [
            CreateHeartbeatMessages(),
            CreateFeedbackMessages(),
            CreateScoreMessages(),
            CreateCodeMessages(),
            CreateReviewMessages(),
            CreateTaskMessages(),
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
