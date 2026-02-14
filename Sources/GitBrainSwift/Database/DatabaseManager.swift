import Foundation
import Fluent
import FluentPostgresDriver
import NIO

public struct DatabaseConfig: Sendable {
    public let host: String
    public let port: Int
    public let database: String
    public let username: String
    public let password: String
    public let projectName: String
    
    public init(
        host: String = "localhost",
        port: Int = 5432,
        projectName: String? = nil,
        database: String? = nil,
        username: String = "postgres",
        password: String = "postgres"
    ) {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        
        if let projectName = projectName {
            self.projectName = projectName
            self.database = "gitbrain_\(projectName)"
        } else if let database = database {
            if database.hasPrefix("gitbrain_") {
                self.projectName = String(database.dropFirst("gitbrain_".count))
            } else {
                self.projectName = database
            }
            self.database = database
        } else {
            self.projectName = "default"
            self.database = "gitbrain_default"
        }
    }
    
    public init(from gitBrainConfig: GitBrainConfig) {
        self.host = gitBrainConfig.databaseHost
        self.port = gitBrainConfig.databasePort
        self.database = gitBrainConfig.databaseName
        self.username = ProcessInfo.processInfo.environment["GITBRAIN_DB_USER"] ?? "postgres"
        self.password = ProcessInfo.processInfo.environment["GITBRAIN_DB_PASSWORD"] ?? "postgres"
        
        if gitBrainConfig.databaseName.hasPrefix("gitbrain_") {
            self.projectName = String(gitBrainConfig.databaseName.dropFirst("gitbrain_".count))
        } else {
            self.projectName = gitBrainConfig.databaseName
        }
    }
    
    public static func fromEnvironment() -> DatabaseConfig {
        let host = ProcessInfo.processInfo.environment["GITBRAIN_DB_HOST"] ?? "localhost"
        let port = Int(ProcessInfo.processInfo.environment["GITBRAIN_DB_PORT"] ?? "5432") ?? 5432
        let projectName = ProcessInfo.processInfo.environment["GITBRAIN_PROJECT_NAME"]
        let database = ProcessInfo.processInfo.environment["GITBRAIN_DB_NAME"]
        let username = ProcessInfo.processInfo.environment["GITBRAIN_DB_USER"] ?? "postgres"
        let password = ProcessInfo.processInfo.environment["GITBRAIN_DB_PASSWORD"] ?? "postgres"
        
        return DatabaseConfig(
            host: host,
            port: port,
            projectName: projectName,
            database: database,
            username: username,
            password: password
        )
    }
    
    public static func forTesting(projectName: String = "swiftgitbraintests") -> DatabaseConfig {
        return DatabaseConfig(
            host: "localhost",
            port: 5432,
            projectName: projectName,
            username: "postgres",
            password: "postgres"
        )
    }
}

public actor DatabaseManager {
    private let config: DatabaseConfig
    private var databases: Databases?
    private var eventLoopGroup: EventLoopGroup?
    private var threadPool: NIOThreadPool?
    private var isInitialized = false
    private var database: Database?
    
    public init(config: DatabaseConfig = .fromEnvironment()) {
        self.config = config
    }
    
    public func initialize() async throws -> Databases {
        if let existing = databases {
            return existing
        }
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.eventLoopGroup = eventLoopGroup
        
        let threadPool = NIOThreadPool(numberOfThreads: 1)
        self.threadPool = threadPool
        threadPool.start()
        
        let db = Databases(threadPool: threadPool, on: eventLoopGroup)
        
        let postgresConfig = SQLPostgresConfiguration(
            hostname: config.host,
            port: config.port,
            username: config.username,
            password: config.password,
            database: config.database,
            tls: .disable
        )
        
        db.use(.postgres(configuration: postgresConfig), as: .init(string: "gitbrain"), isDefault: true)
        
        databases = db
        isInitialized = true
        
        GitBrainLogger.info("Database connected: \(config.host):\(config.port)/\(config.database)")
        
        let migrationManager = MigrationManager(databases: db, eventLoopGroup: eventLoopGroup)
        try await migrationManager.migrate()
        
        return db
    }
    
    public func getDatabase() async throws -> Databases {
        if let db = databases {
            return db
        }
        
        return try await initialize()
    }
    
    private func getSharedDatabase() async throws -> Database {
        if let db = database {
            return db
        }
        
        let databases = try await getDatabase()
        guard let db = databases.database(
            .init(string: "gitbrain"),
            logger: .init(label: "gitbrain.database"),
            on: eventLoopGroup!.any()
        ) else {
            throw DatabaseError.connectionFailed
        }
        
        database = db
        return db
    }
    
    public func createKnowledgeRepository() async throws -> KnowledgeRepositoryProtocol {
        let db = try await getSharedDatabase()
        return FluentKnowledgeRepository(database: db)
    }
    
    public func createBrainStateRepository() async throws -> BrainStateRepositoryProtocol {
        let db = try await getSharedDatabase()
        return FluentBrainStateRepository(database: db)
    }
    
    public func createKnowledgeBase() async throws -> KnowledgeBase {
        let repository = try await createKnowledgeRepository()
        return KnowledgeBase(repository: repository)
    }
    
    public func createBrainStateManager() async throws -> BrainStateManager {
        let repository = try await createBrainStateRepository()
        return BrainStateManager(repository: repository)
    }
    
    public func createMessageCacheManager(forAI aiName: String) async throws -> MessageCacheManager {
        let db = try await getSharedDatabase()
        let repository = FluentMessageCacheRepository(database: db)
        return MessageCacheManager(repository: repository, fromAI: aiName)
    }
    
    public func close() async throws {
        database = nil
        isInitialized = false
        if let databases = databases {
            await databases.shutdownAsync()
            self.databases = nil
        }
        if let threadPool = threadPool {
            try await threadPool.shutdownGracefully()
            self.threadPool = nil
        }
        if let eventLoopGroup = eventLoopGroup {
            try await eventLoopGroup.shutdownGracefully()
            self.eventLoopGroup = nil
        }
        GitBrainLogger.info("Database connection closed")
    }
    
    deinit {
        if isInitialized {
            GitBrainLogger.warning("DatabaseManager deinitialized without calling close()")
        }
    }
}
