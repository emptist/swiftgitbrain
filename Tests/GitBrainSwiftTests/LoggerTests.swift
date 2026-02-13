import Testing
@testable import GitBrainSwift
import Foundation

struct LoggerTests {
    @Test("Logger set and get log level")
    func testSetAndGetLogLevel() {
        let originalLevel = GitBrainLogger.getLogLevel()
        
        GitBrainLogger.setLogLevel(.error)
        #expect(GitBrainLogger.getLogLevel() == .error)
        
        GitBrainLogger.setLogLevel(.debug)
        #expect(GitBrainLogger.getLogLevel() == .debug)
        
        GitBrainLogger.setLogLevel(originalLevel)
    }
    
    @Test("Logger log at debug level")
    func testLogDebug() {
        GitBrainLogger.setLogLevel(.debug)
        GitBrainLogger.debug("Debug message")
    }
    
    @Test("Logger log at info level")
    func testLogInfo() {
        GitBrainLogger.setLogLevel(.info)
        GitBrainLogger.info("Info message")
    }
    
    @Test("Logger log at warning level")
    func testLogWarning() {
        GitBrainLogger.setLogLevel(.warning)
        GitBrainLogger.warning("Warning message")
    }
    
    @Test("Logger log at error level")
    func testLogError() {
        GitBrainLogger.setLogLevel(.error)
        GitBrainLogger.error("Error message")
    }
    
    @Test("Logger log at fault level")
    func testLogFault() {
        GitBrainLogger.setLogLevel(.fault)
        GitBrainLogger.fault("Fault message")
    }
    
    @Test("Logger log with level filter")
    func testLogLevelFilter() {
        GitBrainLogger.setLogLevel(.error)
        
        GitBrainLogger.debug("This should not be logged")
        GitBrainLogger.info("This should not be logged")
        GitBrainLogger.warning("This should not be logged")
        GitBrainLogger.error("This should be logged")
        GitBrainLogger.fault("This should be logged")
    }
    
    @Test("Logger log with custom level")
    func testLogWithCustomLevel() {
        GitBrainLogger.setLogLevel(.debug)
        
        GitBrainLogger.log(.debug, "Debug message")
        GitBrainLogger.log(.info, "Info message")
        GitBrainLogger.log(.warning, "Warning message")
        GitBrainLogger.log(.error, "Error message")
        GitBrainLogger.log(.fault, "Fault message")
    }
    
    @Test("LogLevel comparison")
    func testLogLevelComparison() {
        #expect(LogLevel.debug < LogLevel.info)
        #expect(LogLevel.info < LogLevel.warning)
        #expect(LogLevel.warning < LogLevel.error)
        #expect(LogLevel.error < LogLevel.fault)
        
        #expect(LogLevel.debug <= LogLevel.debug)
        #expect(LogLevel.info <= LogLevel.warning)
        
        #expect(LogLevel.warning > LogLevel.info)
        #expect(LogLevel.error > LogLevel.warning)
        #expect(LogLevel.fault > LogLevel.error)
        
        #expect(LogLevel.warning >= LogLevel.info)
        #expect(LogLevel.error >= LogLevel.error)
    }
    
    @Test("LogLevel name")
    func testLogLevelName() {
        #expect(LogLevel.debug.name == "DEBUG")
        #expect(LogLevel.info.name == "INFO")
        #expect(LogLevel.warning.name == "WARNING")
        #expect(LogLevel.error.name == "ERROR")
        #expect(LogLevel.fault.name == "FAULT")
    }
}
