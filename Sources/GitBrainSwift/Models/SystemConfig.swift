import Foundation

public struct SystemConfig: Codable, Sendable {
    public var name: String
    public var version: String
    public var maildirBase: String
    public var brainstateBase: String
    public var checkInterval: Int
    public var configCheckInterval: Int
    public var hotReload: Bool
    public var autoSave: Bool
    public var saveInterval: Int
    public var roles: [String: RoleConfig]
    
    public init(
        name: String = "GitBrain Workspace",
        version: String = "1.0.0",
        maildirBase: String = "./mailboxes",
        brainstateBase: String = "./brainstates",
        checkInterval: Int = 5,
        configCheckInterval: Int = 60,
        hotReload: Bool = true,
        autoSave: Bool = true,
        saveInterval: Int = 60,
        roles: [String: RoleConfig] = [:]
    ) {
        self.name = name
        self.version = version
        self.maildirBase = maildirBase
        self.brainstateBase = brainstateBase
        self.checkInterval = checkInterval
        self.configCheckInterval = configCheckInterval
        self.hotReload = hotReload
        self.autoSave = autoSave
        self.saveInterval = saveInterval
        self.roles = roles
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case version
        case maildirBase = "maildir_base"
        case brainstateBase = "brainstate_base"
        case checkInterval = "check_interval"
        case configCheckInterval = "config_check_interval"
        case hotReload = "hot_reload"
        case autoSave = "auto_save"
        case saveInterval = "save_interval"
        case roles
    }
    
    public func getRoleConfig(roleName: String) -> RoleConfig? {
        return roles[roleName]
    }
    
    public mutating func addRoleConfig(_ roleConfig: RoleConfig) {
        roles[roleConfig.name] = roleConfig
    }
    
    public mutating func removeRoleConfig(roleName: String) {
        roles.removeValue(forKey: roleName)
    }
}
