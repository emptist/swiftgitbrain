import Foundation
import GitBrainSwift

actor MockKnowledgeRepository: KnowledgeRepositoryProtocol {
    private var storage: [String: [String: (value: SendableContent, metadata: SendableContent, timestamp: Date)]] = [:]
    
    func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws {
        if storage[category] == nil {
            storage[category] = [:]
        }
        storage[category]?[key] = (value, metadata, timestamp)
    }
    
    func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)? {
        return storage[category]?[key]
    }
    
    func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool {
        guard storage[category]?[key] != nil else {
            return false
        }
        storage[category]?[key] = (value, metadata, timestamp)
        return true
    }
    
    func delete(category: String, key: String) async throws -> Bool {
        guard storage[category]?[key] != nil else {
            return false
        }
        storage[category]?.removeValue(forKey: key)
        return true
    }
    
    func listCategories() async throws -> [String] {
        return Array(storage.keys).sorted()
    }
    
    func listKeys(category: String) async throws -> [String] {
        return Array(storage[category]?.keys.sorted() ?? [])
    }
    
    func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)] {
        guard let items = storage[category] else {
            return []
        }
        
        var results: [(value: SendableContent, metadata: SendableContent)] = []
        
        for (key, item) in items {
            if let valueData = try? JSONSerialization.data(withJSONObject: item.value.toAnyDict()),
               let valueStr = String(data: valueData, encoding: .utf8),
               valueStr.localizedCaseInsensitiveContains(query) {
                results.append((item.value, item.metadata))
            }
        }
        
        return results
    }
}
