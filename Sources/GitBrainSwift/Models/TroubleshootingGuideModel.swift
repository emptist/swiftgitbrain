import Fluent
import Foundation

public final class TroubleshootingGuideModel: Model, @unchecked Sendable {
    public static let schema = "troubleshooting_guides"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "issue_title")
    public var issueTitle: String
    
    @Field(key: "issue_description")
    public var issueDescription: String
    
    @OptionalField(key: "symptoms")
    public var symptoms: [String]?
    
    @OptionalField(key: "root_cause")
    public var rootCause: String?
    
    @OptionalField(key: "solutions")
    public var solutions: String?
    
    @OptionalField(key: "prevention")
    public var prevention: String?
    
    @OptionalField(key: "related_issues")
    public var relatedIssues: [String]?
    
    @OptionalField(key: "severity")
    public var severity: String?
    
    @OptionalField(key: "frequency")
    public var frequency: String?
    
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
        issueTitle: String,
        issueDescription: String,
        symptoms: [String]? = nil,
        rootCause: String? = nil,
        solutions: String? = nil,
        prevention: String? = nil,
        relatedIssues: [String]? = nil,
        severity: String? = nil,
        frequency: String? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.issueTitle = issueTitle
        self.issueDescription = issueDescription
        self.symptoms = symptoms
        self.rootCause = rootCause
        self.solutions = solutions
        self.prevention = prevention
        self.relatedIssues = relatedIssues
        self.severity = severity
        self.frequency = frequency
        self.createdBy = createdBy
        self.tags = tags
    }
}
