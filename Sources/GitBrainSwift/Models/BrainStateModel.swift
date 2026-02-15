import Fluent
import Foundation

final class BrainStateModel: Model, @unchecked Sendable {
    static let schema = "brain_states"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "brain_state_id")
    var brainStateId: String
    
    @Field(key: "ai_name")
    var aiName: String
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "state")
    var state: String
    
    @Field(key: "timestamp")
    var timestamp: Date
    
    init() {}
    
    init(aiName: String, role: String, state: String, timestamp: Date) {
        self.id = UUID()
        self.brainStateId = BrainStateID(aiName: aiName, gitHash: Self.getCurrentGitHash(), timestamp: timestamp).value
        self.aiName = aiName
        self.role = role
        self.state = state
        self.timestamp = timestamp
    }
    
    private static func getCurrentGitHash() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "--short", "HEAD"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                return "unknown"
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown"
        } catch {
            return "unknown"
        }
    }
}
