import Fluent
import Foundation

final class DesignPatternModel: Model, @unchecked Sendable {
    static let schema = "design_patterns"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "knowledge_id")
    var knowledgeId: UUID
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "pattern_name")
    var patternName: String
    
    @Field(key: "pattern_type")
    var patternType: String
    
    @Field(key: "description")
    var description: String
    
    @OptionalField(key: "intent")
    var intent: String?
    
    @OptionalField(key: "motivation")
    var motivation: String?
    
    @OptionalField(key: "applicability")
    var applicability: String?
    
    @OptionalField(key: "structure")
    var structure: String?
    
    @OptionalField(key: "participants")
    var participants: [String]?
    
    @OptionalField(key: "collaborations")
    var collaborations: String?
    
    @OptionalField(key: "consequences")
    var consequences: [String]?
    
    @OptionalField(key: "implementation")
    var implementation: String?
    
    @OptionalField(key: "sample_code")
    var sampleCode: String?
    
    @OptionalField(key: "known_uses")
    var knownUses: [String]?
    
    @OptionalField(key: "related_patterns")
    var relatedPatterns: [String]?
    
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
