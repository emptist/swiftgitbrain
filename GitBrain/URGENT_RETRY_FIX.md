# URGENT: Retry Count Tracking Bug - Please Read This!

## The Problem

Your retry function returns `(result, attempts)` but you're throwing away the `attempts` value.

## What's Wrong

**Current Code:**
```swift
let _ = try await retry({
    try await knowledgeRepo.add(...)
}, item: "item", phase: "Transfer", progress: progress)
```

The `_` wildcard discards the `attempts` count!

## The Fix

**Change this:**
```swift
let _ = try await retry({...})
```

**To this:**
```swift
let (_, attempts) = try await retry({...})
```

## Also Change Error Reporting

**Line 333 and 413 - Change this:**
```swift
retryCount: retryPolicy.maxRetries
```

**To this:**
```swift
retryCount: attempts
```

## Why This Matters

If `maxRetries = 3` and item fails on first attempt:
- **Current**: Shows `retryCount: 3` (WRONG - this is max configured)
- **Fixed**: Shows `retryCount: 1` (CORRECT - this is actual attempts)

## Exact Changes Needed

| Line | From | To |
|-------|-------|-----|
| 207 | `let _ =` | `let (_, attempts) =` |
| 224 | `let _ =` | `let (_, attempts) =` |
| 310 | `let _ =` | `let (_, attempts) =` |
| 391 | `let _ =` | `let (_, attempts) =` |
| 333 | `retryPolicy.maxRetries` | `attempts` |
| 413 | `retryPolicy.maxRetries` | `attempts` |

## Summary

- `retryPolicy.maxRetries` = maximum allowed (e.g., 3)
- `attempts` = actual number made (e.g., 1, 2, or 3)
- We want `attempts` in error reporting, NOT `maxRetries`

## Please Make These 6 Changes

1. Line 207: `let _` → `let (_, attempts)`
2. Line 224: `let _` → `let (_, attempts)`
3. Line 310: `let _` → `let (_, attempts)`
4. Line 391: `let _` → `let (_, attempts)`
5. Line 333: `retryPolicy.maxRetries` → `attempts`
6. Line 413: `retryPolicy.maxRetries` → `attempts`

That's it! Just 6 simple line changes.

---

**Questions?** Please ask if anything is unclear!
