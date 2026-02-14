import Foundation

public struct GitBrainConfig: Sendable {
    public let homePath: String
    public let databaseName: String
    public let databaseHost: String
    public let databasePort: Int
    
    public init(
        homePath: String? = nil,
        databaseName: String? = nil,
        databaseHost: String? = nil,
        databasePort: Int? = nil
    ) {
        self.homePath = homePath 
            ?? ProcessInfo.processInfo.environment["GITBRAIN_PATH"]
            ?? "./.GitBrain"
        
        self.databaseName = databaseName
            ?? ProcessInfo.processInfo.environment["GITBRAIN_DB_NAME"]
            ?? "gitbrain"
        
        self.databaseHost = databaseHost
            ?? ProcessInfo.processInfo.environment["GITBRAIN_DB_HOST"]
            ?? "localhost"
        
        self.databasePort = databasePort
            ?? Int(ProcessInfo.processInfo.environment["GITBRAIN_DB_PORT"] ?? "5432")
            ?? 5432
    }
    
    public var memoryPath: String {
        "\(homePath)/Memory"
    }
    
    public var monitorPath: String {
        "\(homePath)/Monitor"
    }
    
    public var creatorPath: String {
        "\(homePath)/Creator"
    }
    
    public var docsPath: String {
        "\(homePath)/Docs"
    }
    
    public var databaseURL: String {
        "postgresql://\(databaseHost):\(databasePort)/\(databaseName)"
    }
}

public let gitbrainConfig = GitBrainConfig()

public var gitbrainHome: String {
    gitbrainConfig.homePath
}
