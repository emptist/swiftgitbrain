import Foundation

public actor CounterFile {
    private let counterPath: String
    
    public init(counterPath: String) {
        self.counterPath = counterPath
        
        ensureCounterFileExists()
    }
    
    private nonisolated func ensureCounterFileExists() {
        if !FileManager.default.fileExists(atPath: counterPath) {
            try? "0".write(toFile: counterPath, atomically: true, encoding: .utf8)
        }
    }
    
    public func increment() -> Int {
        let value = readCounter()
        let newValue = value + 1
        writeCounter(newValue)
        
        return newValue
    }
    
    public func getValue() -> Int {
        return readCounter()
    }
    
    public func reset() {
        writeCounter(0)
    }
    
    private func readCounter() -> Int {
        guard let content = try? String(contentsOfFile: counterPath, encoding: .utf8),
              let value = Int(content) else {
            return 0
        }
        return value
    }
    
    private func writeCounter(_ value: Int) {
        try? String(value).write(toFile: counterPath, atomically: true, encoding: .utf8)
    }
}
