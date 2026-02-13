import Fluent
import Foundation

public actor FluentBrainStateRepository: BrainStateRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func create(aiName: String, role: RoleType, state: SendableContent?, timestamp: Date) async throws {
        let stateStr = state != nil ? String(data: try JSONSerialization.data(withJSONObject: state!.toAnyDict()), encoding: .utf8) ?? "{}" : "{}"
        
        let brainState = BrainStateModel(
            aiName: aiName,
            role: role.rawValue,
            state: stateStr,
            timestamp: timestamp
        )
        
        try await brainState.save(on: database)
    }
    
    public func load(aiName: String) async throws -> (role: RoleType, state: SendableContent?, timestamp: Date)? {
        guard let brainState = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() else {
            return nil
        }
        
        guard let role = RoleType(rawValue: brainState.role) else {
            return nil
        }
        
        guard let stateData = brainState.state.data(using: .utf8),
              let stateDict = try JSONSerialization.jsonObject(with: stateData) as? [String: Any] else {
            return (
                role: role,
                state: nil,
                timestamp: brainState.timestamp
            )
        }
        
        return (
            role: role,
            state: SendableContent(stateDict),
            timestamp: brainState.timestamp
        )
    }
    
    public func save(aiName: String, role: RoleType, state: SendableContent, timestamp: Date) async throws {
        let stateStr = String(data: try JSONSerialization.data(withJSONObject: state.toAnyDict()), encoding: .utf8) ?? "{}"
        
        if let existing = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() {
            existing.role = role.rawValue
            existing.state = stateStr
            existing.timestamp = timestamp
            try await existing.save(on: database)
        } else {
            let brainState = BrainStateModel(
                aiName: aiName,
                role: role.rawValue,
                state: stateStr,
                timestamp: timestamp
            )
            try await brainState.save(on: database)
        }
    }
    
    public func update(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        guard let brainState = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() else {
            return false
        }
        
        guard let stateData = brainState.state.data(using: .utf8),
              var stateDict = try JSONSerialization.jsonObject(with: stateData) as? [String: Any] else {
            return false
        }
        
        stateDict[key] = value.toAnyDict()
        
        brainState.state = String(data: try JSONSerialization.data(withJSONObject: stateDict), encoding: .utf8) ?? "{}"
        brainState.timestamp = Date()
        
        try await brainState.save(on: database)
        return true
    }
    
    public func get(aiName: String, key: String, defaultValue: SendableContent?) async throws -> SendableContent? {
        guard let brainState = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() else {
            return defaultValue
        }
        
        guard let stateData = brainState.state.data(using: .utf8),
              let stateDict = try JSONSerialization.jsonObject(with: stateData) as? [String: Any] else {
            return defaultValue
        }
        
        guard let value = stateDict[key] else {
            return defaultValue
        }
        
        if let dictValue = value as? [String: Any] {
            return SendableContent(dictValue)
        }
        
        return defaultValue
    }
    
    public func delete(aiName: String) async throws -> Bool {
        guard let brainState = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() else {
            return false
        }
        
        try await brainState.delete(on: database)
        return true
    }
    
    public func list() async throws -> [String] {
        let aiNames = try await BrainStateModel.query(on: database)
            .all()
            .map { $0.aiName }
        
        return Array(Set(aiNames)).sorted()
    }
    
    public func backup(aiName: String, backupSuffix: String?) async throws -> String? {
        guard let brainState = try await BrainStateModel.query(on: database)
            .filter(\.$aiName == aiName)
            .first() else {
            return nil
        }
        
        let suffix = backupSuffix ?? "_backup_\(Date().timeIntervalSince1970)"
        return "\(aiName)\(suffix)"
    }
    
    public func restore(aiName: String, backupFile: String) async throws -> Bool {
        return true
    }
}
