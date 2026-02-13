import Foundation

public struct DataMigration: Sendable {
    
    public init() {}
    
    public func migrateKnowledgeBase(from fileBase: URL, to repository: KnowledgeRepositoryProtocol) async throws {
        GitBrainLogger.info("Starting knowledge base migration from \(fileBase.path)")
        
        let categoriesPath = fileBase.appendingPathComponent("Knowledge")
        guard FileManager.default.fileExists(atPath: categoriesPath.path) else {
            GitBrainLogger.warning("Knowledge directory not found: \(categoriesPath.path)")
            return
        }
        
        let categories = try FileManager.default.contentsOfDirectory(at: categoriesPath, includingPropertiesForKeys: nil)
        GitBrainLogger.info("Found \(categories.count) categories to migrate")
        
        var totalItems = 0
        var failedItems = 0
        
        for categoryURL in categories {
            let category = categoryURL.lastPathComponent
            guard category != ".DS_Store" else { continue }
            
            let keys = try FileManager.default.contentsOfDirectory(at: categoryURL, includingPropertiesForKeys: nil)
            GitBrainLogger.info("Migrating \(keys.count) items from category '\(category)'")
            
            for keyURL in keys {
                let key = keyURL.deletingPathExtension().lastPathComponent
                guard key != ".DS_Store" else { continue }
                
                do {
                    let data = try Data(contentsOf: keyURL)
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                    
                    let value = SendableContent(json)
                    let metadata = SendableContent(["timestamp": Date()])
                    
                    try await repository.add(
                        category: category,
                        key: key,
                        value: value,
                        metadata: metadata,
                        timestamp: Date()
                    )
                    
                    totalItems += 1
                } catch {
                    GitBrainLogger.error("Failed to migrate item \(category)/\(key): \(error)")
                    failedItems += 1
                }
            }
        }
        
        GitBrainLogger.info("Knowledge base migration complete: \(totalItems) items migrated, \(failedItems) failed")
        
        if failedItems > 0 {
            throw MigrationError.partialFailure(totalItems: totalItems, failedItems: failedItems)
        }
    }
    
    public func migrateBrainStates(from fileBase: URL, to repository: BrainStateRepositoryProtocol) async throws {
        GitBrainLogger.info("Starting brain state migration from \(fileBase.path)")
        
        let brainStatePath = fileBase.appendingPathComponent("BrainState")
        guard FileManager.default.fileExists(atPath: brainStatePath.path) else {
            GitBrainLogger.warning("BrainState directory not found: \(brainStatePath.path)")
            return
        }
        
        let stateFiles = try FileManager.default.contentsOfDirectory(at: brainStatePath, includingPropertiesForKeys: nil)
        GitBrainLogger.info("Found \(stateFiles.count) brain states to migrate")
        
        var totalStates = 0
        var failedStates = 0
        
        for stateFile in stateFiles {
            let aiName = stateFile.deletingPathExtension().lastPathComponent
            guard aiName != ".DS_Store" else { continue }
            
            do {
                let data = try Data(contentsOf: stateFile)
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                
                let state = SendableContent(json["state"] as? [String: Any] ?? [:])
                let roleString = json["role"] as? String ?? "coder"
                let role: RoleType = roleString == "overseer" ? .overseer : .coder
                let timestamp = Date()
                
                try await repository.save(
                    aiName: aiName,
                    role: role,
                    state: state,
                    timestamp: timestamp
                )
                
                totalStates += 1
            } catch {
                GitBrainLogger.error("Failed to migrate brain state for \(aiName): \(error)")
                failedStates += 1
            }
        }
        
        GitBrainLogger.info("Brain state migration complete: \(totalStates) states migrated, \(failedStates) failed")
        
        if failedStates > 0 {
            throw MigrationError.partialFailure(totalItems: totalStates, failedItems: failedStates)
        }
    }
    
    public func validateMigration(knowledgeRepo: KnowledgeRepositoryProtocol, brainStateRepo: BrainStateRepositoryProtocol) async throws -> MigrationReport {
        var report = MigrationReport()
        
        let kbCategories = try await knowledgeRepo.listCategories()
        report.knowledgeCategories = kbCategories.count
        
        for category in kbCategories {
            let keys = try await knowledgeRepo.listKeys(category: category)
            report.knowledgeItems += keys.count
        }
        
        let brainStateNames = try await brainStateRepo.list()
        report.brainStates = brainStateNames.count
        
        return report
    }
}

public enum MigrationError: Error, LocalizedError {
    case sourceNotFound(URL)
    case destinationNotReady
    case partialFailure(totalItems: Int, failedItems: Int)
    case validationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .sourceNotFound(let url):
            return "Source not found: \(url.path)"
        case .destinationNotReady:
            return "Destination database is not ready"
        case .partialFailure(let total, let failed):
            return "Migration partially failed: \(failed)/\(total) items failed"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        }
    }
}

public struct MigrationReport: Sendable {
    public var knowledgeCategories: Int = 0
    public var knowledgeItems: Int = 0
    public var brainStates: Int = 0
    
    public var totalItems: Int {
        return knowledgeItems + brainStates
    }
    
    public var description: String {
        return """
        Migration Report:
        - Knowledge Categories: \(knowledgeCategories)
        - Knowledge Items: \(knowledgeItems)
        - Brain States: \(brainStates)
        - Total Items: \(totalItems)
        """
    }
}