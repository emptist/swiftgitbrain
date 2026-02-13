# Retry Count Tracking Fix - Critical Bug

## Issue Summary

The retry count tracking in `DataMigration.swift` is incomplete. While the retry function was modified to return `(result: T, attempts: Int)`, the actual attempts count is being discarded and not used in error reporting.

## Current Problem

### What's Working
✅ Retry function correctly returns tuple with attempts count:
```swift
private func retry<T>(...) async throws -> (result: T, attempts: Int) {
    // ...
    return (result, attempt + 1)
}
```

### What's Wrong
❌ All retry calls discard the attempts count:
```swift
let _ = try await retry({
    try await knowledgeRepo.add(...)
}, item: "\(item.category)/\(item.key)", phase: "Transfer", progress: progress)
```

❌ Error reporting uses maxRetries instead of actual attempts:
```swift
migrationErrors.append(MigrationErrorDetail(
    item: "\(category)/\(key)",
    error: error.localizedDescription,
    phase: "Transfer",
    retryCount: retryPolicy.maxRetries  // This is MAX configured, not ACTUAL!
))
```

## Why This Matters

### Example Scenario
- `retryPolicy.maxRetries = 3`
- Item fails on first attempt (1 try)

**Current Behavior:**
- Shows `retryCount: 3` (maximum configured retries)
- ❌ INCORRECT - Item only tried once!

**Correct Behavior Should Be:**
- Shows `retryCount: 1` (actual attempts made)
- ✅ CORRECT - Shows real number of attempts

### Impact
- Error reporting is inaccurate
- Cannot distinguish between transient vs permanent errors
- Difficult to debug migration issues
- Monitoring data is misleading

## The Fix

### Change 1: Capture Attempts Count
**File:** `Sources/GitBrainSwift/Migration/DataMigration.swift`

**Line 207:** Change from:
```swift
let _ = try await retry({
```

To:
```swift
let (_, attempts) = try await retry({
```

**Line 224:** Change from:
```swift
let _ = try await retry({
```

To:
```swift
let (_, attempts) = try await retry({
```

**Line 310:** Change from:
```swift
let _ = try await retry({
```

To:
```swift
let (_, attempts) = try await retry({
```

**Line 391:** Change from:
```swift
let _ = try await retry({
```

To:
```swift
let (_, attempts) = try await retry({
```

### Change 2: Use Actual Attempts in Error Reporting

**Line 333:** Change from:
```swift
retryCount: retryPolicy.maxRetries
```

To:
```swift
retryCount: attempts
```

**Line 413:** Change from:
```swift
retryCount: retryPolicy.maxRetries
```

To:
```swift
retryCount: attempts
```

## Complete Example

### Before (Current - Incorrect)
```swift
for item in snapshot.knowledgeItems {
    do {
        let _ = try await retry({
            try await knowledgeRepo.add(
                category: item.category,
                key: item.key,
                value: item.value
            )
        }, item: "\(item.category)/\(item.key)", phase: "Transfer", progress: progress)
        
        totalItems += 1
    } catch {
        migrationErrors.append(MigrationErrorDetail(
            item: "\(item.category)/\(item.key)",
            error: error.localizedDescription,
            phase: "Transfer",
            retryCount: retryPolicy.maxRetries  // WRONG!
        ))
        failedItems += 1
        progress?.reportError(error: error, context: "Migrating \(item.category)/\(item.key)")
    }
}
```

### After (Fixed - Correct)
```swift
for item in snapshot.knowledgeItems {
    do {
        let (_, attempts) = try await retry({
            try await knowledgeRepo.add(
                category: item.category,
                key: item.key,
                value: item.value
            )
        }, item: "\(item.category)/\(item.key)", phase: "Transfer", progress: progress)
        
        totalItems += 1
    } catch {
        migrationErrors.append(MigrationErrorDetail(
            item: "\(item.category)/\(item.key)",
            error: error.localizedDescription,
            phase: "Transfer",
            retryCount: attempts  // CORRECT!
        ))
        failedItems += 1
        progress?.reportError(error: error, context: "Migrating \(item.category)/\(item.key)")
    }
}
```

## Summary of Changes

| Line | From | To | Description |
|-------|-------|-----|-------------|
| 207 | `let _ =` | `let (_, attempts) =` | Capture attempts for knowledge items |
| 224 | `let _ =` | `let (_, attempts) =` | Capture attempts for brain states |
| 310 | `let _ =` | `let (_, attempts) =` | Capture attempts for knowledge files |
| 391 | `let _ =` | `let (_, attempts) =` | Capture attempts for brain state files |
| 333 | `retryPolicy.maxRetries` | `attempts` | Use actual attempts in error reporting |
| 413 | `retryPolicy.maxRetries` | `attempts` | Use actual attempts in error reporting |

## Testing

### Test Case
1. Set `retryPolicy.maxRetries = 3`
2. Simulate transient error that succeeds on 2nd attempt
3. Check error reporting

**Expected Result:**
- `retryCount` should be `2` (actual attempts made)
- NOT `3` (maximum configured)

## Questions?

If anything is unclear, please ask:
1. Do you see the difference between `retryPolicy.maxRetries` (maximum allowed) and `attempts` (actual made)?
2. Do you understand why `let _` discards the attempts count?
3. Would you like me to help with the exact line-by-line changes?
