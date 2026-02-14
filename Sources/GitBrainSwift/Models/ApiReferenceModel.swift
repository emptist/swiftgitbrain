import Fluent
import Foundation

final class ApiReferenceModel: Model, @unchecked Sendable {
    static let schema = "api_references"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "api_name")
    var apiName: String
    
    @Field(key: "api_type")
    var apiType: String
    
    @OptionalField(key: "endpoint")
    var endpoint: String?
    
    @OptionalField(key: "method")
    var method: String?
    
    @OptionalField(key: "parameters")
    var parameters: String?
    
    @OptionalField(key: "response_schema")
    var responseSchema: String?
    
    @OptionalField(key: "authentication")
    var authentication: String?
    
    @OptionalField(key: "rate_limiting")
    var rateLimiting: String?
    
    @OptionalField(key: "examples")
    var examples: String?
    
    @OptionalField(key: "version")
    var version: String?
    
    @Field(key: "deprecated")
    var deprecated: Bool
    
    @OptionalField(key: "deprecation_note")
    var deprecationNote: String?
    
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
        apiName: String,
        apiType: String,
        endpoint: String? = nil,
        method: String? = nil,
        parameters: String? = nil,
        responseSchema: String? = nil,
        authentication: String? = nil,
        rateLimiting: String? = nil,
        examples: String? = nil,
        version: String? = nil,
        deprecated: Bool = false,
        deprecationNote: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.apiName = apiName
        self.apiType = apiType
        self.endpoint = endpoint
        self.method = method
        self.parameters = parameters
        self.responseSchema = responseSchema
        self.authentication = authentication
        self.rateLimiting = rateLimiting
        self.examples = examples
        self.version = version
        self.deprecated = deprecated
        self.deprecationNote = deprecationNote
        self.createdBy = createdBy
        self.tags = tags
    }
}
