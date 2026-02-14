import Testing
import Foundation
import Fluent
import NIO
@testable import GitBrainSwift

@Suite("Repository Integration Tests with New Database Naming")
struct RepositoryIntegrationTests {
    
    @Test("DatabaseConfig supports gitbrain_<project> naming")
    func testDatabaseConfigNaming() async throws {
        let config1 = DatabaseConfig(projectName: "testproject")
        #expect(config1.database == "gitbrain_testproject")
        #expect(config1.projectName == "testproject")
        
        let config2 = DatabaseConfig(database: "gitbrain_customdb")
        #expect(config2.database == "gitbrain_customdb")
        #expect(config2.projectName == "customdb")
        
        let config3 = DatabaseConfig(database: "plainname")
        #expect(config3.database == "plainname")
        #expect(config3.projectName == "plainname")
    }
    
    @Test("DatabaseConfig integrates with GitBrainConfig")
    func testGitBrainConfigIntegration() async throws {
        let gitBrainConfig = GitBrainConfig(
            databaseName: "gitbrain_myproject",
            databaseHost: "localhost",
            databasePort: 5432
        )
        
        let dbConfig = DatabaseConfig(from: gitBrainConfig)
        #expect(dbConfig.database == "gitbrain_myproject")
        #expect(dbConfig.projectName == "myproject")
        #expect(dbConfig.host == "localhost")
        #expect(dbConfig.port == 5432)
    }
    
    @Test("DatabaseConfig forTesting creates correct database name")
    func testForTestingConfig() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        #expect(config.database == "gitbrain_swiftgitbraintests")
        #expect(config.projectName == "swiftgitbraintests")
        #expect(config.host == "localhost")
        #expect(config.port == 5432)
    }
    
    @Test("Repository can connect to test database")
    func testRepositoryConnection() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let _ = try await dbManager.initialize()
            
            try await dbManager.close()
        } catch {
            Issue.record("Failed to connect to test database: \(error)")
        }
    }
    
    @Test("CodeSnippetRepository can perform CRUD operations")
    func testCodeSnippetRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createCodeSnippetRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_key",
                language: "swift",
                code: "print(\"hello\")",
                description: "Test snippet",
                usageExample: nil as String?,
                dependencies: nil as [String]?,
                framework: nil as String?,
                version: nil as String?,
                complexity: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.category == "test")
            #expect(retrieved?.language == "swift")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
}
