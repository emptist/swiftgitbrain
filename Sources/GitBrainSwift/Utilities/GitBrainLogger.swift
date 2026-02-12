import Foundation

public enum GitBrainLogger {
    private static let logger = Logger()
    
    public static func debug(_ message: String) {
        logger.debug(message)
    }
    
    public static func info(_ message: String) {
        logger.info(message)
    }
    
    public static func warning(_ message: String) {
        logger.warning(message)
    }
    
    public static func error(_ message: String) {
        logger.error(message)
    }
}
