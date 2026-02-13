import Fluent
import Foundation

final class KnowledgeItemModel: Model, @unchecked Sendable {
    static let schema = "knowledge_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "metadata")
    var metadata: String
    
    @Field(key: "timestamp")
    var timestamp: Date
    
    init() {}
    
    init(id: UUID? = nil, category: String, key: String, value: String, metadata: String, timestamp: Date) {
        self.id = id
        self.category = category
        self.key = key
        self.value = value
        self.metadata = metadata
        self.timestamp = timestamp
    }
}
