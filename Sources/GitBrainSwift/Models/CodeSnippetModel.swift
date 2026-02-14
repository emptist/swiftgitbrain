import Fluent
import Foundation

public final class CodeSnippetModel: Model, @unchecked Sendable {
    public static let schema = "code_snippets"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "language")
    public var language: String
    
    @Field(key: "code")
    public var code: String
    
    @OptionalField(key: "description")
    public var description: String?
    
    @OptionalField(key: "usage_example")
    public var usageExample: String?
    
    @OptionalField(key: "dependencies")
    public var dependencies: [String]?
    
    @OptionalField(key: "framework")
    public var framework: String?
    
    @OptionalField(key: "version")
    public var version: String?
    
    @OptionalField(key: "complexity")
    public var complexity: String?
    
    @Field(key: "created_by")
    public var createdBy: String
    
    @OptionalField(key: "tags")
    public var tags: [String]?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init() {}
    
    public init(
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
