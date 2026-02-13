import Foundation

public protocol MigrationProgressProtocol: Sendable {
    func reportProgress(phase: String, current: Int, total: Int, message: String)
    func reportError(error: Error, context: String)
    func reportCompletion(result: MigrationResult)
}

public protocol MigrationRollbackProtocol: Sendable {
    func createSnapshot() async throws -> MigrationSnapshot
    func rollback(to snapshot: MigrationSnapshot) async throws
    func rollbackItem(category: String, key: String) async throws
    func rollbackBrainState(aiName: String) async throws
}

public struct MigrationSnapshot: Sendable {
    public let id: String
    public let timestamp: Date
    public let knowledgeItems: [KnowledgeItemSnapshot]
    public let brainStates: [BrainStateSnapshot]
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), knowledgeItems: [KnowledgeItemSnapshot] = [], brainStates: [BrainStateSnapshot] = []) {
        self.id = id
        self.timestamp = timestamp
        self.knowledgeItems = knowledgeItems
        self.brainStates = brainStates
    }
}

public struct KnowledgeItemSnapshot: Sendable {
    public let category: String
    public let key: String
    public let value: SendableContent
    public let metadata: SendableContent
    public let timestamp: Date
    
    public init(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) {
        self.category = category
        self.key = key
        self.value = value
        self.metadata = metadata
        self.timestamp = timestamp
    }
}

public struct BrainStateSnapshot: Sendable {
    public let aiName: String
    public let role: RoleType
    public let state: SendableContent
    public let timestamp: Date
    
    public init(aiName: String, role: RoleType, state: SendableContent, timestamp: Date) {
        self.aiName = aiName
        self.role = role
        self.state = state
        self.timestamp = timestamp
    }
}

public struct MigrationResult: Sendable {
    public let success: Bool
    public let itemsMigrated: Int
    public let itemsFailed: Int
    public let errors: [MigrationErrorDetail]
    public let duration: TimeInterval
    public let timestamp: Date
    public let snapshotId: String?
    
    public init(success: Bool, itemsMigrated: Int, itemsFailed: Int, errors: [MigrationErrorDetail] = [], duration: TimeInterval, timestamp: Date = Date(), snapshotId: String? = nil) {
        self.success = success
        self.itemsMigrated = itemsMigrated
        self.itemsFailed = itemsFailed
        self.errors = errors
        self.duration = duration
        self.timestamp = timestamp
        self.snapshotId = snapshotId
    }
}

public struct MigrationErrorDetail: Sendable {
    public let item: String
    public let error: String
    public let phase: String
    public let timestamp: Date
    public let retryCount: Int
    
    public init(item: String, error: String, phase: String, timestamp: Date = Date(), retryCount: Int = 0) {
        self.item = item
        self.error = error
        self.phase = phase
        self.timestamp = timestamp
        self.retryCount = retryCount
    }
}

public struct RetryPolicy: Sendable {
    public let maxRetries: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let backoffMultiplier: Double
    
    public init(maxRetries: Int = 5, baseDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 60.0, backoffMultiplier: Double = 2.0) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt))
        return min(exponentialDelay, maxDelay)
    }
    
    public func shouldRetry(attempt: Int, error: Error) -> Bool {
        guard attempt < maxRetries else { return false }
        return isTransientError(error)
    }
    
    private func isTransientError(_ error: Error) -> Bool {
        let errorDescription = error.localizedDescription.lowercased()
        let transientKeywords = ["timeout", "connection", "network", "temporary", "unavailable", "busy", "locked"]
        return transientKeywords.contains { errorDescription.contains($0) }
    }
}

public struct DataMigration: Sendable {
    
    private var currentSnapshot: MigrationSnapshot?
    private var migrationErrors: [MigrationErrorDetail] = []
    private var startTime: Date?
    private let retryPolicy: RetryPolicy
    
    public init(retryPolicy: RetryPolicy = RetryPolicy()) {
        self.retryPolicy = retryPolicy
    }
    
