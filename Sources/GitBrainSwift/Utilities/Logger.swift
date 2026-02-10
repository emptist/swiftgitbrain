import Foundation
import os

public enum Logger {
    private static let subsystem = "com.gitbrain.swift"
    private static let category = "GitBrain"
    
    #if DEBUG
    private nonisolated(unsafe) static var logLevel: LogLevel = .debug
    #else
    private nonisolated(unsafe) static var logLevel: LogLevel = .info
    #endif
    
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel <= .debug else { return }
        let logger = OSLog(subsystem: subsystem, category: category)
        logger.debug("\(message)", file: file, function: function, line: line)
    }
    
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel <= .info else { return }
        let logger = OSLog(subsystem: subsystem, category: category)
        logger.info("\(message)", file: file, function: function, line: line)
    }
    
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel <= .warning else { return }
        let logger = OSLog(subsystem: subsystem, category: category)
        logger.warning("\(message)", file: file, function: function, line: line)
    }
    
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel <= .error else { return }
        let logger = OSLog(subsystem: subsystem, category: category)
        logger.error("\(message)", file: file, function: function, line: line)
    }
    
    public static func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel <= .fault else { return }
        let logger = OSLog(subsystem: subsystem, category: category)
        logger.critical("\(message)", file: file, function: function, line: line)
    }
    
    public static func log(_ level: LogLevel, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        switch level {
        case .debug:
            debug(message, file: file, function: function, line: line)
        case .info:
            info(message, file: file, function: function, line: line)
        case .warning:
            warning(message, file: file, function: function, line: line)
        case .error:
            error(message, file: file, function: function, line: line)
        case .fault:
            fault(message, file: file, function: function, line: line)
        }
    }
    
    public static func setLogLevel(_ level: LogLevel) {
        logLevel = level
    }
    
    public static func getLogLevel() -> LogLevel {
        return logLevel
    }
}

public enum LogLevel: Int, Comparable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case fault = 4
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func <= (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    public static func > (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    public static func >= (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    public var name: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .fault:
            return "FAULT"
        }
    }
}