# Swift File Locking Implementation for CounterFile

## Overview

This document provides suggestions for implementing proper file locking when using `CounterFile.swift`. The founder designed `CounterFile.swift` with caller-side locking responsibility. This document outlines a recommended implementation approach.

## Problem Statement

`CounterFile.swift` uses `actor` for thread-safety within a single process, but multiple processes (CoderAI + OverseerAI) can still cause race conditions when accessing the shared counter file.

## Recommended Solution

Implement a user-side Swift utility function that provides file locking before calling `CounterFile` methods.

## Suggested Implementation

### File Locking Utility

Create a new file: `Sources/GitBrainSwift/Utilities/FileLock.swift`

```swift
import Foundation

public enum FileLockError: LocalizedError {
    case lockFileCreationFailed
    case lockAcquisitionFailed
    case lockReleaseFailed
    
    public var errorDescription: String? {
        switch self {
        case .lockFileCreationFailed:
            return "Failed to create lock file"
        case .lockAcquisitionFailed:
            return "Failed to acquire file lock"
        case .lockReleaseFailed:
            return "Failed to release file lock"
        }
    }
}

public func withFileLock<T>(
    _ lockPath: String,
    timeout: TimeInterval = 30.0,
    operation: () throws -> T
) throws -> T {
    let lockURL = URL(fileURLWithPath: lockPath)
    let fileManager = FileManager.default
    
    guard fileManager.createFile(atPath: lockPath, contents: nil, attributes: nil) else {
        throw FileLockError.lockFileCreationFailed
    }
    
    guard let lockHandle = try? FileHandle(forWritingTo: lockURL) else {
        throw FileLockError.lockAcquisitionFailed
    }
    
    defer {
        try? lockHandle.close()
        try? fileManager.removeItem(atPath: lockPath)
    }
    
    let startTime = Date()
    while Date().timeIntervalSince(startTime) < timeout {
        do {
            try lockHandle.lock(contentsOf: lockURL)
            defer {
                try? lockHandle.unlock()
            }
            return try operation()
        } catch {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    throw FileLockError.lockAcquisitionFailed
}
```

### Usage Example

```swift
import GitBrainSwift

let counterFile = CounterFile(counterPath: "GitBrain/keepalive_counter.txt")

do {
    let newValue = try withFileLock("GitBrain/keepalive_counter.txt.lock") {
        await counterFile.increment()
    }
    print("Counter incremented to: \(newValue)")
} catch {
    print("Failed to increment counter: \(error)")
}
```

### Keepalive Script Example

Create a Swift keepalive script: `scripts/KeepaliveScript.swift`

```swift
#!/usr/bin/env swift

import Foundation

let counterFile = CounterFile(counterPath: "GitBrain/keepalive_counter.txt")
let interval: TimeInterval = 180.0 // 3 minutes

print("Starting keepalive loop (interval: \(interval)s)...")

while true {
    do {
        let newValue = try withFileLock("GitBrain/keepalive_counter.txt.lock") {
            await counterFile.increment()
        }
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] Counter incremented to: \(newValue)")
    } catch {
        print("Error: \(error)")
    }
    
    sleep(UInt32(interval))
}
```

## Implementation Tasks for CoderAI

1. **Research Swift file locking mechanisms**
   - Investigate `FileHandle.lock(contentsOf:)` behavior
   - Test cross-process locking on macOS
   - Verify timeout handling

2. **Create `FileLock.swift` utility**
   - Implement the `withFileLock` function
   - Add proper error handling
   - Include timeout support

3. **Create Swift keepalive scripts**
   - Replace shell scripts with Swift versions
   - Test with both CoderAI and OverseerAI
   - Verify no race conditions occur

4. **Update documentation**
   - Document the new locking approach
   - Add usage examples
   - Update KEEP_ALIVE_SYSTEM.md

5. **Test thoroughly**
   - Run both keepalive scripts simultaneously
   - Monitor for race conditions
   - Verify counter increments correctly

## Testing Strategy

1. **Unit Tests**
   - Test `withFileLock` with concurrent access
   - Verify timeout behavior
   - Test error handling

2. **Integration Tests**
   - Run CoderAI and OverseerAI keepalive scripts together
   - Monitor counter file for corruption
   - Verify both processes can increment safely

3. **Stress Tests**
   - Run multiple instances of keepalive scripts
   - Test with very short intervals
   - Verify system stability

## Notes

- The founder's design of caller-side locking is sound
- This implementation provides the missing locking layer
- The approach is simple and maintainable
- Works well with the existing `CounterFile.swift` API

## References

- [CounterFile.swift](../Sources/GitBrainSwift/Utilities/CounterFile.swift)
- [KEEP_ALIVE_SYSTEM.md](KEEP_ALIVE_SYSTEM.md)
- [COUNTER_SYSTEM_ANALYSIS.md](COUNTER_SYSTEM_ANALYSIS.md)

---

*Document created by OverseerAI - Suggestion for CoderAI implementation*
