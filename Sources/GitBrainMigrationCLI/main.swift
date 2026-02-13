import Foundation
import ArgumentParser
import GitBrainSwift

struct MigrationCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "migration",
        abstract: "GitBrain Migration CLI - Migrate data from file-based storage to PostgreSQL",
        subcommands: [MigrateCommand.self, RollbackCommand.self, StatusCommand.self, ValidateCommand.self, SnapshotCommand.self]
    )
}

struct MigrateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Migrate data from file-based storage to PostgreSQL"
    )
    
    @Option(name: .shortAndLong, help: "Path to file-based storage directory")
    var sourcePath: String?
    
    @Option(name: .shortAndLong, help: "Migrate knowledge base only")
    var knowledgeOnly: Bool = false
    
    @Option(name: .shortAndLong, help: "Migrate brain states only")
    var brainStateOnly: Bool = false
    
    @Option(name: .shortAndLong, help: "Dry run - preview migration without executing")
    var dryRun: Bool = false
    
    @Option(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false
    
    @Option(name: .shortAndLong, help: "Create snapshot before migration")
    var snapshot: Bool = true
    
    func run() throws {
        let migration = DataMigration()
        let progress = ConsoleProgress(verbose: verbose)
        
        Task {
            do {
                if dryRun {
                    print("🔍 Dry run mode - previewing migration...")
                    print("Source path: \(sourcePath ?? "default")")
                    print("Knowledge only: \(knowledgeOnly)")
                    print("Brain state only: \(brainStateOnly)")
                    print("Snapshot: \(snapshot)")
                    return
                }
                
                let dbManager = DatabaseManager()
                let databases = try await dbManager.initialize()
                let knowledgeRepo = try await dbManager.createKnowledgeRepository()
                let brainStateRepo = try await dbManager.createBrainStateRepository()
                
                var currentSnapshot: MigrationSnapshot?
                if snapshot {
                    print("📸 Creating snapshot before migration...")
                    currentSnapshot = try await migration.createSnapshot(knowledgeRepo: knowledgeRepo, brainStateRepo: brainStateRepo)
                    print("✅ Snapshot created: \(currentSnapshot?.id ?? "unknown")")
                }
                
                let sourceURL: URL
                if let path = sourcePath {
                    sourceURL = URL(fileURLWithPath: path)
                } else {
                    sourceURL = URL(fileURLWithPath: ".")
                }
                
                if !brainStateOnly {
                    print("📚 Migrating knowledge base...")
                    let kbResult = try await migration.migrateKnowledgeBase(from: sourceURL, to: knowledgeRepo, progress: progress, snapshot: currentSnapshot)
                    print("✅ Knowledge base migration complete: \(kbResult.itemsMigrated) items migrated in \(String(format: "%.2f", kbResult.duration))s")
                    if kbResult.itemsFailed > 0 {
                        print("⚠️  \(kbResult.itemsFailed) items failed to migrate")
                    }
                }
                
                if !knowledgeOnly {
                    print("🧠 Migrating brain states...")
                    let bsResult = try await migration.migrateBrainStates(from: sourceURL, to: brainStateRepo, progress: progress, snapshot: currentSnapshot)
                    print("✅ Brain state migration complete: \(bsResult.itemsMigrated) states migrated in \(String(format: "%.2f", bsResult.duration))s")
                    if bsResult.itemsFailed > 0 {
                        print("⚠️  \(bsResult.itemsFailed) states failed to migrate")
                    }
                }
                
                print("🎉 Migration completed successfully!")
                
            } catch {
                print("❌ Migration failed: \(error)")
                throw error
            }
        }
    }
}

