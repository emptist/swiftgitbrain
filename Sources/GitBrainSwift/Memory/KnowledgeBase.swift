import Foundation

public protocol KnowledgeBaseProtocol: Sendable {
    func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent?) async throws
    func getKnowledge(category: String, key: String) async throws -> SendableContent?
    func updateKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent?) async throws -> Bool
    func deleteKnowledge(category: String, key: String) async throws -> Bool
    func listCategories() async throws -> [String]
    func listKeys(category: String) async throws -> [String]
    func searchKnowledge(category: String, query: String) async throws -> [SendableContent]
}

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
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
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
        
        private func getCategoryPath(category: String) -> URL {
            return base.appendingPathComponent(category)
        }
        
        let data = try Data(contentsOf: itemPath)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let valueData = json["value"] as? [String: String] else {
            return nil
        }
        
        let value = SendableContent(valueData.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value
        })
        
        let metadataData = json["metadata"] as? [String: String] ?? [:]
        let metadata = SendableContent(metadataData.reduce(into: [String: Any]()) { dict, pair in
            dict[pair.key] = pair.value
        })
        
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
        
        func getKnowledge(category: String, key: String) async throws -> TaskData? {
            if let item = inMemoryStorage[category]?[key] {
                return TaskData(item.value)
            }
            
            let itemPath = getItemPath(category: category, key: key)
            guard fileManager.fileExists(atPath: itemPath.path) else {
                return nil
            }
            
            let data = try Data(contentsOf: itemPath)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let value = json["value"] as? [String: Any] else {
                return nil
            }
            
            if inMemoryStorage[category] == nil {
                inMemoryStorage[category] = [:]
            }
            inMemoryStorage[category]?[key] = KnowledgeItem(
                value: value,
                metadata: json["metadata"] as? [String: Any] ?? [:],
                timestamp: ISO8601DateFormatter().date(from: json["timestamp"] as? String ?? "") ?? Date()
            )
            
            return TaskData(value)
        }
        
        func updateKnowledge(category: String, key: String, value: TaskData, metadataTaskData: TaskData?) async throws -> Bool {
            guard try await getKnowledge(category: category, key: key) != nil else {
                return false
            }
            
            try await addKnowledge(category: category, key: key, taskData: value, metadataTaskData: metadataTaskData)
            return true
        }
        
        func deleteKnowledge(category: String, key: String) async throws -> Bool {
            let itemPath = getItemPath(category: category, key: key)
            
            guard fileManager.fileExists(atPath: itemPath.path) else {
                return false
            }
            
            try fileManager.removeItem(at: itemPath)
            inMemoryStorage[category]?.removeValue(forKey: key)
            return true
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
            
            return results
        }
    }
    
    private let storage: Storage
    
    public init(base: URL) {
        self.storage = Storage(base: base, fileManager: FileManager.default)
    }
    
    public func addKnowledge(category: String, key: String, value: TaskData, metadata: TaskData? = nil) async throws {
        try await storage.addKnowledge(category: category, key: key, taskData: value, metadataTaskData: metadata)
    }
    
    public func getKnowledge(category: String, key: String) async throws -> TaskData? {
        return try await storage.getKnowledge(category: category, key: key)
    }
    
    public func updateKnowledge(category: String, key: String, value: TaskData, metadata: TaskData? = nil) async throws -> Bool {
        return try await storage.updateKnowledge(category: category, key: key, value: value, metadataTaskData: metadata)
    }
    
    public func deleteKnowledge(category: String, key: String) async throws -> Bool {
        return try await storage.deleteKnowledge(category: category, key: key)
    }
    
    public func listCategories() async throws -> [String] {
        return try await storage.listCategories()
    }
    
    public func listKeys(category: String) async throws -> [String] {
        return try await storage.listKeys(category: category)
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [TaskData] {
        return try await storage.searchKnowledge(category: category, query: query)
    }
}
