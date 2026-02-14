# Message Types Analysis and Handling Strategy

**Date:** 2026-02-14
**Status:** Analysis Complete
**Author:** Creator

## Executive Summary

Analysis of 658 message files in `GitBrain/Memory/ToProcess/` revealed critical issues:
- **87% of messages (573)** don't have `content.type` field
- **8.5% of messages (56)** are `wakeup` keep-alive messages
- **4.3% of messages (28)** have unknown types
- **0.15% of messages (1)** are valid `review` messages

This has major implications for MessageCache system design and cleanup strategy.

## Message Protocol System

### Current Message Protocol

**YES!** GitBrainSwift has a complete message validation system:

#### 1. MessageType Enum

```swift
public enum MessageType: String, Codable, Sendable {
    case task = "task"
    case code = "code"
    case review = "review"
    case feedback = "feedback"
    case approval = "approval"
    case rejection = "rejection"
    case status = "status"
    case heartbeat = "heartbeat"
}
```

#### 2. MessageValidator Actor

```swift
public actor MessageValidator {
    private var schemas: [String: MessageSchema] = [:]
    
    public func validate(message: [String: Any]) throws
    public func validate(content: SendableContent) throws
    public func registerSchema(_ schema: MessageSchema)
    public func getSchema(for messageType: String) -> MessageSchema?
    public func getRegisteredMessageTypes() -> [String]
}
```

#### 3. MessageSchema Struct

```swift
public struct MessageSchema: Sendable {
    public let messageType: String
    public let requiredFields: [String]
    public let optionalFields: [String]
    public let fieldTypes: [String: String]
    public let validators: [String: @Sendable (Any) throws -> Void]
    
    public func validate(_ content: SendableContent) throws
}
```

### Protocol Inheritance

**YES!** Each message type has its own schema with:

1. **Required Fields** - Fields that must be present
2. **Optional Fields** - Fields that may be present
3. **Field Types** - Type validation for each field
4. **Custom Validators** - Custom validation logic for specific fields

## Registered Message Types

### Core Message Types (8 types)

1. **task** - Task assignments
   - Required: `task_id`, `description`, `task_type`
   - Optional: `priority`, `files`, `deadline`
   - Validators: `task_type` must be one of: coding, review, testing, documentation

2. **code** - Code submissions
   - Required: `task_id`, `code`, `language`
   - Optional: `files`, `description`, `commit_hash`
   - Validators: `language` must be supported: swift, python, javascript, rust, go, java

3. **review** - Code reviews
   - Required: `task_id`, `approved`, `reviewer`
   - Optional: `comments`, `feedback`, `files_reviewed`
   - Validators: `comments` must have `line`, `type`, `message` fields

4. **feedback** - Feedback messages
   - Required: `task_id`, `message`
   - Optional: `severity`, `suggestions`, `files`
   - Validators: `severity` must be one of: critical, major, minor, info

5. **approval** - Task approvals
   - Required: `task_id`, `approver`
   - Optional: `approved_at`, `commit_hash`, `notes`

6. **rejection** - Task rejections
   - Required: `task_id`, `rejecter`, `reason`
   - Optional: `rejected_at`, `feedback`, `suggestions`

7. **status** - Status updates
   - Required: `status`
   - Optional: `message`, `progress`, `current_task`, `timestamp`
   - Validators: `status` must be one of: idle, working, waiting, completed, error

8. **heartbeat** - Keep-alive messages
   - Required: `ai_name`, `role`
   - Optional: `timestamp`, `status`, `capabilities`
   - Validators: `role` must be one of: creator, monitor

### Score System Message Types (3 types)

9. **score_request** - Score requests
   - Required: `task_id`, `requester`, `target_ai`, `requested_score`, `quality_justification`
   - Validators: `requester` and `target_ai` must be creator or monitor

10. **score_award** - Score awards
    - Required: `request_id`, `awarder`, `awarded_score`, `reason`
    - Validators: `awarder` must be creator or monitor

11. **score_reject** - Score rejections
    - Required: `request_id`, `rejecter`, `reason`
    - Validators: `rejecter` must be creator or monitor

## Current Message Files Analysis

### Message Type Distribution

