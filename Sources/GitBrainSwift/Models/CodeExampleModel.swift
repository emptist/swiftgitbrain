import Fluent
import Foundation

public final class CodeExampleModel: Model, @unchecked Sendable {
    public static let schema = "code_examples"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "title")
    public var title: String
    
    @OptionalField(key: "description")
    public var description: String?
    
    @Field(key: "language")
    public var language: String
    
    @Field(key: "code")
    public var code: String
    
    @OptionalField(key: "input_example")
    public var inputExample: String?
    
    @OptionalField(key: "output_example")
    public var outputExample: String?
    
    @OptionalField(key: "explanation")
    public var explanation: String?
    
    @OptionalField(key: "complexity")
    public var complexity: String?
    
    @OptionalField(key: "dependencies")
    public var dependencies: [String]?
    
    @OptionalField(key: "related_snippets")
    public var relatedSnippets: [String]?
    
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
        title: String,
        description: String? = nil,
        language: String,
        code: String,
        inputExample: String? = nil,
        outputExample: String? = nil,
        explanation: String? = nil,
        complexity: String? = nil,
        dependencies: [String]? = nil,
        relatedSnippets: [String]? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.title = title
        self.description = description
        self.language = language
        self.code = code
        self.inputExample = inputExample
        self.outputExample = outputExample
        self.explanation = explanation
        self.complexity = complexity
        self.dependencies = dependencies
        self.relatedSnippets = relatedSnippets
        self.createdBy = createdBy
        self.tags = tags
    }
}
