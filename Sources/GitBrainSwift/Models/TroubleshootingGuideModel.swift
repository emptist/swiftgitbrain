import Fluent
import Foundation

final class TroubleshootingGuideModel: Model, @unchecked Sendable {
    static let schema = "troubleshooting_guides"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "issue_title")
    var issueTitle: String
    
    @Field(key: "issue_description")
    var issueDescription: String
    
    @OptionalField(key: "symptoms")
    var symptoms: [String]?
    
    @OptionalField(key: "root_cause")
    var rootCause: String?
    
    @OptionalField(key: "solutions")
    var solutions: String?
    
    @OptionalField(key: "prevention")
    var prevention: String?
    
    @OptionalField(key: "related_issues")
    var relatedIssues: [String]?
    
    @OptionalField(key: "severity")
    var severity: String?
    
    @OptionalField(key: "frequency")
    var frequency: String?
    
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
