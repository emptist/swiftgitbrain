import Fluent
import Foundation

public actor FluentKnowledgeRepository: KnowledgeRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws {
        let item = KnowledgeItemModel(
            category: category,
            key: key,
            value: String(data: try JSONSerialization.data(withJSONObject: value.toAnyDict()), encoding: .utf8) ?? "{}",
            metadata: String(data: try JSONSerialization.data(withJSONObject: metadata.toAnyDict()), encoding: .utf8) ?? "{}",
            timestamp: timestamp
        )
        
        try await item.save(on: database)
    }
    
    public func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)? {
        guard let item = try await KnowledgeItemModel.query(on: database)
            .filter(\.$category == category)
            .filter(\.$key == key)
            .first() else {
            return nil
        }
        
        guard let valueData = item.value.data(using: .utf8),
              let valueDict = try JSONSerialization.jsonObject(with: valueData) as? [String: Any],
              let metadataData = item.metadata.data(using: .utf8),
              let metadataDict = try JSONSerialization.jsonObject(with: metadataData) as? [String: Any] else {
            return nil
        }
        
        return (
            value: SendableContent(valueDict),
            metadata: SendableContent(metadataDict),
            timestamp: item.timestamp
        )
    }
    
    public func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool {
        guard let item = try await KnowledgeItemModel.query(on: database)
            .filter(\.$category == category)
            .filter(\.$key == key)
            .first() else {
            return false
        }
        
        item.value = String(data: try JSONSerialization.data(withJSONObject: value.toAnyDict()), encoding: .utf8) ?? "{}"
        item.metadata = String(data: try JSONSerialization.data(withJSONObject: metadata.toAnyDict()), encoding: .utf8) ?? "{}"
        item.timestamp = timestamp
        
        try await item.save(on: database)
        return true
    }
    
    public func delete(category: String, key: String) async throws -> Bool {
        guard let item = try await KnowledgeItemModel.query(on: database)
            .filter(\.$category == category)
            .filter(\.$key == key)
            .first() else {
            return false
        }
        
        try await item.delete(on: database)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        let categories = try await KnowledgeItemModel.query(on: database)
            .all()
            .map { $0.category }
        
        return Array(Set(categories)).sorted()
    }
    
    public func listKeys(category: String) async throws -> [String] {
        let keys = try await KnowledgeItemModel.query(on: database)
            .filter(\.$category == category)
            .all()
            .map { $0.key }
        
        return keys.sorted()
    }
    
    public func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)] {
        let items = try await KnowledgeItemModel.query(on: database)
            .filter(\.$category == category)
            .all()
        
        let results: [(value: SendableContent, metadata: SendableContent)] = items.compactMap { item in
            guard let valueData = item.value.data(using: .utf8),
                  let valueStr = String(data: valueData, encoding: .utf8),
                  valueStr.localizedCaseInsensitiveContains(query) else {
                return nil
            }
            
            guard let valueDict = try? JSONSerialization.jsonObject(with: valueData) as? [String: Any],
                  let metadataData = item.metadata.data(using: .utf8),
                  let metadataDict = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] else {
                return nil
            }
            
            return (
                value: SendableContent(valueDict),
                metadata: SendableContent(metadataDict)
            )
        }
        
        return results
    }
}
