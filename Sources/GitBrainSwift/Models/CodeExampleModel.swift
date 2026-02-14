import Fluent
import Foundation

final class CodeExampleModel: Model, @unchecked Sendable {
    static let schema = "code_examples"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "title")
    var title: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "language")
    var language: String
    
    @Field(key: "code")
    var code: String
    
    @OptionalField(key: "input_example")
    var inputExample: String?
    
    @OptionalField(key: "output_example")
    var outputExample: String?
    
    @OptionalField(key: "explanation")
    var explanation: String?
    
    @OptionalField(key: "complexity")
    var complexity: String?
    
    @OptionalField(key: "dependencies")
    var dependencies: [String]?
    
    @OptionalField(key: "related_snippets")
    var relatedSnippets: [String]?
    
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
