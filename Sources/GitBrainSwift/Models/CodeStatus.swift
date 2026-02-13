import Foundation

public enum CodeStatus: String, Codable, Sendable, CaseIterable {
    case pending = "pending"
    case reviewing = "reviewing"
    case approved = "approved"
    case rejected = "rejected"
    case merged = "merged"
    case archived = "archived"
    
    public enum TransitionError: Error, Sendable {
        case invalidTransition(from: CodeStatus, to: CodeStatus)
    }
    
    public func canTransition(to newStatus: CodeStatus) -> Bool {
        switch (self, newStatus) {
        case (.pending, .reviewing),
             (.pending, .approved),
             (.pending, .rejected),
             (.reviewing, .approved),
             (.reviewing, .rejected),
             (.approved, .merged),
             (.approved, .archived),
             (.rejected, .archived),
             (.merged, .archived):
            return true
        default:
            return false
        }
    }
    
    public func transition(to newStatus: CodeStatus) throws(CodeStatus.TransitionError) -> CodeStatus {
        guard canTransition(to: newStatus) else {
            throw TransitionError.invalidTransition(from: self, to: newStatus)
        }
        return newStatus
    }
    
    public var isArchivable: Bool {
        switch self {
        case .approved, .rejected, .merged:
            return true
        case .pending, .reviewing, .archived:
            return false
        }
    }
    
    public var isTerminal: Bool {
        return self == .archived
    }
    
    public var isActive: Bool {
        switch self {
        case .pending, .reviewing:
            return true
        case .approved, .rejected, .merged, .archived:
            return false
        }
    }
}
