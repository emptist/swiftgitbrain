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
    
    @Test("DocumentationRepository can perform CRUD operations")
    func testDocumentationRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createDocumentationRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_doc",
                title: "Test Documentation",
                content: "This is test content",
                summary: nil as String?,
                version: nil as String?,
                lastReviewed: nil as Date?,
                reviewStatus: nil as String?,
                relatedTopics: nil as [String]?,
                externalLinks: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.title == "Test Documentation")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("TestingStrategyRepository can perform CRUD operations")
    func testTestingStrategyRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createTestingStrategyRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_strategy",
                strategyName: "Test Strategy",
                testingType: "unit",
                description: "Test description",
                scope: nil as String?,
                techniques: nil as [String]?,
                tools: nil as [String]?,
                bestPractices: nil as [String]?,
                coverageGoals: nil as String?,
                automationLevel: nil as String?,
                testDataStrategy: nil as String?,
                ciCdIntegration: nil as String?,
                examples: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.strategyName == "Test Strategy")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("DesignPatternRepository can perform CRUD operations")
    func testDesignPatternRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createDesignPatternRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_pattern",
                patternName: "Singleton",
                patternType: "creational",
                description: "Ensure a class only has one instance",
                intent: nil as String?,
                motivation: nil as String?,
                applicability: nil as String?,
                structure: nil as String?,
                participants: nil as [String]?,
                collaborations: nil as String?,
                consequences: nil as [String]?,
                implementation: nil as String?,
                sampleCode: nil as String?,
                knownUses: nil as [String]?,
                relatedPatterns: nil as [String]?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.patternName == "Singleton")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("CodeExampleRepository can perform CRUD operations")
    func testCodeExampleRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createCodeExampleRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_example",
                title: "Test Example",
                description: nil as String?,
                language: "swift",
                code: "let x = 5",
                inputExample: nil as String?,
                outputExample: nil as String?,
                explanation: nil as String?,
                complexity: nil as String?,
                dependencies: nil as [String]?,
                relatedSnippets: nil as [String]?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.title == "Test Example")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("TroubleshootingGuideRepository can perform CRUD operations")
    func testTroubleshootingGuideRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createTroubleshootingGuideRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_issue",
                issueTitle: "Test Issue",
                issueDescription: "Description of test issue",
                symptoms: nil as [String]?,
                rootCause: nil as String?,
                solutions: nil as String?,
                prevention: nil as String?,
                relatedIssues: nil as [String]?,
                severity: nil as String?,
                frequency: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.issueTitle == "Test Issue")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("ApiReferenceRepository can perform CRUD operations")
    func testApiReferenceRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createApiReferenceRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_api",
                apiName: "TestAPI",
                apiType: "REST",
                endpoint: nil as String?,
                method: nil as String?,
                parameters: nil as String?,
                responseSchema: nil as String?,
                authentication: nil as String?,
                rateLimiting: nil as String?,
                examples: nil as String?,
                version: nil as String?,
                deprecated: false,
                deprecationNote: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.apiName == "TestAPI")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
    
    @Test("ArchitecturePatternRepository can perform CRUD operations")
    func testArchitecturePatternRepositoryCRUD() async throws {
        let config = DatabaseConfig.forTesting(projectName: "swiftgitbraintests")
        let dbManager = DatabaseManager(config: config)
        
        do {
            let repository = try await dbManager.createArchitecturePatternRepository()
            
            let testId = UUID()
            try await repository.add(
                knowledgeId: testId,
                category: "test",
                key: "test_arch",
                patternName: "MVC",
                description: "Model-View-Controller pattern",
                problem: nil as String?,
                solution: nil as String?,
                consequences: nil as [String]?,
                useCases: nil as [String]?,
                relatedPatterns: nil as [String]?,
                examples: nil as String?,
                createdBy: "test",
                tags: nil as [String]?
            )
            
            let retrieved = try await repository.get(knowledgeId: testId)
            #expect(retrieved != nil)
            #expect(retrieved?.patternName == "MVC")
            
            let deleted = try await repository.delete(knowledgeId: testId)
            #expect(deleted == true)
            
            try await dbManager.close()
        } catch {
            Issue.record("CRUD test failed: \(error)")
        }
    }
}
