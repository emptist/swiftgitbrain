# Message Lifecycle Design

**Date:** 2026-02-14
**Author:** CoderAI
**Status:** Design Proposal

## Problem

Current `MessageStatus` enum is too simplistic:
```swift
public enum MessageStatus: String, Codable, Sendable {
    case unread = "unread"
    case read = "read"
    case processed = "processed"
    case sent = "sent"
    case delivered = "delivered"
}
```

This doesn't capture the **semantic lifecycle** of different message types.

**Example:**
- For a **Task**: "is it read?" is not very useful. "is it done?" makes sense.
- For a **Review**: "is it processed?" is vague. "is it applied?" or "is it rejected?" is meaningful.
- For a **Score**: "processed" doesn't tell us if it was awarded or rejected.

## Proposed Solution

Each message type should have its own status enum that reflects its semantic lifecycle.

### TaskStatus

```swift
public enum TaskStatus: String, Codable, Sendable {
    case pending = "pending"           // Created, not started
    case in_progress = "in_progress"   // Being worked on
    case completed = "completed"       // Successfully done
    case failed = "failed"             // Could not complete
    case cancelled = "cancelled"       // Cancelled by sender
    case archived = "archived"         // Old, moved to disk archive
}
```

**When is a Task "old"?**
- `completed`, `failed`, `cancelled` → can be archived after N days
- `archived` → already on disk

### ReviewStatus

```swift
public enum ReviewStatus: String, Codable, Sendable {
    case pending = "pending"           // Awaiting review
    case in_review = "in_review"       // Being reviewed
    case approved = "approved"         // Passed review
    case rejected = "rejected"         // Failed review
    case needs_changes = "needs_changes" // Requires fixes
    case applied = "applied"           // Changes applied by CoderAI
    case archived = "archived"         // Old, moved to disk archive
}
```

**When is a Review "old"?**
- `approved` + `applied` → can be archived after N days
- `rejected` → can be archived immediately
- `archived` → already on disk

### ScoreStatus

```swift
public enum ScoreStatus: String, Codable, Sendable {
    case pending = "pending"           // Awaiting score decision
    case awarded = "awarded"           // Score given
    case rejected = "rejected"         // Score denied
    case disputed = "disputed"         // Under dispute
    case resolved = "resolved"         // Dispute resolved
    case archived = "archived"         // Old, moved to disk archive
}
```

**When is a Score "old"?**
- `awarded` or `rejected` → can be archived after N days
- `resolved` → can be archived immediately
- `archived` → already on disk

### CodeStatus

```swift
public enum CodeStatus: String, Codable, Sendable {
    case pending = "pending"           // Code submitted, not reviewed
    case in_review = "in_review"       // Under review
    case integrated = "integrated"     // Merged into codebase
    case obsolete = "obsolete"         // Superseded by newer code
    case archived = "archived"         // Old, moved to disk archive
}
```

**When is Code "old"?**
- `integrated` → can be archived after N days
- `obsolete` → can be archived immediately
- `archived` → already on disk

## Archive Strategy

### Archive Conditions by Type

| Message Type | Archive Condition | Archive After |
|-------------|-------------------|---------------|
| Task | `completed`, `failed`, `cancelled` | 7 days |
| Review | `applied`, `rejected` | 3 days |
| Score | `awarded`, `rejected`, `resolved` | 30 days |
| Code | `integrated`, `obsolete` | 14 days |

### Archive Process

1. **Scheduler** runs daily to check archive conditions
2. **Eligible messages** are serialized to JSON
3. **Written to disk** at `GitBrain/Memory/Archive/{type}/{year}/{month}/{day}/{message_id}.json`
4. **Deleted from database** after successful write
5. **Index file** updated for quick lookup

### Archive Retrieval

Messages can be retrieved from archive if needed:
- Load index file to find message location
- Deserialize JSON from disk
- Return as read-only historical record

## Implementation Plan

### Phase 1: Update Models

1. Create `TaskStatus` enum
2. Create `ReviewStatus` enum
3. Create `ScoreStatus` enum (for future use)
4. Create `CodeStatus` enum (for future use)
5. Update `TaskMessageModel` to use `TaskStatus`
6. Update `ReviewMessageModel` to use `ReviewStatus`

### Phase 2: Archive Infrastructure

1. Create `MessageArchiver` actor
2. Create `ArchiveScheduler` actor
3. Implement archive conditions logic
4. Implement disk serialization
5. Implement archive retrieval

### Phase 3: Integration

1. Update `MessageCacheManager` to handle status transitions
2. Add archive methods to repository
3. Update tests

## Benefits

1. **Semantic clarity**: Status reflects actual message lifecycle
2. **Better queries**: "Show me pending tasks" vs "Show me unread messages"
3. **Intelligent archiving**: Archive based on completion, not just time
4. **Type safety**: Compiler ensures correct status transitions
5. **Audit trail**: Clear history of what happened to each message

## Migration Path

### From Old MessageStatus

Old status → New status mapping:

**For Task:**
- `unread` → `pending`
- `read` → `pending` (still pending, just seen)
- `processed` → `completed` or `failed` (need context)

**For Review:**
- `unread` → `pending`
- `read` → `pending` or `in_review`
- `processed` → `applied` or `rejected`

## Questions for Discussion

1. Should we keep a **unified status field** for backward compatibility?
2. What's the **minimum retention period** for each type?
3. Should archived messages be **compressed**?
4. Do we need a **search index** for archives?

---

**This design needs review before implementation.**
