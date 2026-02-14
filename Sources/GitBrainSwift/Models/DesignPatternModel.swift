import Fluent
import Foundation

public final class DesignPatternModel: Model, @unchecked Sendable {
    public static let schema = "design_patterns"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "knowledge_id")
    public var knowledgeId: UUID
    
    @Field(key: "category")
    public var category: String
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "pattern_name")
    public var patternName: String
    
    @Field(key: "pattern_type")
    public var patternType: String
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "intent")
    public var intent: String?
    
    @OptionalField(key: "motivation")
    public var motivation: String?
    
    @OptionalField(key: "applicability")
    public var applicability: String?
    
    @OptionalField(key: "structure")
    public var structure: String?
    
    @OptionalField(key: "participants")
    public var participants: [String]?
    
    @OptionalField(key: "collaborations")
    public var collaborations: String?
    
    @OptionalField(key: "consequences")
    public var consequences: [String]?
    
    @OptionalField(key: "implementation")
    public var implementation: String?
    
    @OptionalField(key: "sample_code")
    public var sampleCode: String?
    
    @OptionalField(key: "known_uses")
    public var knownUses: [String]?
    
    @OptionalField(key: "related_patterns")
    public var relatedPatterns: [String]?
    
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
        patternName: String,
        patternType: String,
        description: String,
        intent: String? = nil,
        motivation: String? = nil,
        applicability: String? = nil,
        structure: String? = nil,
        participants: [String]? = nil,
        collaborations: String? = nil,
        consequences: [String]? = nil,
        implementation: String? = nil,
        sampleCode: String? = nil,
        knownUses: [String]? = nil,
        relatedPatterns: [String]? = nil,
        createdBy: String,
        tags: [String]? = nil
    ) {
        self.id = id
        self.knowledgeId = knowledgeId
        self.category = category
        self.key = key
        self.patternName = patternName
        self.patternType = patternType
        self.description = description
        self.intent = intent
        self.motivation = motivation
        self.applicability = applicability
        self.structure = structure
        self.participants = participants
        self.collaborations = collaborations
        self.consequences = consequences
        self.implementation = implementation
        self.sampleCode = sampleCode
        self.knownUses = knownUses
        self.relatedPatterns = relatedPatterns
        self.createdBy = createdBy
        self.tags = tags
    }
}