    private func retry<T>(_ operation: @escaping () async throws -> T, item: String, phase: String, progress: MigrationProgressProtocol?) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<retryPolicy.maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                if retryPolicy.shouldRetry(attempt: attempt, error: error) {
                    let delay = retryPolicy.delay(for: attempt)
                    let delayString = String(format: "%.2f", delay)
                    GitBrainLogger.warning("Retry \(attempt + 1)/\(retryPolicy.maxRetries) for \(item) after \(delayString)s delay: \(error.localizedDescription)")
                    progress?.reportError(error: error, context: "Attempt \(attempt + 1) for \(item)")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    break
                }
            }
        }
        
        throw lastError ?? MigrationError.unknownError(item: item)
    }
    
    public func createSnapshot(knowledgeRepo: KnowledgeRepositoryProtocol, brainStateRepo: BrainStateRepositoryProtocol) async throws -> MigrationSnapshot {
        GitBrainLogger.info("Creating migration snapshot")
        
        var knowledgeItems: [KnowledgeItemSnapshot] = []
        let categories = try await knowledgeRepo.listCategories()
        
        for category in categories {
            let keys = try await knowledgeRepo.listKeys(category: category)
            for key in keys {
                if let (value, metadata) = try await knowledgeRepo.get(category: category, key: key) {
                    knowledgeItems.append(KnowledgeItemSnapshot(
                        category: category,
                        key: key,
                        value: value,
                        metadata: metadata,
                        timestamp: Date()
                    ))
                }
            }
        }
        
        var brainStates: [BrainStateSnapshot] = []
        let aiNames = try await brainStateRepo.list()
        
        for aiName in aiNames {
            if let brainState = try await brainStateRepo.load(aiName: aiName) {
                brainStates.append(BrainStateSnapshot(
                    aiName: aiName,
                    role: brainState.role,
                    state: brainState.state,
                    timestamp: brainState.timestamp
                ))
            }
        }
        
        let snapshot = MigrationSnapshot(
            knowledgeItems: knowledgeItems,
            brainStates: brainStates
        )
        
        GitBrainLogger.info("Snapshot created with \(knowledgeItems.count) knowledge items and \(brainStates.count) brain states")
        return snapshot
    }
    
    public func rollback(to snapshot: MigrationSnapshot, knowledgeRepo: KnowledgeRepositoryProtocol, brainStateRepo: BrainStateRepositoryProtocol) async throws {
        GitBrainLogger.info("Rolling back to snapshot \(snapshot.id)")
        
        for item in snapshot.knowledgeItems {
            do {
                try await retry({
                    try await knowledgeRepo.add(
                        category: item.category,
                        key: item.key,
                        value: item.value,
                        metadata: item.metadata,
                        timestamp: item.timestamp
                    )
                }, item: "\(item.category)/\(item.key)", phase: "Rollback", progress: nil)
            } catch {
                GitBrainLogger.error("Failed to rollback knowledge item \(item.category)/\(item.key): \(error)")
                throw MigrationError.rollbackFailed(item: "\(item.category)/\(item.key)", reason: error.localizedDescription)
            }
        }
        
        for state in snapshot.brainStates {
            do {
                try await retry({
                    try await brainStateRepo.save(
                        aiName: state.aiName,
                        role: state.role,
                        state: state.state,
                        timestamp: state.timestamp
                    )
                }, item: state.aiName, phase: "Rollback", progress: nil)
            } catch {
                GitBrainLogger.error("Failed to rollback brain state for \(state.aiName): \(error)")
                throw MigrationError.rollbackFailed(item: state.aiName, reason: error.localizedDescription)
            }
        }
        
        GitBrainLogger.info("Rollback to snapshot \(snapshot.id) completed successfully")
    }
    
    public func rollbackItem(category: String, key: String, snapshot: MigrationSnapshot, knowledgeRepo: KnowledgeRepositoryProtocol) async throws {
        guard let item = snapshot.knowledgeItems.first(where: { $0.category == category && $0.key == key }) else {
            throw MigrationError.itemNotFoundInSnapshot(item: "\(category)/\(key)")
        }
        
        try await knowledgeRepo.add(
            category: item.category,
            key: item.key,
            value: item.value,
            metadata: item.metadata,
            timestamp: item.timestamp
        )
        
        GitBrainLogger.info("Rolled back knowledge item \(category)/\(key)")
    }
    
    public func rollbackBrainState(aiName: String, snapshot: MigrationSnapshot, brainStateRepo: BrainStateRepositoryProtocol) async throws {
        guard let state = snapshot.brainStates.first(where: { $0.aiName == aiName }) else {
            throw MigrationError.itemNotFoundInSnapshot(item: aiName)
        }
        
        try await brainStateRepo.save(
            aiName: state.aiName,
            role: state.role,
            state: state.state,
            timestamp: state.timestamp
        )
        
        GitBrainLogger.info("Rolled back brain state for \(aiName)")
    }
    
    public func migrateKnowledgeBase(from fileBase: URL, to repository: KnowledgeRepositoryProtocol, progress: MigrationProgressProtocol? = nil, snapshot: MigrationSnapshot? = nil) async throws -> MigrationResult {
        startTime = Date()
        migrationErrors = []
        
        GitBrainLogger.info("Starting knowledge base migration from \(fileBase.path)")
        progress?.reportProgress(phase: "Discovery", current: 0, total: 100, message: "Starting migration")
        
        let categoriesPath = fileBase.appendingPathComponent("Knowledge")
        guard FileManager.default.fileExists(atPath: categoriesPath.path) else {
            GitBrainLogger.warning("Knowledge directory not found: \(categoriesPath.path)")
            let result = MigrationResult(success: true, itemsMigrated: 0, itemsFailed: 0, duration: Date().timeIntervalSince(startTime!), snapshotId: snapshot?.id)
            progress?.reportCompletion(result: result)
            return result
        }
        
        let categories = try FileManager.default.contentsOfDirectory(at: categoriesPath, includingPropertiesForKeys: nil)
        GitBrainLogger.info("Found \(categories.count) categories to migrate")
        progress?.reportProgress(phase: "Discovery", current: 10, total: 100, message: "Found \(categories.count) categories")
        
        var totalItems = 0
        var failedItems = 0
        var currentItem = 0
        let totalEstimatedItems = categories.reduce(0) { $0 + (try? FileManager.default.contentsOfDirectory(at: $1, includingPropertiesForKeys: nil).count) ?? 0 }
        
        for categoryURL in categories {
            let category = categoryURL.lastPathComponent
            guard category != ".DS_Store" else { continue }
            
            let keys = try FileManager.default.contentsOfDirectory(at: categoryURL, includingPropertiesForKeys: nil)
            GitBrainLogger.info("Migrating \(keys.count) items from category '\(category)'")
            progress?.reportProgress(phase: "Transfer", current: currentItem, total: totalEstimatedItems, message: "Migrating category '\(category)'")
            
            for keyURL in keys {
                currentItem += 1
                let key = keyURL.deletingPathExtension().lastPathComponent
                guard key != ".DS_Store" else { continue }
                
                var retryCount = 0
                do {
                    try await retry({
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
                    }, item: "\(category)/\(key)", phase: "Transfer", progress: progress)
                    
                    totalItems += 1
                    
                    if currentItem % 10 == 0 {
                        let progressPercent = Int(Double(currentItem) / Double(totalEstimatedItems) * 100)
                        progress?.reportProgress(phase: "Transfer", current: currentItem, total: totalEstimatedItems, message: "Migrated \(currentItem)/\(totalEstimatedItems) items")
                    }
                } catch {
                    GitBrainLogger.error("Failed to migrate item \(category)/\(key) after \(retryCount + 1) attempts: \(error)")
                    migrationErrors.append(MigrationErrorDetail(item: "\(category)/\(key)", error: error.localizedDescription, phase: "Transfer", retryCount: retryCount))
                    failedItems += 1
                    progress?.reportError(error: error, context: "Migrating \(category)/\(key)")
                }
            }
        }
        
        GitBrainLogger.info("Knowledge base migration complete: \(totalItems) items migrated, \(failedItems) failed")
        progress?.reportProgress(phase: "Verification", current: 100, total: 100, message: "Migration complete")
        
        let duration = Date().timeIntervalSince(startTime!)
        let result = MigrationResult(
            success: failedItems == 0,
            itemsMigrated: totalItems,
            itemsFailed: failedItems,
            errors: migrationErrors,
            duration: duration,
            snapshotId: snapshot?.id
        )
        
        progress?.reportCompletion(result: result)
        
        if failedItems > 0 {
            throw MigrationError.partialFailure(totalItems: totalItems, failedItems: failedItems)
        }
        
        return result
    }
    
    public func migrateBrainStates(from fileBase: URL, to repository: BrainStateRepositoryProtocol, progress: MigrationProgressProtocol? = nil, snapshot: MigrationSnapshot? = nil) async throws -> MigrationResult {
        startTime = Date()
        migrationErrors = []
        
        GitBrainLogger.info("Starting brain state migration from \(fileBase.path)")
        progress?.reportProgress(phase: "Discovery", current: 0, total: 100, message: "Starting migration")
        
        let brainStatePath = fileBase.appendingPathComponent("BrainState")
        guard FileManager.default.fileExists(atPath: brainStatePath.path) else {
            GitBrainLogger.warning("BrainState directory not found: \(brainStatePath.path)")
            let result = MigrationResult(success: true, itemsMigrated: 0, itemsFailed: 0, duration: Date().timeIntervalSince(startTime!), snapshotId: snapshot?.id)
            progress?.reportCompletion(result: result)
            return result
        }
        
        let stateFiles = try FileManager.default.contentsOfDirectory(at: brainStatePath, includingPropertiesForKeys: nil)
        GitBrainLogger.info("Found \(stateFiles.count) brain states to migrate")
        progress?.reportProgress(phase: "Discovery", current: 10, total: 100, message: "Found \(stateFiles.count) brain states")
        
        var totalStates = 0
        var failedStates = 0
        var currentState = 0
        
        for stateFile in stateFiles {
            currentState += 1
            let aiName = stateFile.deletingPathExtension().lastPathComponent
            guard aiName != ".DS_Store" else { continue }
            
            var retryCount = 0
            do {
                try await retry({
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
                }, item: aiName, phase: "Transfer", progress: progress)
                
                totalStates += 1
                
                let progressPercent = Int(Double(currentState) / Double(stateFiles.count) * 100)
                progress?.reportProgress(phase: "Transfer", current: currentState, total: stateFiles.count, message: "Migrated \(currentState)/\(stateFiles.count) states")
            } catch {
                GitBrainLogger.error("Failed to migrate brain state for \(aiName) after \(retryCount + 1) attempts: \(error)")
                migrationErrors.append(MigrationErrorDetail(item: aiName, error: error.localizedDescription, phase: "Transfer", retryCount: retryCount))
                failedStates += 1
                progress?.reportError(error: error, context: "Migrating brain state for \(aiName)")
            }
        }
        
        GitBrainLogger.info("Brain state migration complete: \(totalStates) states migrated, \(failedStates) failed")
        progress?.reportProgress(phase: "Verification", current: 100, total: 100, message: "Migration complete")
        
        let duration = Date().timeIntervalSince(startTime!)
        let result = MigrationResult(
            success: failedStates == 0,
            itemsMigrated: totalStates,
            itemsFailed: failedStates,
            errors: migrationErrors,
            duration: duration,
            snapshotId: snapshot?.id
        )
        
        progress?.reportCompletion(result: result)
        
        if failedStates > 0 {
            throw MigrationError.partialFailure(totalItems: totalStates, failedItems: failedStates)
        }
        
        return result
    }
    
    public func validateMigration(knowledgeRepo: KnowledgeRepositoryProtocol, brainStateRepo: BrainStateRepositoryProtocol, progress: MigrationProgressProtocol? = nil) async throws -> MigrationReport {
        progress?.reportProgress(phase: "Validation", current: 0, total: 100, message: "Starting validation")
        
        var report = MigrationReport()
        
        let kbCategories = try await knowledgeRepo.listCategories()
        report.knowledgeCategories = kbCategories.count
        progress?.reportProgress(phase: "Validation", current: 25, total: 100, message: "Validating \(kbCategories.count) categories")
        
        for category in kbCategories {
            let keys = try await knowledgeRepo.listKeys(category: category)
            report.knowledgeItems += keys.count
        }
        
        let brainStateNames = try await brainStateRepo.list()
        report.brainStates = brainStateNames.count
        progress?.reportProgress(phase: "Validation", current: 100, total: 100, message: "Validation complete")
        
        return report
    }
}

public enum MigrationError: Error, LocalizedError {
    case sourceNotFound(URL)
    case destinationNotReady
    case partialFailure(totalItems: Int, failedItems: Int)
    case validationFailed(String)
    case rollbackFailed(item: String, reason: String)
    case itemNotFoundInSnapshot(item: String)
    case unknownError(item: String)
    
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
        case .rollbackFailed(let item, let reason):
            return "Rollback failed for \(item): \(reason)"
        case .itemNotFoundInSnapshot(let item):
            return "Item not found in snapshot: \(item)"
        case .unknownError(let item):
            return "Unknown error for \(item)"
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