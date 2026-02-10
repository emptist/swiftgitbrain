import Foundation

public protocol BrainStateManagerProtocol: Sendable {
    func createBrainState(aiName: String, role: RoleType, initialState: SendableContent?) async throws -> BrainState
    func loadBrainState(aiName: String) async throws -> BrainState?
    func saveBrainState(_ brainState: BrainState) async throws
    func updateBrainState(aiName: String, key: String, value: SendableContent) async throws -> Bool
    func getBrainStateValue(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent?
    func deleteBrainState(aiName: String) async throws -> Bool
    func listBrainStates() async throws -> [String]
    func backupBrainState(aiName: String, backupSuffix: String?) async throws -> String?
    func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool
}

public struct BrainStateManager: @unchecked Sendable, BrainStateManagerProtocol {
    private let brainstateBase: URL
    private let fileManager: FileManager
    
    private actor Storage {
        let brainstateBase: URL
        let fileManager: FileManager
        
        init(brainstateBase: URL, fileManager: FileManager) {
            self.brainstateBase = brainstateBase
            self.fileManager = fileManager
        }
        
        func createBrainState(aiName: String, role: RoleType, initialState: TaskData?) async throws -> BrainState {
            let brainState = BrainState(
                aiName: aiName,
                role: role,
                version: "1.0.0",
                lastUpdated: ISO8601DateFormatter().string(from: Date()),
                state: initialState?.data ?? [:]
            )
            
            try await saveBrainState(brainState)
            return brainState
        }
        
        func loadBrainState(aiName: String) async throws -> BrainState? {
            let brainStatePath = brainstateBase.appendingPathComponent("\(aiName)_state.json")
            
            guard fileManager.fileExists(atPath: brainStatePath.path) else {
                return nil
            }
            
            let data = try Data(contentsOf: brainStatePath)
            return try JSONDecoder().decode(BrainState.self, from: data)
        }
        
        func saveBrainState(_ brainState: BrainState) async throws {
            try fileManager.createDirectory(at: brainstateBase, withIntermediateDirectories: true)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(brainState)
            
            let brainStatePath = brainstateBase.appendingPathComponent("\(brainState.aiName)_state.json")
            try data.write(to: brainStatePath)
        }
        
        func updateBrainState(aiName: String, key: String, value: TaskData) async throws -> Bool {
            guard var brainState = try await loadBrainState(aiName: aiName) else {
                return false
            }
            
            brainState.updateState(taskData: value)
            try await saveBrainState(brainState)
            return true
        }
        
        func getBrainStateValue(aiName: String, key: String, defaultValue: TaskData?) async throws -> TaskData? {
            guard let brainState = try await loadBrainState(aiName: aiName) else {
                return defaultValue
            }
            
            let value = brainState.getState(key: key, defaultValue: defaultValue?.data)
            
            if let dictValue = value as? [String: Any] {
                return TaskData(dictValue)
            } else if let value = value {
                return TaskData(["value": value])
            }
            
            return defaultValue
        }
        
        func deleteBrainState(aiName: String) async throws -> Bool {
            let brainStatePath = brainstateBase.appendingPathComponent("\(aiName)_state.json")
            
            guard fileManager.fileExists(atPath: brainStatePath.path) else {
                return false
            }
            
            try fileManager.removeItem(at: brainStatePath)
            return true
        }
        
        func listBrainStates() async throws -> [String] {
            guard fileManager.fileExists(atPath: brainstateBase.path) else {
                return []
            }
            
            let files = try fileManager.contentsOfDirectory(at: brainstateBase, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "_state", with: "") }
        }
        
        func backupBrainState(aiName: String, backupSuffix: String?) async throws -> String? {
            guard let brainState = try await loadBrainState(aiName: aiName) else {
                return nil
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            let suffix = backupSuffix ?? timestamp
            
            let backupPath = brainstateBase.appendingPathComponent("\(aiName)_state_\(suffix).json")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(brainState)
            try data.write(to: backupPath)
            
            return backupPath.path
        }
        
        func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool {
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
    
    private let storage: Storage
    
    public init(brainstateBase: URL) {
        self.brainstateBase = brainstateBase
        self.fileManager = FileManager.default
        self.storage = Storage(brainstateBase: brainstateBase, fileManager: fileManager)
    }
    
    public func createBrainState(aiName: String, role: RoleType, initialState: SendableContent? = nil) async throws -> BrainState {
        let brainState = BrainState(
            aiName: aiName,
            role: role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: initialState?.toAnyDict() ?? [:]
        )
        
        try await saveBrainState(brainState)
        return brainState
    }
    
    public func loadBrainState(aiName: String) async throws -> BrainState? {
        return try await storage.loadBrainState(aiName: aiName)
    }
    
    public func saveBrainState(_ brainState: BrainState) async throws {
        try await storage.saveBrainState(brainState)
    }
    
    public func updateBrainState(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        guard var brainState = try await loadBrainState(aiName: aiName) else {
            return false
        }
        
        brainState.updateState(key: key, value: value.toAnyDict())
        try await saveBrainState(brainState)
        return true
    }
    
    public func getBrainStateValue(aiName: String, key: String, defaultValue: SendableContent? = nil) async throws -> SendableContent? {
        guard let brainState = try await loadBrainState(aiName: aiName) else {
            return defaultValue
        }
        
        if let value = brainState.getState(key: key, defaultValue: defaultValue?.toAnyDict()) {
            if let dictValue = value as? [String: Any] {
                return SendableContent(dictValue)
            } else if let sendableValue = value as? SendableContent {
                return sendableValue
            }
        }
        return defaultValue
    }
    
    public func deleteBrainState(aiName: String) async throws -> Bool {
        return try await storage.deleteBrainState(aiName: aiName)
    }
    
    public func listBrainStates() async throws -> [String] {
        guard fileManager.fileExists(atPath: brainstateBase.path) else {
            return []
        }
        
        let files = try fileManager.contentsOfDirectory(at: brainstateBase, includingPropertiesForKeys: nil)
        return files
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "_state", with: "") }
    }
    
    public func backupBrainState(aiName: String, backupSuffix: String? = nil) async throws -> String? {
        return try await storage.backupBrainState(aiName: aiName, backupSuffix: backupSuffix)
    }
    
    public func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool {
        return try await storage.restoreBrainState(aiName: aiName, backupFile: backupFile)
    }
}
