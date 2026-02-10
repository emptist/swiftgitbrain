import Foundation

public protocol BrainStateManagerProtocol: Sendable {
    func createBrainState(aiName: String, role: RoleType, initialState: [String: Any]?) async throws -> BrainState
    func loadBrainState(aiName: String) async throws -> BrainState?
    func saveBrainState(_ brainState: BrainState) async throws
    func updateBrainState(aiName: String, key: String, value: Any) async throws -> Bool
    func getBrainStateValue(aiName: String, key: String, defaultValue: Any?) async throws -> Any?
    func deleteBrainState(aiName: String) async throws -> Bool
    func listBrainStates() async throws -> [String]
    func backupBrainState(aiName: String, backupSuffix: String?) async throws -> String?
    func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool
}

public actor BrainStateManager: BrainStateManagerProtocol {
    private let brainstateBase: URL
    private let fileManager: FileManager
    
    public init(brainstateBase: URL) {
        self.brainstateBase = brainstateBase
        self.fileManager = FileManager.default
    }
    
    public func createBrainState(aiName: String, role: RoleType, initialState: [String: Any]? = nil) async throws -> BrainState {
        let brainState = BrainState(
            aiName: aiName,
            role: role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: initialState ?? [:]
        )
        
        try await saveBrainState(brainState)
        return brainState
    }
    
    public func loadBrainState(aiName: String) async throws -> BrainState? {
        let brainStatePath = brainstateBase.appendingPathComponent("\(aiName)_state.json")
        
        guard fileManager.fileExists(atPath: brainStatePath.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: brainStatePath)
        return try JSONDecoder().decode(BrainState.self, from: data)
    }
    
    public func saveBrainState(_ brainState: BrainState) async throws {
        try fileManager.createDirectory(at: brainstateBase, withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(brainState)
        
        let brainStatePath = brainstateBase.appendingPathComponent("\(brainState.aiName)_state.json")
        try data.write(to: brainStatePath)
    }
    
    public func updateBrainState(aiName: String, key: String, value: Any) async throws -> Bool {
        guard var brainState = try await loadBrainState(aiName: aiName) else {
            return false
        }
        
        brainState.updateState(key: key, value: value)
        try await saveBrainState(brainState)
        return true
    }
    
    public func getBrainStateValue(aiName: String, key: String, defaultValue: Any? = nil) async throws -> Any? {
        guard let brainState = try await loadBrainState(aiName: aiName) else {
            return defaultValue
        }
        
        return brainState.getState(key: key, defaultValue: defaultValue)
    }
    
    public func deleteBrainState(aiName: String) async throws -> Bool {
        let brainStatePath = brainstateBase.appendingPathComponent("\(aiName)_state.json")
        
        guard fileManager.fileExists(atPath: brainStatePath.path) else {
            return false
        }
        
        try fileManager.removeItem(at: brainStatePath)
        return true
    }
    
    public func listBrainStates() async throws -> [String] {
        guard fileManager.fileExists(atPath: brainstateBase.path) else {
            return []
        }
        
        let files = try fileManager.contentsOfDirectory(at: brainstateBase, includingPropertiesForKeys: nil)
        return files
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().replacingOccurrences(of: "_state", with: "") }
    }
    
    public func backupBrainState(aiName: String, backupSuffix: String? = nil) async throws -> String? {
        guard let brainState = try await loadBrainState(aiName: aiName) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: Date())
        let suffix = backupSuffix ?? dateStr
        let backupFileName = "\(aiName)_state_\(suffix).bak"
        let backupPath = brainstateBase.appendingPathComponent(backupFileName)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(brainState)
        try data.write(to: backupPath)
        
        return backupPath.path
    }
    
    public func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool {
        let backupPath = brainstateBase.appendingPathComponent(backupFile)
        
        guard fileManager.fileExists(atPath: backupPath.path) else {
            return false
        }
        
        let data = try Data(contentsOf: backupPath)
        let brainState = try JSONDecoder().decode(BrainState.self, from: data)
        
        try await saveBrainState(brainState)
        return true
    }
}
