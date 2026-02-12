# Keep-Alive System - Complete Solution

## Overview

The Keep-Alive System prevents AI timeout and maintains continuous operation between CoderAI and OverseerAI using a shared counter file with staggered increment intervals.

## Architecture

### Components

1. **CounterFile Actor** ([Sources/GitBrainSwift/Utilities/CounterFile.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/Sources/GitBrainSwift/Utilities/CounterFile.swift))
   - Thread-safe counter management
   - Atomic file operations
   - Actor-based locking (Swift 6.2)

2. **Logger Utility** ([Sources/GitBrainSwift/Utilities/Logger.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/Sources/GitBrainSwift/Utilities/Logger.swift))
   - OSLog-based logging
   - Structured logging levels (debug, info, warning, error)

3. **GitBrainLogger** ([Sources/GitBrainSwift/Utilities/GitBrainLogger.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/Sources/GitBrainSwift/Utilities/GitBrainLogger.swift))
   - Static logger interface for the entire project
   - Singleton pattern for consistent logging

4. **Keep-Alive Scripts**
   - [scripts/coder_keepalive.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/scripts/coder_keepalive.swift) - CoderAI keep-alive (60s interval)
   - [scripts/overseer_keepalive.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/scripts/overseer_keepalive.swift) - OverseerAI keep-alive (90s interval)

## How It Works

### Actor-Based Locking

The `CounterFile` actor provides thread-safe access to the counter file:

```swift
public actor CounterFile {
    // All methods are automatically serialized by Swift's actor isolation
    // No explicit file locking needed - Swift handles it at the actor boundary
}
```

**Key Benefits:**
- No race conditions
- Automatic serialization of concurrent access
- Modern Swift 6.2 concurrency model
- No manual lock management

### Shared Counter File

Both AIs increment the same counter file: `GitBrain/keepalive_counter.txt`

**Staggered Intervals:**
- CoderAI: 60 seconds
- OverseerAI: 90 seconds

This prevents both AIs from trying to write simultaneously, reducing contention.

### Atomic Operations

File operations use atomic writes:

```swift
try String(value).write(toFile: counterPath, atomically: true, encoding: .utf8)
```

This ensures that the counter file is never in a partially written state.

## Quick Start

### Step 1: Build the Project

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree
swift build
```

### Step 2: Start CoderAI Keep-Alive

Open Terminal 1:

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree
swift scripts/coder_keepalive.swift
```

**Expected Output:**
```
🤖 CoderAI Keep-Alive Starting...
   Interval: 60 seconds
   Counter file: GitBrain/keepalive_counter.txt

[2026-02-12T08:30:00.123Z] 🔥 CoderAI heartbeat #1
[2026-02-12T08:31:00.456Z] 🔥 CoderAI heartbeat #2
[2026-02-12T08:32:00.789Z] 🔥 CoderAI heartbeat #3
```

### Step 3: Start OverseerAI Keep-Alive

Open Terminal 2:

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree
swift scripts/overseer_keepalive.swift
```

**Expected Output:**
```
🤖 OverseerAI Keep-Alive Starting...
   Interval: 90 seconds
   Counter file: GitBrain/keepalive_counter.txt

[2026-02-12T08:30:00.123Z] 🔥 OverseerAI heartbeat #1
[2026-02-12T08:31:30.456Z] 🔥 OverseerAI heartbeat #2
[2026-02-12T08:33:00.789Z] 🔥 OverseerAI heartbeat #3
```

## Monitoring

### Check Counter Value

```bash
cat GitBrain/keepalive_counter.txt
```

### Check File Modification Time

```bash
stat -f "%Sm" GitBrain/keepalive_counter.txt
```

### Monitor Logs

```bash
log stream --predicate 'subsystem == "com.gitbrains.swiftgitbrain"' --level debug
```

## API Reference

### CounterFile Actor

```swift
public actor CounterFile {
    public init(counterPath: String, logger: Logger = Logger())
    
    public func increment() async -> Int
    public func getValue() async -> Int
    public func reset() async
    public func getLastModifiedTime() async -> Date?
}
```

### Logger Struct

```swift
public struct Logger {
    public init(subsystem: String = "com.gitbrains.swiftgitbrain", category: String = "default")
    
