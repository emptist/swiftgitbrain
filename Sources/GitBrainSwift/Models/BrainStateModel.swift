import Fluent
import Foundation

final class BrainStateModel: Model, @unchecked Sendable {
    static let schema = "brain_states"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "ai_name")
    var aiName: String
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "state")
    var state: String
    
    @Field(key: "timestamp")
    var timestamp: Date
    
    init() {}
    
    init(id: UUID? = nil, aiName: String, role: String, state: String, timestamp: Date) {
        self.id = id
        self.aiName = aiName
        self.role = role
        self.state = state
        self.timestamp = timestamp
    }
}
