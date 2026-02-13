import Foundation
import GitBrainSwift

@main
struct GitBrainMigrationCLI {
    static func main() async throws {
        let arguments = CommandLine.arguments
        
        if arguments.count < 2 {
            printUsage()
            return
        }
        
        let command = arguments[1]
        
        switch command {
        case "migrate":
            try await handleMigration(arguments: Array(arguments.dropFirst()))
        case "validate":
            try await handleValidation(arguments: Array(arguments.dropFirst()))
        case "help", "--help", "-h":
            printUsage()
        default:
            print("Unknown command: \(command)")
            printUsage()
        }
    }
    
    private static func handleMigration(arguments: [String]) async throws {
        guard arguments.count >= 2 else {
            print("Error: Missing required arguments")
            printUsage()
            return
        }
        
        let sourceType = arguments[0]
        let sourcePath = arguments[1]
        
        let sourceURL = URL(fileURLWithPath: sourcePath)
        
        let config = DatabaseConfig.fromEnvironment()
        let dbManager = DatabaseManager(config: config)
        
        do {
            _ = try await dbManager.initialize()
            
            let migration = DataMigration()
            
            switch sourceType {
            case "knowledge":
                let repository = try await dbManager.createKnowledgeRepository()
                try await migration.migrateKnowledgeBase(from: sourceURL, to: repository)
            case "brainstate":
                let repository = try await dbManager.createBrainStateRepository()
                try await migration.migrateBrainStates(from: sourceURL, to: repository)
            default:
                print("Error: Unknown source type '\(sourceType)'. Use 'knowledge' or 'brainstate'")
            }
            
            try await dbManager.close()
            print("Migration completed successfully!")
        } catch {
            try? await dbManager.close()
            print("Migration failed: \(error)")
            exit(1)
        }
    }
    
    private static func handleValidation(arguments: [String]) async throws {
        let config = DatabaseConfig.fromEnvironment()
        let dbManager = DatabaseManager(config: config)
        
        do {
            _ = try await dbManager.initialize()
            
            let migration = DataMigration()
            let repository = try await dbManager.createKnowledgeRepository()
            let brainStateRepo = try await dbManager.createBrainStateRepository()
            
            let report = try await migration.validateMigration(knowledgeRepo: repository, brainStateRepo: brainStateRepo)
            
            print(report.description)
            
            try await dbManager.close()
        } catch {
            try? await dbManager.close()
            print("Validation failed: \(error)")
            exit(1)
        }
    }
    
    private static func printUsage() {
        print("""
        GitBrain Migration Tool
        
        Usage:
          gitbrain-migrate migrate <source_type> <source_path>
            Migrate data from file-based storage to PostgreSQL
            
            source_type: 'knowledge' or 'brainstate'
            source_path: Path to GitBrain folder containing data
            
          gitbrain-migrate validate
            Validate migration and show report
        
        Environment Variables:
          GITBRAIN_DB_HOST     Database host (default: localhost)
          GITBRAIN_DB_PORT     Database port (default: 5432)
          GITBRAIN_DB_NAME     Database name (default: gitbrain)
          GITBRAIN_DB_USER     Database user (default: postgres)
          GITBRAIN_DB_PASSWORD Database password (default: postgres)
        
        Examples:
          gitbrain-migrate migrate knowledge ./GitBrain
          gitbrain-migrate migrate brainstate ./GitBrain
          gitbrain-migrate validate
        """)
    }
}