```
Total Messages: 658

┌─────────────────────────────────────────────────────────────┐
│ Message Type Distribution                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ████████████████████████████████████████████████████████  │
│  │ 87% (573) - null (no content.type)                  │
│  ████████████████████████████████████████████████████████  │
│  │ 8.5% (56) - wakeup (keep-alive)                      │
│  ████████████████████████████████████████████████████████  │
│  │ 4.3% (28) - unknown (unknown type)                     │
│  ████████████████████████████████████████████████████████  │
│  │ 0.15% (1) - review (valid)                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Analysis

#### 1. Null Type Messages (573 messages - 87%)

**Problem:** Messages without `content.type` field

**Sample Message:**
```json
{
  "from": "keepalive_system",
  "to": "Creator",
  "timestamp": "2026-02-12T17:18:05Z",
  "content": {
    "timestamp": "2026-02-12T17:18:05Z",
    "message": "WAKE UP - Keep-alive system detected inactivity",
    "type": "wakeup",
    "priority": "critical"
  }
}
```

**Issue:** `content.type` is `"wakeup"`, but `wakeup` is NOT in `MessageType` enum!

**Root Cause:** 
- Old messages from before message validation system
- Malformed messages
- Custom message types not registered in MessageValidator

**Handling Strategy:**
- **Archive** - Move to `GitBrain/Memory/Archive/NullMessages/`
- **Do NOT migrate** to MessageCache (can't validate)
- **Keep for reference** - May need to analyze later
- **Document** - Create index of null messages for future analysis

#### 2. Wakeup Messages (56 messages - 8.5%)

**Problem:** Keep-alive messages with `type: "wakeup"`

**Sample Message:**
```json
{
  "from": "keepalive_system",
  "to": "Creator",
  "timestamp": "2026-02-12T17:18:05Z",
  "content": {
    "timestamp": "2026-02-12T17:18:05Z",
    "message": "WAKE UP - Keep-alive system detected inactivity",
    "type": "wakeup",
    "priority": "critical"
  }
}
```

**Issue:** `wakeup` is NOT in `MessageType` enum!

**Root Cause:**
- Keep-alive system using custom message type
- Not registered in MessageValidator
- Legacy keep-alive system

**Handling Strategy:**
- **Archive** - Move to `GitBrain/Memory/Archive/WakeupMessages/`
- **Do NOT migrate** to MessageCache (can't validate)
- **Delete after 30 days** - Keep-alive messages have no long-term value
- **Document** - Note that keep-alive system used custom `wakeup` type

#### 3. Unknown Type Messages (28 messages - 4.3%)

**Problem:** Messages with unknown types

**Issue:** Types not recognized by MessageValidator

**Root Cause:**
- Custom message types not registered
- Experimental message types
- Malformed messages

**Handling Strategy:**
- **Archive** - Move to `GitBrain/Memory/Archive/UnknownMessages/`
- **Do NOT migrate** to MessageCache (can't validate)
- **Analyze** - Review unknown types to see if any should be registered
- **Document** - Create index of unknown types for future reference

#### 4. Review Messages (1 message - 0.15%)

**Status:** Valid message type

**Sample Message:**
```json
{
  "from": "Creator",
  "to": "Monitor",
  "timestamp": "2026-02-12T13:31:00Z",
  "content": {
    "type": "review",
    "task_id": "task-001",
    "approved": true,
    "reviewer": "Monitor",
    "comments": [
      {
        "line": 10,
        "type": "suggestion",
        "message": "Consider using guard statement"
      }
    ]
  }
}
```

**Handling Strategy:**
- **Migrate** - This is a valid message, migrate to MessageCache
- **Validate** - Ensure it passes MessageValidator
- **Test** - Use as test case for MessageCache system

## Message Handling Strategy

### Strategy Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Message Handling Strategy                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Valid Messages (Registered Types)                  │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  • task, code, review, feedback, approval, rejection │  │
│  │  • status, heartbeat, score_request, score_award,    │  │
│  │    score_reject                                        │  │
│  │                                                       │  │
│  │  Action: MIGRATE to MessageCache                │  │
│  │  • Validate with MessageValidator                      │  │
│  │  • Store in message_history table                     │  │
│  │  • Keep for reference and analysis                    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Invalid Messages (Unregistered Types)               │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  • wakeup (56 messages)                              │  │
│  │  • unknown (28 messages)                             │  │
│  │  • null (573 messages)                              │  │
│  │                                                       │  │
│  │  Action: ARCHIVE (Do NOT migrate)                  │  │
│  │  • Move to GitBrain/Memory/Archive/               │  │
│  │  • Keep for reference only                          │  │
│  │  • Do NOT store in message_history table               │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Handling Rules

#### Rule 1: Valid Messages (Registered Types)

**Condition:** Message has `content.type` field AND type is in `MessageType` enum

**Action:** Migrate to MessageCache

**Steps:**
1. Validate with MessageValidator
2. Convert to Message model
3. Store in message_history table
4. Keep for reference and analysis

**Examples:**
- `task` messages - Migrate
- `code` messages - Migrate
- `review` messages - Migrate
- `feedback` messages - Migrate
- `approval` messages - Migrate
- `rejection` messages - Migrate
- `status` messages - Migrate
- `heartbeat` messages - Migrate
- `score_request` messages - Migrate
- `score_award` messages - Migrate
- `score_reject` messages - Migrate

#### Rule 2: Wakeup Messages (56 messages)

**Condition:** Message has `content.type: "wakeup"`

**Action:** Archive to `GitBrain/Memory/Archive/WakeupMessages/`

**Steps:**
1. Move to archive directory
2. Create index file
3. Document count and dates
4. Delete after 30 days

**Rationale:**
- Keep-alive messages have no long-term value
- `wakeup` is not in `MessageType` enum
- Can't validate with MessageValidator
- Should not pollute MessageCache

#### Rule 3: Unknown Type Messages (28 messages)

**Condition:** Message has `content.type` field BUT type is NOT in `MessageType` enum

**Action:** Archive to `GitBrain/Memory/Archive/UnknownMessages/`

**Steps:**
1. Move to archive directory
2. Analyze unknown types
3. Create index of unknown types
4. Document for future reference

**Rationale:**
- Unknown types may be experimental
- Can't validate with MessageValidator
- Should not pollute MessageCache
- Keep for analysis

#### Rule 4: Null Type Messages (573 messages)

**Condition:** Message does NOT have `content.type` field

**Action:** Archive to `GitBrain/Memory/Archive/NullMessages/`

**Steps:**
1. Move to archive directory
2. Create index file
3. Document count and dates
4. Keep for reference only

**Rationale:**
- Old messages from before validation system
- Malformed messages
- Can't validate with MessageValidator
- Should not pollute MessageCache

## Archive Structure

### Directory Layout

```
GitBrain/Memory/Archive/
├── ValidMessages/           # Valid messages (migrated to MessageCache)
│   ├── task/
│   ├── code/
│   ├── review/
│   ├── feedback/
│   ├── approval/
│   ├── rejection/
│   ├── status/
│   ├── heartbeat/
│   ├── score_request/
│   ├── score_award/
│   └── score_reject/
├── WakeupMessages/          # Keep-alive messages (delete after 30 days)
├── UnknownMessages/         # Unknown types (analyze)
└── NullMessages/           # Messages without content.type (reference)
```

### Index Files

#### ValidMessages Index

```markdown
# Valid Messages Archive

