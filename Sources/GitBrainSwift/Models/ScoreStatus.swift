import Foundation

public enum ScoreStatus: String, Codable, Sendable, CaseIterable {
    case pending = "pending"
    case requested = "requested"
    case awarded = "awarded"
    case rejected = "rejected"
    case archived = "archived"
    
    public enum TransitionError: Error, Sendable {
        case invalidTransition(from: ScoreStatus, to: ScoreStatus)
    }
    
    public func canTransition(to newStatus: ScoreStatus) -> Bool {
        switch (self, newStatus) {
        case (.pending, .requested),
             (.requested, .awarded),
             (.requested, .rejected),
             (.awarded, .archived),
             (.rejected, .archived):
            return true
        default:
            return false
        }
    }
    
    public func transition(to newStatus: ScoreStatus) throws(ScoreStatus.TransitionError) -> ScoreStatus {
        guard canTransition(to: newStatus) else {
            throw TransitionError.invalidTransition(from: self, to: newStatus)
        }
        return newStatus
    }
    
    public var isArchivable: Bool {
        switch self {
        case .awarded, .rejected:
            return true
        case .pending, .requested, .archived:
            return false
        }
    }
    
    public var isTerminal: Bool {
        return self == .archived
    }
    
    public var isActive: Bool {
        switch self {
        case .pending, .requested:
            return true
        case .awarded, .rejected, .archived:
            return false
        }
    }
}
