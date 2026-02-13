import Foundation
import os

private final class ThreadSafe<T>: @unchecked Sendable {
    private var value: T
    private let lock = NSLock()
    
    init(_ value: T) {
        self.value = value
    }
    
    func get() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
    
    func set(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}

public enum GitBrainLogger {
    private static let subsystem = "com.gitbrain.swift"
    private static let category = "GitBrain"
    
    #if DEBUG
    private static nonisolated(unsafe) var logLevel = ThreadSafe(LogLevel.debug)
    #else
    private static nonisolated(unsafe) var logLevel = ThreadSafe(LogLevel.info)
    #endif
    
    private static func formatMessage(_ message: String, context: LogContext, metadata: LogMetadata? = nil) -> String {
        var formatted = "[\(context.file):\(context.line)] \(context.function) - \(message)"
        if let metadata = metadata, !metadata.data.isEmpty {
            let metadataString = metadata.data.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            formatted += " | \(metadataString)"
        }
        return formatted
    }
    
    public static func debug(_ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel.get() <= .debug else { return }
        let ctx = context ?? LogContext(file: file, function: function, line: line)
        let formatted = formatMessage(message, context: ctx, metadata: metadata)
        os_log("%{public}@", dso: #dsohandle, log: OSLog(subsystem: subsystem, category: category), type: .info, formatted)
    }
    
    public static func info(_ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel.get() <= .info else { return }
        let ctx = context ?? LogContext(file: file, function: function, line: line)
        let formatted = formatMessage(message, context: ctx, metadata: metadata)
        os_log("%{public}@", dso: #dsohandle, log: OSLog(subsystem: subsystem, category: category), type: .info, formatted)
    }
    
    public static func warning(_ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel.get() <= .warning else { return }
        let ctx = context ?? LogContext(file: file, function: function, line: line)
        let formatted = formatMessage(message, context: ctx, metadata: metadata)
        os_log("%{public}@", dso: #dsohandle, log: OSLog(subsystem: subsystem, category: category), type: .default, formatted)
    }
    
    public static func error(_ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel.get() <= .error else { return }
        let ctx = context ?? LogContext(file: file, function: function, line: line)
        let formatted = formatMessage(message, context: ctx, metadata: metadata)
        os_log("%{public}@", dso: #dsohandle, log: OSLog(subsystem: subsystem, category: category), type: .error, formatted)
    }
    
    public static func fault(_ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard logLevel.get() <= .fault else { return }
        let ctx = context ?? LogContext(file: file, function: function, line: line)
        let formatted = formatMessage(message, context: ctx, metadata: metadata)
        os_log("%{public}@", dso: #dsohandle, log: OSLog(subsystem: subsystem, category: category), type: .fault, formatted)
    }
    
    public static func log(_ level: LogLevel, _ message: String, context: LogContext? = nil, metadata: LogMetadata? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        switch level {
        case .debug:
            debug(message, context: context, metadata: metadata, file: file, function: function, line: line)
        case .info:
            info(message, context: context, metadata: metadata, file: file, function: function, line: line)
        case .warning:
            warning(message, context: context, metadata: metadata, file: file, function: function, line: line)
        case .error:
            error(message, context: context, metadata: metadata, file: file, function: function, line: line)
        case .fault:
            fault(message, context: context, metadata: metadata, file: file, function: function, line: line)
        }
    }
    
    public static func setLogLevel(_ level: LogLevel) {
        logLevel.set(level)
    }
    
    public static func getLogLevel() -> LogLevel {
        return logLevel.get()
    }
}

public struct LogContext: Sendable {
    public let file: String
    public let function: String
    public let line: Int
    
    public init(file: String = #file, function: String = #function, line: Int = #line) {
        self.file = (file as NSString).lastPathComponent
        self.function = function
        self.line = line
    }
}

public struct LogMetadata: Sendable {
    public let data: [String: Sendable]
    
    public init(_ data: [String: Sendable] = [:]) {
        self.data = data
    }
    
    public subscript(key: String) -> Sendable? {
        return data[key]
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