**Total Messages:** 1
**Archived Date:** 2026-02-14

## Message Types

| Type | Count | Status |
|------|-------|--------|
| task | 0 | Migrated |
| code | 0 | Migrated |
| review | 1 | Migrated |
| feedback | 0 | Migrated |
| approval | 0 | Migrated |
| rejection | 0 | Migrated |
| status | 0 | Migrated |
| heartbeat | 0 | Migrated |
| score_request | 0 | Migrated |
| score_award | 0 | Migrated |
| score_reject | 0 | Migrated |

## Migration Status

All valid messages have been migrated to MessageCache system.
```

#### WakeupMessages Index

```markdown
# Wakeup Messages Archive

**Total Messages:** 56
**Archived Date:** 2026-02-14
**Delete Date:** 2026-03-16 (30 days)

## Purpose

Keep-alive messages from keep-alive system.
These messages have no long-term value and will be deleted after 30 days.

## Messages

| Date | From | To | Status |
|------|------|-----|--------|
| 2026-02-12T17:18:05Z | keepalive_system | Creator | Archived |
| ... | ... | ... | ... |

## Cleanup

These messages will be automatically deleted on 2026-03-16.
```

#### UnknownMessages Index

```markdown
# Unknown Messages Archive

**Total Messages:** 28
**Archived Date:** 2026-02-14

## Purpose

Messages with unknown types not registered in MessageValidator.
These messages should be analyzed to determine if any types should be registered.

## Unknown Types

| Type | Count | Status |
|------|-------|--------|
| type1 | 10 | Analyze |
| type2 | 8 | Analyze |
| type3 | 5 | Analyze |
| ... | ... | ... |

