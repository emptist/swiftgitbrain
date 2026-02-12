import Foundation

public actor CounterFile {
    private let counterPath: String
    private let fileManager: FileManager
    private let logger: Logger
    
    public init(counterPath: String, logger: Logger = Logger()) {
        self.counterPath = counterPath
        self.fileManager = FileManager.default
        self.logger = logger
        ensureCounterFileExists()
    }
    
    private nonisolated func ensureCounterFileExists() {
        if !fileManager.fileExists(atPath: counterPath) {
            do {
                try "0".write(toFile: counterPath, atomically: true, encoding: .utf8)
                logger.info("Created counter file with initial value 0")
            } catch {
                logger.error("Failed to create counter file: \(error)")
            }
        }
    }
    
    public func increment() async -> Int {
        let value = await readCounter()
        let newValue = value + 1
        await writeCounter(newValue)
        logger.debug("Counter incremented: \(value) -> \(newValue)")
        return newValue
    }
    
    public func getValue() async -> Int {
        return await readCounter()
    }
    
    public func reset() async {
        await writeCounter(0)
        logger.info("Counter reset to 0")
    }
    
    private func readCounter() async -> Int {
        do {
            let content = try String(contentsOfFile: counterPath, encoding: .utf8)
            guard let value = Int(content.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                logger.warning("Invalid counter value in file: \(content)")
                return 0
            }
            return value
        } catch {
            logger.error("Failed to read counter file: \(error)")
            return 0
        }
    }
    
    private func writeCounter(_ value: Int) async {
        do {
            try String(value).write(toFile: counterPath, atomically: true, encoding: .utf8)
        } catch {
            logger.error("Failed to write counter file: \(error)")
        }
    }
    
    public func getLastModifiedTime() async -> Date? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: counterPath)
            return attributes[.modificationDate] as? Date
        } catch {
            logger.error("Failed to get file modification time: \(error)")
            return nil
        }
    }
}
