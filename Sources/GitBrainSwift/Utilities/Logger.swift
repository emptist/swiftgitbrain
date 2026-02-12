import Foundation
import OSLog

public struct Logger {
    private let osLogger: OSLog
    
    public init(subsystem: String = "com.gitbrains.swiftgitbrain", category: String = "default") {
        self.osLogger = OSLog(subsystem: subsystem, category: category)
    }
    
    public func debug(_ message: String) {
        os_log("%{public}@", log: osLogger, type: .debug, message)
    }
    
    public func info(_ message: String) {
        os_log("%{public}@", log: osLogger, type: .info, message)
    }
    
    public func warning(_ message: String) {
        os_log("%{public}@", log: osLogger, type: .default, message)
    }
    
    public func error(_ message: String) {
        os_log("%{public}@", log: osLogger, type: .error, message)
    }
}
