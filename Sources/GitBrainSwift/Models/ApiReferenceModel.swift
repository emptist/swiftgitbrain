import Fluent
import Foundation

public final class ApiReferenceModel: Model, @unchecked Sendable {
    public static let schema = "api_references"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "api_name")
    public var apiName: String
    
    @Field(key: "api_type")
    public var apiType: String
    
    @OptionalField(key: "endpoint")
    public var endpoint: String?
    
    @OptionalField(key: "method")
    public var method: String?
    
    @OptionalField(key: "parameters")
    public var parameters: String?
    
    @OptionalField(key: "response_schema")
    public var responseSchema: String?
    
    @OptionalField(key: "authentication")
    public var authentication: String?
    
    @OptionalField(key: "rate_limiting")
    public var rateLimiting: String?
    
    @OptionalField(key: "examples")
    public var examples: String?
    
    @OptionalField(key: "version")
    public var version: String?
    
    @Field(key: "deprecated")
    public var deprecated: Bool
    
    @OptionalField(key: "deprecation_note")
    public var deprecationNote: String?
    
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