struct RollbackCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rollback",
        abstract: "Rollback migration to a previous snapshot"
    )
    
    @Option(name: .shortAndLong, help: "Snapshot ID to rollback to")
    var snapshotId: String?
    
    @Option(name: .shortAndLong, help: "Rollback specific knowledge item (format: category/key)")
    var knowledgeItem: String?
    
    @Option(name: .shortAndLong, help: "Rollback specific brain state")
    var brainState: String?
    
    @Option(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false
    
    func run() throws {
        let migration = DataMigration()
        let progress = ConsoleProgress(verbose: verbose)
        
        Task {
            do {
                let dbManager = DatabaseManager()
                let databases = try await dbManager.initialize()
                let knowledgeRepo = try await dbManager.createKnowledgeRepository()
                let brainStateRepo = try await dbManager.createBrainStateRepository()
                
                if let snapshotId = snapshotId {
                    print("🔄 Rolling back to snapshot: \(snapshotId)")
                    
                    let snapshot = MigrationSnapshot(id: snapshotId, timestamp: Date())
                    try await migration.rollback(to: snapshot, knowledgeRepo: knowledgeRepo, brainStateRepo: brainStateRepo)
                    
                    print("✅ Rollback to snapshot \(snapshotId) completed successfully")
                } else if let knowledgeItem = knowledgeItem {
                    let parts = knowledgeItem.split(separator: "/")
                    guard parts.count == 2 else {
                        print("❌ Invalid knowledge item format. Use: category/key")
                        return
                    }
                    
                    let category = String(parts[0])
                    let key = String(parts[1])
                    
                    print("🔄 Rolling back knowledge item: \(category)/\(key)")
                    
                    let snapshot = MigrationSnapshot()
                    try await migration.rollbackItem(category: category, key: key, snapshot: snapshot, knowledgeRepo: knowledgeRepo)
                    
                    print("✅ Knowledge item rollback completed")
                } else if let brainState = brainState {
                    print("🔄 Rolling back brain state: \(brainState)")
                    
                    let snapshot = MigrationSnapshot()
                    try await migration.rollbackBrainState(aiName: brainState, snapshot: snapshot, brainStateRepo: brainStateRepo)
                    
                    print("✅ Brain state rollback completed")
                } else {
                    print("❌ No rollback target specified. Use --snapshot-id, --knowledge-item, or --brain-state")
                }
                
            } catch {
                print("❌ Rollback failed: \(error)")
                throw error
            }
        }
    }
}

struct StatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Check migration status and database health"
    )
    
    @Option(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false
    
    func run() throws {
        Task {
            do {
                let dbManager = DatabaseManager()
                let databases = try await dbManager.initialize()
                let knowledgeRepo = try await dbManager.createKnowledgeRepository()
                let brainStateRepo = try await dbManager.createBrainStateRepository()
                
                print("📊 Migration Status")
                print("=" * 50)
                
                let migration = DataMigration()
                let progress = ConsoleProgress(verbose: verbose)
                let report = try await migration.validateMigration(knowledgeRepo: knowledgeRepo, brainStateRepo: brainStateRepo, progress: progress)
                
                print(report.description)
                print("=" * 50)
                print("✅ Database is healthy and ready")
                
            } catch {
                print("❌ Status check failed: \(error)")
                throw error
            }
        }
    }
}

