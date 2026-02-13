import Foundation

public actor BrainStateManager: @unchecked Sendable, BrainStateManagerProtocol {
    private let repository: BrainStateRepositoryProtocol
    
    public init(repository: BrainStateRepositoryProtocol) {
        self.repository = repository
        GitBrainLogger.info("BrainStateManager initialized with Fluent repository")
    }
    
    public func createBrainState(aiName: String, role: RoleType, initialState: SendableContent? = nil) async throws -> BrainState {
        GitBrainLogger.debug("Creating brain state: aiName=\(aiName), role=\(role)")
        try await repository.create(aiName: aiName, role: role, state: initialState, timestamp: Date())
        GitBrainLogger.info("Successfully created brain state: aiName=\(aiName)")
        return BrainState(
            aiName: aiName,
            role: role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: initialState?.toAnyDict() ?? [:]
        )
    }
    
    public func loadBrainState(aiName: String) async throws -> BrainState? {
        GitBrainLogger.debug("Loading brain state: aiName=\(aiName)")
        guard let result = try await repository.load(aiName: aiName) else {
            GitBrainLogger.debug("Brain state not found: aiName=\(aiName)")
            return nil
        }
        GitBrainLogger.debug("Successfully loaded brain state: aiName=\(aiName)")
        return BrainState(
            aiName: aiName,
            role: result.role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: result.timestamp),
            state: result.state?.toAnyDict() ?? [:]
        )
    }
    
    public func saveBrainState(_ brainState: BrainState) async throws {
        GitBrainLogger.debug("Saving brain state: aiName=\(brainState.aiName)")
        try await repository.save(aiName: brainState.aiName, role: brainState.role, state: brainState.state, timestamp: Date())
        GitBrainLogger.info("Successfully saved brain state: aiName=\(brainState.aiName)")
    }
    
    public func updateBrainState(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        GitBrainLogger.debug("Updating brain state: aiName=\(aiName), key=\(key)")
        let result = try await repository.update(aiName: aiName, key: key, value: value)
        if result {
            GitBrainLogger.info("Successfully updated brain state: aiName=\(aiName), key=\(key)")
        } else {
            GitBrainLogger.warning("Brain state not found for update: aiName=\(aiName), key=\(key)")
        }
        return result
    }
    
    public func getBrainStateValue(aiName: String, key: String, defaultValue: SendableContent? = nil) async throws -> SendableContent? {
        GitBrainLogger.debug("Getting brain state value: aiName=\(aiName), key=\(key)")
        let result = try await repository.get(aiName: aiName, key: key, defaultValue: defaultValue)
        GitBrainLogger.debug("Successfully retrieved brain state value: aiName=\(aiName), key=\(key)")
        return result
    }
    
    public func deleteBrainState(aiName: String) async throws -> Bool {
        GitBrainLogger.debug("Deleting brain state: aiName=\(aiName)")
        let result = try await repository.delete(aiName: aiName)
        if result {
            GitBrainLogger.info("Successfully deleted brain state: aiName=\(aiName)")
        } else {
            GitBrainLogger.warning("Brain state not found for deletion: aiName=\(aiName)")
        }
        return result
    }
    
    public func listBrainStates() async throws -> [String] {
        GitBrainLogger.debug("Listing brain states")
        let aiNames = try await repository.list()
        GitBrainLogger.debug("Found \(aiNames.count) brain states")
        return aiNames
    }
    
    public func backupBrainState(aiName: String, backupSuffix: String? = nil) async throws -> String? {
        GitBrainLogger.debug("Backing up brain state: aiName=\(aiName)")
        let result = try await repository.backup(aiName: aiName, backupSuffix: backupSuffix)
        if let result = result {
            GitBrainLogger.info("Successfully backed up brain state: aiName=\(aiName), backup=\(result)")
        } else {
            GitBrainLogger.warning("Brain state not found for backup: aiName=\(aiName)")
        }
        return result
    }
    
    public func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool {
        GitBrainLogger.debug("Restoring brain state: aiName=\(aiName), backup=\(backupFile)")
        let result = try await repository.restore(aiName: aiName, backupFile: backupFile)
        if result {
            GitBrainLogger.info("Successfully restored brain state: aiName=\(aiName)")
        } else {
            GitBrainLogger.warning("Failed to restore brain state: aiName=\(aiName)")
        }
        return result
    }
}
