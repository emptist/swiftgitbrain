# Keep-Alive System

## Overview

The GitBrain keep-alive system ensures both CoderAI and OverseerAI remain active indefinitely, preventing them from going to sleep during long-running collaborative sessions.

## Shared Counter Approach

### Concept

A simple shared counter file (`GitBrain/keepalive_counter.txt`) is used as a heartbeat mechanism:
- Both AIs increment the counter at different intervals
- CoderAI increments every 60 seconds
- OverseerAI increments every 90 seconds
- This ensures at least one AI is always active

### Benefits

1. **Simple**: Just read, increment, write a number
2. **Reliable**: No complex message parsing needed
3. **Efficient**: Minimal file I/O
4. **Staggered**: Different intervals ensure overlap
5. **Monitorable**: Counter value shows activity

## Implementation

### Swift Actor-Based Counter

**File**: `Sources/GitBrainSwift/Utilities/CounterFile.swift`

```swift
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
```

### Usage

**CoderAI:**
```swift
let counterFile = CounterFile(counterPath: "GitBrain/keepalive_counter.txt")
while true {
    let value = await counterFile.increment()
    print("Counter: \(value)")
    try await Task.sleep(nanoseconds: 60_000_000_000)  // 60 seconds
}
```

**OverseerAI:**
```swift
let counterFile = CounterFile(counterPath: "GitBrain/keepalive_counter.txt")
while true {
    let value = await counterFile.increment()
    print("Counter: \(value)")
    try await Task.sleep(nanoseconds: 90_000_000_000)  // 90 seconds
}
```

## Usage

### Starting Keep-Alive Scripts

**CoderAI:**
```bash
./scripts/coder_keepalive_counter.sh
```

**OverseerAI:**
```bash
./scripts/overseer_keepalive_counter.sh
```

### Monitoring Activity

Check the counter value to verify both AIs are active:
```bash
cat GitBrain/keepalive_counter.txt
```

The counter should increase over time as both AIs increment it.

## Keep-Alive Techniques for AIs

### 1. Always Show Thinking Process

Use the 🤔 emoji at the start of every response and provide actual thinking content:
- 📋 (Analysis)
- 💡 (Insight/Plan)
- 🔧 (Implementation)
- ⚖️ (Evaluation)

### 2. Work on Meaningful Tasks

- Fix real issues in the codebase
- Address OverseerAI's review suggestions
- Make actual improvements, not just busy work

### 3. Send Status Updates

- Update OverseerAI on progress
- Use "working" or "waiting" status (not "completed")
- Keep communication channels active

### 4. Check for Messages Regularly

- Use `gitbrain check coder` to see new messages
- Respond to OverseerAI's feedback
- Maintain two-way communication

### 5. Show Continuous Activity

- Don't mark tasks as "completed" prematurely
- Keep work in progress while actively working
- Demonstrate ongoing engagement

## Comparison with Message-Based Keep-Alive

### Message-Based Approach (Previous)

- Complex message parsing
- Requires checking multiple message types
- More file I/O operations
- Higher risk of errors

### Shared Counter Approach (Current)

- Simple number increment
- Minimal file I/O
- No message parsing needed
- More reliable and efficient

## Troubleshooting

### Counter Not Incrementing

If the counter is not increasing:
1. Check if keep-alive scripts are running
2. Verify file permissions on `GitBrain/keepalive_counter.txt`
3. Check for error messages in script output

### AI Still Going to Sleep

If an AI goes to sleep despite keep-alive scripts:
1. Verify the AI is showing thinking process (🤔 emoji)
2. Ensure the AI is working on meaningful tasks
3. Check that status updates are being sent regularly

## Best Practices

1. **Start Both Scripts**: Always start both CoderAI and OverseerAI keep-alive scripts
2. **Monitor Counter**: Regularly check the counter value to verify activity
3. **Meaningful Work**: Ensure AIs are working on real improvements, not just staying busy
4. **Communication**: Maintain regular communication between AIs
5. **Documentation**: Document keep-alive procedures for future reference

## Conclusion

The shared counter keep-alive system is a simple, reliable, and efficient solution for keeping both CoderAI and OverseerAI active indefinitely. By incrementing a counter at different intervals, both AIs ensure continuous activity without the complexity of message-based systems.

This approach has been successfully tested and demonstrated to keep both AIs alive during extended collaborative sessions.