struct ValidateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate migration integrity"
    )
    
    @Option(name: .shortAndLong, help: "Path to file-based storage directory")
    var sourcePath: String?
    
    @Option(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false
    
    func run() throws {
        Task {
            do {
                let sourceURL: URL
                if let path = sourcePath {
                    sourceURL = URL(fileURLWithPath: path)
                } else {
                    sourceURL = URL(fileURLWithPath: ".")
                }
                
                let dbManager = DatabaseManager()
                let databases = try await dbManager.initialize()
                let knowledgeRepo = try await dbManager.createKnowledgeRepository()
                let brainStateRepo = try await dbManager.createBrainStateRepository()
                
                print("🔍 Validating migration integrity...")
                print("=" * 50)
                
                let migration = DataMigration()
                let progress = ConsoleProgress(verbose: verbose)
                let report = try await migration.validateMigration(knowledgeRepo: knowledgeRepo, brainStateRepo: brainStateRepo, progress: progress)
                
                print(report.description)
                
                let categoriesPath = sourceURL.appendingPathComponent("Knowledge")
                if FileManager.default.fileExists(atPath: categoriesPath.path) {
                    let categories = try FileManager.default.contentsOfDirectory(at: categoriesPath, includingPropertiesForKeys: nil)
                    let fileKnowledgeItems = categories.reduce(0) { total, category in
                        let keys = try? FileManager.default.contentsOfDirectory(at: category, includingPropertiesForKeys: nil)
                        return total + (keys?.count ?? 0)
                    }
                    
                    print("\n📁 File-based storage:")
                    print("   Knowledge items: \(fileKnowledgeItems)")
                    print("   Database items: \(report.knowledgeItems)")
                    
                    if fileKnowledgeItems == report.knowledgeItems {
                        print("   ✅ Knowledge items match")
                    } else {
                        print("   ⚠️  Knowledge items mismatch: \(fileKnowledgeItems) vs \(report.knowledgeItems)")
                    }
                }
                
                let brainStatePath = sourceURL.appendingPathComponent("BrainState")
                if FileManager.default.fileExists(atPath: brainStatePath.path) {
                    let stateFiles = try FileManager.default.contentsOfDirectory(at: brainStatePath, includingPropertiesForKeys: nil)
                    let fileBrainStates = stateFiles.filter { $0.lastPathComponent != ".DS_Store" }.count
                    
                    print("\n   Brain states: \(fileBrainStates)")
                    print("   Database states: \(report.brainStates)")
                    
                    if fileBrainStates == report.brainStates {
                        print("   ✅ Brain states match")
                    } else {
                        print("   ⚠️  Brain states mismatch: \(fileBrainStates) vs \(report.brainStates)")
                    }
                }
                
                print("=" * 50)
                print("✅ Validation complete")
                
            } catch {
                print("❌ Validation failed: \(error)")
                throw error
            }
        }
    }
}

struct SnapshotCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "snapshot",
        abstract: "Create and manage migration snapshots"
    )
    
    @Option(name: .shortAndLong, help: "Create a new snapshot")
    var create: Bool = false
    
    @Option(name: .shortAndLong, help: "List all snapshots")
    var list: Bool = false
    
    @Option(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false
    
    func run() throws {
        Task {
            do {
                let dbManager = DatabaseManager()
                let databases = try await dbManager.initialize()
                let knowledgeRepo = try await dbManager.createKnowledgeRepository()
                let brainStateRepo = try await dbManager.createBrainStateRepository()
                
                let migration = DataMigration()
                
                if create {
                    print("📸 Creating snapshot...")
                    let snapshot = try await migration.createSnapshot(knowledgeRepo: knowledgeRepo, brainStateRepo: brainStateRepo)
                    print("✅ Snapshot created: \(snapshot.id)")
                    print("   Knowledge items: \(snapshot.knowledgeItems.count)")
                    print("   Brain states: \(snapshot.brainStates.count)")
                    print("   Timestamp: \(snapshot.timestamp)")
                } else if list {
                    print("📋 Snapshots:")
                    print("   (Snapshot listing not implemented yet)")
                } else {
                    print("❌ No action specified. Use --create or --list")
                }
                
            } catch {
                print("❌ Snapshot operation failed: \(error)")
                throw error
            }
        }
    }
}

struct ConsoleProgress: MigrationProgressProtocol {
    let verbose: Bool
    
    init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    func reportProgress(phase: String, current: Int, total: Int, message: String) {
        let percent = total > 0 ? Int(Double(current) / Double(total) * 100) : 0
        let progressBar = String(repeating: "█", count: percent / 2) + String(repeating: "░", count: 50 - percent / 2)
        print("[\(progressBar)] \(percent)% - \(phase): \(message)")
    }
    
    func reportError(error: Error, context: String) {
        print("❌ Error in \(context): \(error.localizedDescription)")
        if verbose {
            print("   Details: \(error)")
        }
    }
    
    func reportCompletion(result: MigrationResult) {
        print("\n📊 Migration Result:")
        print("   Success: \(result.success ? "✅" : "❌")")
        print("   Items migrated: \(result.itemsMigrated)")
        print("   Items failed: \(result.itemsFailed)")
        print("   Duration: \(String(format: "%.2f", result.duration))s")
        if let snapshotId = result.snapshotId {
            print("   Snapshot ID: \(snapshotId)")
        }
        if !result.errors.isEmpty {
            print("   Errors: \(result.errors.count)")
            if verbose {
                for error in result.errors.prefix(5) {
                    print("      - \(error.item): \(error.error)")
                }
            }
        }
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

MigrationCLI.main()