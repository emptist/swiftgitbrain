import Foundation

public actor KnowledgeBase: KnowledgeBaseProtocol {
    private struct KnowledgeItem: Sendable {
        let value: SendableContent
        let metadata: SendableContent
        let timestamp: Date
    }
    
    private let base: URL
    private let fileManager: FileManager
    private var inMemoryStorage: [String: [String: KnowledgeItem]] = [:]
    
    public init(base: URL) {
        self.base = base
        self.fileManager = FileManager.default
    }
    
    private func getCategoryPath(category: String) -> URL {
        return base.appendingPathComponent(category)
    }
    
    private func getItemPath(category: String, key: String) -> URL {
        return getCategoryPath(category: category).appendingPathComponent("\(key).json")
    }
    
    public func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws {
        try fileManager.createDirectory(at: getCategoryPath(category: category), withIntermediateDirectories: true)
        
        let item = KnowledgeItem(
            value: value,
            metadata: metadata ?? SendableContent([:]),
            timestamp: Date()
        )
        
        if inMemoryStorage[category] == nil {
            inMemoryStorage[category] = [:]
        }
        inMemoryStorage[category]?[key] = item
        
        let itemData: [String: Any] = [
            "value": value.data,
            "metadata": metadata?.data ?? [:],
            "timestamp": ISO8601DateFormatter().string(from: item.timestamp)
        ]
        
        let data = try JSONSerialization.data(withJSONObject: itemData)
        try data.write(to: getItemPath(category: category, key: key))
    }
    
    public func getKnowledge(category: String, key: String) async throws -> SendableContent? {
        if let item = inMemoryStorage[category]?[key] {
            return item.value
        }
        
        let itemPath = getItemPath(category: category, key: key)
        guard fileManager.fileExists(atPath: itemPath.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: itemPath)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let valueData = json["value"] as? [String: Any] else {
            return nil
        }
        
        let value = SendableContent(valueData)
        
        let metadataData = json["metadata"] as? [String: Any] ?? [:]
        let metadata = SendableContent(metadataData)
        
        if inMemoryStorage[category] == nil {
            inMemoryStorage[category] = [:]
        }
        inMemoryStorage[category]?[key] = KnowledgeItem(
            value: value,
            metadata: metadata,
            timestamp: ISO8601DateFormatter().date(from: json["timestamp"] as? String ?? "") ?? Date()
        )
        
        return value
    }
    
    public func updateKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws -> Bool {
        guard try await getKnowledge(category: category, key: key) != nil else {
            return false
        }
        
        try await addKnowledge(category: category, key: key, value: value, metadata: metadata)
        return true
    }
    
    public func deleteKnowledge(category: String, key: String) async throws -> Bool {
        let itemPath = getItemPath(category: category, key: key)
        
        guard fileManager.fileExists(atPath: itemPath.path) else {
            return false
        }
        
        try fileManager.removeItem(at: itemPath)
        inMemoryStorage[category]?.removeValue(forKey: key)
        return true
    }
    
    public func listCategories() async throws -> [String] {
        guard fileManager.fileExists(atPath: base.path) else {
            return []
        }
        
        let categories = try fileManager.contentsOfDirectory(at: base, includingPropertiesForKeys: nil)
        return categories
            .filter { $0.hasDirectoryPath }
            .map { $0.lastPathComponent }
            .sorted()
    }
    
    public func listKeys(category: String) async throws -> [String] {
        let categoryPath = getCategoryPath(category: category)
        guard fileManager.fileExists(atPath: categoryPath.path) else {
            return []
        }
        
        let files = try fileManager.contentsOfDirectory(at: categoryPath, includingPropertiesForKeys: nil)
        return files
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [SendableContent] {
        let keys = try await listKeys(category: category)
        var results: [SendableContent] = []
        
        for key in keys {
            if let value = try await getKnowledge(category: category, key: key) {
                let valueString = try JSONSerialization.data(withJSONObject: value.data)
                if let valueStr = String(data: valueString, encoding: .utf8) {
                    if valueStr.localizedCaseInsensitiveContains(query) {
                        results.append(value)
                    }
                }
            }
        }
        
        return results
    }
}
