import Fluent
import Foundation

final class CodeSnippetModel: Model, @unchecked Sendable {
    static let schema = "code_snippets"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "language")
    var language: String
    
    @Field(key: "code")
    var code: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @OptionalField(key: "usage_example")
    var usageExample: String?
    
    @OptionalField(key: "dependencies")
    var dependencies: [String]?
    
    @OptionalField(key: "framework")
    var framework: String?
    
    @OptionalField(key: "version")
    var version: String?
    
    @OptionalField(key: "complexity")
    var complexity: String?
    
    @Field(key: "created_by")
    var createdBy: String
    
    @OptionalField(key: "tags")
    var tags: [String]?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        knowledgeId: UUID,
        category: String,
        key: String,
        language: String,
        code: String,
        description: String? = nil,
        usageExample: String? = nil,
        dependencies: [String]? = nil,
        framework: String? = nil,
        version: String? = nil,
        complexity: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.language = language
        self.code = code
        self.description = description
        self.usageExample = usageExample
        self.dependencies = dependencies
        self.framework = framework
        self.version = version
        self.complexity = complexity
        self.createdBy = createdBy
        self.tags = tags
    }
}
