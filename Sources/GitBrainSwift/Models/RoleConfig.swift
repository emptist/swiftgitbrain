import Foundation

public struct RoleConfig: Codable, Sendable {
    public let name: String
    public let roleType: RoleType
    public var enabled: Bool
    public var mailbox: String
    public var brainstateFile: String
    public var capabilities: [String]
    public var preferences: [String: String]
    
    public init(
        name: String,
        roleType: RoleType,
        enabled: Bool = true,
        mailbox: String = "",
        brainstateFile: String = "",
        capabilities: [String] = [],
        preferences: [String: String] = [:]
    ) {
        self.name = name
        self.roleType = roleType
        self.enabled = enabled
        self.mailbox = mailbox
        self.brainstateFile = brainstateFile
        self.capabilities = capabilities
        self.preferences = preferences
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case roleType = "role_type"
        case enabled
        case mailbox
        case brainstateFile = "brainstate_file"
        case capabilities
        case preferences
    }
}