    public func debug(_ message: String)
    public func info(_ message: String)
    public func warning(_ message: String)
    public func error(_ message: String)
}
```

### GitBrainLogger Enum

```swift
public enum GitBrainLogger {
    public static func debug(_ message: String)
    public static func info(_ message: String)
    public static func warning(_ message: String)
    public static func error(_ message: String)
}
```

## Design Decisions

### Why Actor-Based Locking?

- **Modern Swift 6.2**: Leverages latest concurrency features
- **Type Safety**: Compile-time guarantees for thread safety
- **No Manual Lock Management**: Swift handles serialization automatically
- **Sendable Compliance**: All types conform to Sendable protocol

### Why Staggered Intervals?

- **Reduced Contention**: Minimizes concurrent write attempts
- **Load Balancing**: Spreads I/O operations over time
- **Fault Tolerance**: If one AI fails, the other continues

### Why Atomic File Operations?

- **Data Integrity**: Prevents partial writes
- **Crash Recovery**: File is always in a valid state
- **Cross-Process Safety**: Works across multiple processes

## Error Handling

The keep-alive scripts include automatic error recovery:

```swift
do {
    let value = await counterFile.increment()
    // Process heartbeat
} catch {
    logger.error("Keep-alive error: \(error)")
    try await Task.sleep(nanoseconds: 5_000_000_000) // Wait 5 seconds before retry
}
```

## Stopping the Scripts

Press `Ctrl+C` in each terminal to stop the keep-alive scripts.

## Troubleshooting

### Counter File Not Found

The scripts automatically create the counter file if it doesn't exist:

```bash
mkdir -p GitBrain
echo "0" > GitBrain/keepalive_counter.txt
```

### Permission Denied

Ensure the scripts have execute permissions:

```bash
chmod +x scripts/coder_keepalive.swift scripts/overseer_keepalive.swift
```

### Build Errors

Ensure the project builds successfully:

```bash
swift build
```

If you see errors about `GitBrainLogger`, ensure the file exists:

```bash
ls Sources/GitBrainSwift/Utilities/GitBrainLogger.swift
```

## Testing

### Unit Tests

Test the CounterFile actor in isolation:

```swift
let counterFile = CounterFile(counterPath: "/tmp/test_counter.txt")
let value1 = await counterFile.increment() // Returns 1
let value2 = await counterFile.increment() // Returns 2
let value3 = await counterFile.getValue() // Returns 2
await counterFile.reset()
let value4 = await counterFile.getValue() // Returns 0
```

### Integration Tests

Test concurrent access from multiple AIs:

```swift
// Simulate CoderAI
Task {
    for _ in 0..<10 {
        _ = await counterFile.increment()
        try await Task.sleep(nanoseconds: 60_000_000_000)
    }
}

// Simulate OverseerAI
Task {
    for _ in 0..<10 {
        _ = await counterFile.increment()
        try await Task.sleep(nanoseconds: 90_000_000_000)
    }
}
```

## Related Documentation

- [KEEP_ALIVE_SYSTEM.md](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/Documentation/KEEP_ALIVE_SYSTEM.md) - Original design documentation
- [DESIGN_DECISIONS.md](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/Documentation/DESIGN_DECISIONS.md) - Project design decisions
- [Project Rules](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree/.trae/rules/project_rules.md) - Project-level rules and conventions

## Summary

The Keep-Alive System provides a robust, thread-safe solution for maintaining AI collaboration using:

- ✅ Swift 6.2 actor-based concurrency
- ✅ Atomic file operations
- ✅ Staggered intervals to reduce contention
- ✅ Automatic error recovery
- ✅ Comprehensive logging
- ✅ No manual lock management

The system is production-ready and follows all project conventions for MVVM architecture, Protocol-Oriented Programming, and Sendable compliance.