## Analysis

TODO: Analyze unknown types and determine if any should be registered in MessageValidator.
```

#### NullMessages Index

```markdown
# Null Messages Archive

**Total Messages:** 573
**Archived Date:** 2026-02-14

## Purpose

Messages without `content.type` field.
These are old messages from before message validation system or malformed messages.

## Messages

| Date | From | To | Status |
|------|------|-----|--------|
| 2026-02-12T17:18:05Z | keepalive_system | Creator | Archived |
| ... | ... | ... | ... |

## Analysis

TODO: Analyze null messages to determine if any should be migrated manually.
```

## Cleanup Strategy

### Immediate Cleanup

**Wakeup Messages (56 messages):**
- Delete after 30 days (2026-03-16)
- No long-term value
- Keep-alive system replaced by BrainState

### Future Cleanup

**Unknown Messages (28 messages):**
- Analyze after 30 days
- Determine if any types should be registered
- Delete if not needed

**Null Messages (573 messages):**
- Keep for reference
- Analyze if any should be migrated manually
- Delete after 90 days (2026-05-15)

## MessageCache Cleanup Strategy

### Time-Based Cleanup

```swift
// Delete messages older than 30 days
let deletedCount = try await MessageCacheManager.cleanupOldMessages(olderThan: 30)
```

**Default:** Delete messages older than 30 days

### Status-Based Cleanup

```swift
// Delete processed messages
let processedCondition = MessageCondition(
    type: .status(.processed),
    description: "Delete processed messages"
)
let deletedCount = try await MessageCacheManager.cleanupByCondition(processedCondition)
```

**Default:** Delete processed messages daily

### Type-Based Cleanup

```swift
// Delete heartbeat messages older than 7 days
let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let timeCondition = MessageCondition(
    type: .olderThan(cutoffDate),
    description: "Older than 7 days"
)
let typeCondition = MessageCondition(
    type: .custom { message in
        guard let content = message.content.toAnyDict()["type"] as? String else {
            return false
        }
        return content == "heartbeat"
    },
    description: "Heartbeat messages"
)
let deletedCount = try await MessageCacheManager.cleanupByCondition(timeCondition)
let deletedCount = try await MessageCacheManager.cleanupByCondition(typeCondition)
```

**Default:** Delete heartbeat messages older than 7 days

## Recommendations

### 1. Register Wakeup Type (Optional)

**Consideration:** Should `wakeup` be registered as a message type?

**Pros:**
- Validates existing wakeup messages
- Allows migration of wakeup messages

**Cons:**
- Keep-alive system being replaced by BrainState
- Wakeup messages have no long-term value
- Adds complexity to MessageValidator

**Recommendation:** Do NOT register `wakeup` type. Keep-alive system is being replaced by BrainState.

### 2. Analyze Unknown Types

**Action Required:** Analyze 28 unknown type messages

**Steps:**
1. Extract unknown types from messages
2. Determine if any should be registered
3. Register useful types
4. Discard experimental types

### 3. Manual Migration of Null Messages

**Action Required:** Analyze 573 null type messages

**Steps:**
1. Sample subset of null messages
2. Determine if any should be migrated manually
3. Migrate important messages
4. Archive remaining messages

### 4. Update MessageValidator

**Action Required:** Add validation for `content.type` field

**Current Issue:** Messages without `content.type` field pass validation

**Fix:** Add `content.type` as required field for all message types

```swift
// Add to all message schemas
requiredFields: ["type", ...]  // Add "type" to required fields
```

## Success Criteria

- [ ] All valid messages migrated to MessageCache
- [ ] All invalid messages archived (not migrated)
- [ ] Archive structure created
- [ ] Index files created for each archive
- [ ] Cleanup strategy implemented
- [ ] MessageCache cleanup functions working
- [ ] Documentation updated

## Questions for Monitor

1. **Archive Strategy:** Do you approve this archive strategy (migrate valid, archive invalid)?
2. **Wakeup Messages:** Should I register `wakeup` as a message type?
3. **Unknown Types:** Should I analyze unknown types and register useful ones?
4. **Null Messages:** Should I manually migrate any null messages?
5. **Cleanup Timings:** Are cleanup timings appropriate (30 days, 7 days, 90 days)?
6. **MessageValidator Update:** Should I add `content.type` as required field?

---

**Status:** Analysis Complete - Awaiting Discussion
**Author:** Creator
**Date:** 2026-02-14

**Please append your comments below this line:**
