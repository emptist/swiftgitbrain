import Foundation

public actor KnowledgeBase: KnowledgeBaseProtocol {
    private let repository: KnowledgeRepositoryProtocol
    
    public init(repository: KnowledgeRepositoryProtocol) {
        self.repository = repository
        GitBrainLogger.info("KnowledgeBase initialized with Fluent repository")
    }
    
    public func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws {
        GitBrainLogger.debug("Adding knowledge: category=\(category), key=\(key)")
        try await repository.add(category: category, key: key, value: value, metadata: metadata ?? SendableContent([:]), timestamp: Date())
        GitBrainLogger.info("Successfully added knowledge: category=\(category), key=\(key)")
    }
    
    public func getKnowledge(category: String, key: String) async throws -> SendableContent? {
        GitBrainLogger.debug("Getting knowledge: category=\(category), key=\(key)")
        guard let result = try await repository.get(category: category, key: key) else {
            GitBrainLogger.debug("Knowledge not found: category=\(category), key=\(key)")
            return nil
        }
        GitBrainLogger.debug("Successfully retrieved knowledge: category=\(category), key=\(key)")
        return result.value
    }
    
    public func updateKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws -> Bool {
        GitBrainLogger.debug("Updating knowledge: category=\(category), key=\(key)")
        let result = try await repository.update(category: category, key: key, value: value, metadata: metadata ?? SendableContent([:]), timestamp: Date())
        if result {
            GitBrainLogger.info("Successfully updated knowledge: category=\(category), key=\(key)")
        } else {
            GitBrainLogger.warning("Knowledge not found for update: category=\(category), key=\(key)")
        }
        return result
    }
    
    public func deleteKnowledge(category: String, key: String) async throws -> Bool {
        GitBrainLogger.debug("Deleting knowledge: category=\(category), key=\(key)")
        let result = try await repository.delete(category: category, key: key)
        if result {
            GitBrainLogger.info("Successfully deleted knowledge: category=\(category), key=\(key)")
        } else {
            GitBrainLogger.warning("Knowledge not found for deletion: category=\(category), key=\(key)")
        }
        return result
    }
    
    public func listCategories() async throws -> [String] {
        GitBrainLogger.debug("Listing categories")
        let categories = try await repository.listCategories()
        GitBrainLogger.debug("Found \(categories.count) categories")
        return categories
    }
    
    public func listKeys(category: String) async throws -> [String] {
        GitBrainLogger.debug("Listing keys for category: \(category)")
        let keys = try await repository.listKeys(category: category)
        GitBrainLogger.debug("Found \(keys.count) keys in category: \(category)")
        return keys
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [SendableContent] {
        GitBrainLogger.debug("Searching knowledge: category=\(category), query=\(query)")
        let results = try await repository.search(category: category, query: query)
        let values = results.map { $0.value }
        GitBrainLogger.info("Search completed: category=\(category), query=\(query), results=\(values.count)")
        return values
    }
}
