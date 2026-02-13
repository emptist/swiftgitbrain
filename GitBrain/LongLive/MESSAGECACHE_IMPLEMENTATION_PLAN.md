# MessageCache Implementation Plan

**Date:** 2026-02-14
**Author:** CoderAI
**Status:** Planning - Awaiting OverseerAI Review

## Overview

MessageCache is the foundation for AI-to-AI collaboration in GitBrainSwift. It provides structured, type-safe messaging between CoderAI and OverseerAI.

## Design Principles

1. **Swift's strength is strict types - use it properly**
   - Enums for exhaustive, known cases
   - Structs for data with required fields
   - No Python-style dynamic typing
   - No SendableContent in message models
   - Compiler is your friend - let it catch errors

2. **Protocol-first design**
   - Define protocols before implementations
   - Submit for review before coding

3. **Separate tables per message type**
   - Type is implicit from table name
   - No MessageType field needed in models
   - Type-specific indexing and constraints

## Phase 1: Task and Review Messages

### Types to Create

#### TaskType (New)
```swift
public enum TaskType: String, Codable, Sendable {
    case coding = "coding"
    case review = "review"
    case testing = "testing"
    case documentation = "documentation"
}
```

#### ReviewComment (New)
```swift
public struct ReviewComment: Codable, Sendable {
    public let file: String      // Required for multi-file reviews
    public let line: Int
    public let type: CommentType
    public let message: String
    
    public enum CommentType: String, Codable, Sendable {
        case error = "error"
        case warning = "warning"
        case suggestion = "suggestion"
        case info = "info"
    }
}
```

### Models to Create

#### TaskMessageModel
- Table: `task_messages`
- Strict types: String, Int, Date, [String]?
- No SendableContent
- Computed properties for enum conversion

#### ReviewMessageModel
- Table: `review_messages`
- Strict types: String, Int, Date, Bool, [ReviewComment]?
- No SendableContent
- Helper method: `getCommentsByFile()`

### Protocols to Create

#### MessageCacheRepositoryProtocol
Low-level database operations:
- `sendTaskMessage(...)`
- `getTaskMessages(forAI:status:)`
- `markTaskMessageAsRead(messageId:)`
- `markTaskMessageAsProcessed(messageId:)`
- `deleteTaskMessage(messageId:)`
- `sendReviewMessage(...)`
- `getReviewMessages(forAI:status:)`
- `markReviewMessageAsRead(messageId:)`
- `markReviewMessageAsProcessed(messageId:)`
- `deleteReviewMessage(messageId:)`

#### MessageCacheProtocol
High-level API for AI communication:
- `sendTask(...) -> UUID`
- `receiveTasks(for:)`
- `markTaskAsRead(messageId:)`
- `markTaskAsProcessed(messageId:)`
- `sendReview(...) -> UUID`
- `receiveReviews(for:)`
- `markReviewAsRead(messageId:)`
- `markReviewAsProcessed(messageId:)`

## Implementation Steps

### Step 1: Create Type Definitions
- [ ] Create `Sources/GitBrainSwift/Models/TaskType.swift`
- [ ] Create `Sources/GitBrainSwift/Models/ReviewComment.swift`
- [ ] Write tests for types

### Step 2: Create Models
- [ ] Create `Sources/GitBrainSwift/Models/TaskMessageModel.swift`
- [ ] Create `Sources/GitBrainSwift/Models/ReviewMessageModel.swift`
- [ ] Write tests for models

### Step 3: Create Protocols
- [ ] Create `Sources/GitBrainSwift/Protocols/MessageCacheRepositoryProtocol.swift`
- [ ] Create `Sources/GitBrainSwift/Protocols/MessageCacheProtocol.swift`
- [ ] Write tests for protocols

### Step 4: Create Migrations
- [ ] Create `Sources/GitBrainSwift/Migrations/CreateTaskMessages.swift`
- [ ] Create `Sources/GitBrainSwift/Migrations/CreateReviewMessages.swift`
- [ ] Update `MigrationManager.swift` to include new migrations

### Step 5: Implement Repository
- [ ] Create `Sources/GitBrainSwift/Repositories/FluentMessageCacheRepository.swift`
- [ ] Implement all protocol methods
- [ ] Write integration tests

### Step 6: Implement Manager
- [ ] Create `Sources/GitBrainSwift/Memory/MessageCacheManager.swift`
- [ ] Implement high-level API
- [ ] Write integration tests

### Step 7: Integration
- [ ] Update `BrainStateCommunication.swift` to use MessageCache
- [ ] Remove message storage from BrainState
- [ ] Update tests

### Step 8: Documentation
- [ ] Update SYSTEM_DESIGN.md with corrected ReviewComment schema
- [ ] Create usage examples
- [ ] Update README.md

## Testing Strategy

### Unit Tests
- Type encoding/decoding
- Model initialization
- Enum conversions
- Computed properties

### Integration Tests
- Database operations
- Message sending/receiving
- Status transitions
- Multi-file review comments

### End-to-End Tests
- CoderAI sends task to OverseerAI
- OverseerAI receives and processes task
- OverseerAI sends review to CoderAI
- CoderAI receives and applies review

## Dependencies

### Existing Types (Reuse)
- `MessageStatus` from `Message.swift`
- `MessagePriority` from `Message.swift`

### Database
- PostgreSQL with Fluent
- UUID primary keys
- Timestamps for ordering

## Critical Decisions

### 1. ReviewComment.file Field
**Decision:** Added `file` field to ReviewComment
**Rationale:** Without it, multi-file reviews are ambiguous. SYSTEM_DESIGN.md was incorrect.

### 2. TaskType as Enum
**Decision:** Use enum, not extensible struct
**Rationale:** Swift's strength is strict types. Known cases should be exhaustive.

### 3. No SendableContent
**Decision:** Models use strict types, not SendableContent
**Rationale:** SendableContent is Python-style dynamic typing. Use Swift's type system.

### 4. Separate Tables
**Decision:** Separate tables per message type
**Rationale:** Type is implicit from table name. No MessageType field needed.

## Next Steps

1. **Await OverseerAI review** of design decisions
2. **Address feedback** if any changes needed
3. **Begin implementation** following the steps above
4. **Test thoroughly** before integration
5. **Document changes** to SYSTEM_DESIGN.md

## Success Criteria

- [ ] All types compile without warnings
- [ ] All tests pass
- [ ] Code review approved by OverseerAI
- [ ] Integration with existing code works
- [ ] Documentation updated
- [ ] No SendableContent in message models
- [ ] Strict types throughout

---

**This plan is awaiting OverseerAI review before implementation begins.**
