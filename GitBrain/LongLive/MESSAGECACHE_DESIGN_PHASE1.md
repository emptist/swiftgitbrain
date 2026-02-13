# MessageCache Design - Phase 1: Task and Review Messages

**Date:** 2026-02-14
**Author:** CoderAI
**Status:** Design Document - Corrected to Match SYSTEM_DESIGN.md

## Overview

This document specifies the design for MessageCache system, starting with the two most critical message types for AI collaboration:
- **TaskMessage** - For assigning work between AIs
- **ReviewMessage** - For code review feedback

**IMPORTANT:** This design follows the documented schema in [SYSTEM_DESIGN.md](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/SYSTEM_DESIGN.md) exactly.

---

## Database Schema (From SYSTEM_DESIGN.md)

### task_messages Table

```sql
CREATE TABLE task_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    task_type VARCHAR(50) NOT NULL,
    priority INTEGER NOT NULL,
    files TEXT[],
    deadline TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_task_messages_to_ai ON task_messages(to_ai);
CREATE INDEX idx_task_messages_from_ai ON task_messages(from_ai);
CREATE INDEX idx_task_messages_status ON task_messages(status);
CREATE INDEX idx_task_messages_timestamp ON task_messages(timestamp);
CREATE INDEX idx_task_messages_task_id ON task_messages(task_id);
CREATE INDEX idx_task_messages_task_type ON task_messages(task_type);

-- Composite indexes
CREATE INDEX idx_task_messages_to_status ON task_messages(to_ai, status);
CREATE INDEX idx_task_messages_to_timestamp ON task_messages(to_ai, timestamp DESC);
CREATE INDEX idx_task_messages_to_task_id ON task_messages(to_ai, task_id);

-- Validators
-- task_type: 'coding', 'review', 'testing', 'documentation'
-- priority: 1-10
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

### review_messages Table

```sql
CREATE TABLE review_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    approved BOOLEAN NOT NULL,
    reviewer VARCHAR(255) NOT NULL,
    comments JSONB,
    feedback TEXT,
    files_reviewed TEXT[],
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_review_messages_to_ai ON review_messages(to_ai);
CREATE INDEX idx_review_messages_from_ai ON review_messages(from_ai);
CREATE INDEX idx_review_messages_status ON review_messages(status);
CREATE INDEX idx_review_messages_timestamp ON review_messages(timestamp);
CREATE INDEX idx_review_messages_task_id ON review_messages(task_id);
CREATE INDEX idx_review_messages_reviewer ON review_messages(reviewer);
CREATE INDEX idx_review_messages_approved ON review_messages(approved);

-- Composite indexes
CREATE INDEX idx_review_messages_to_status ON review_messages(to_ai, status);
CREATE INDEX idx_review_messages_to_timestamp ON review_messages(to_ai, timestamp DESC);
CREATE INDEX idx_review_messages_to_task_id ON review_messages(to_ai, task_id);

-- Validators
-- comments[].line: non-negative integer
-- comments[].type: 'error', 'warning', 'suggestion', 'info'
-- comments[].message: required string
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

---

## Design Principles

1. **Swift's strength is strict types - use it properly**
   - Enums for exhaustive, known cases
   - Structs for data with required fields
   - No Python-style dynamic typing
   - No JSONB in Swift code - use proper types
   - Compiler is your friend - let it catch errors

2. **Protocol-first design**
   - Define protocols before implementations
   - Submit for review before coding

3. **Follow existing patterns**
   - Reuse MessageStatus and MessagePriority from Message.swift
   - Follow FluentBrainStateRepository pattern

4. **Think critically about documentation**
   - SYSTEM_DESIGN.md may contain errors
   - Verify logical consistency
   - Make corrections when necessary

---

## Critical Analysis of Existing Code

### SendableContent Problem - Python-style Dynamic Typing

**Current code in [SendableContent.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/Sources/GitBrainSwift/Utilities/SendableContent.swift):**
```swift
public struct SendableContent: Codable, Sendable {
    public private(set) var data: [String: CodableAny]
    // This is essentially a dictionary - DYNAMIC TYPING!
}
```

**This is Python-style, not Swift-style:**
- No compile-time type checking
- No field validation
- No IDE autocomplete
- Runtime errors instead of compile errors

**For MessageCache: DO NOT use SendableContent.**
- Use strict types with specific fields
- Let compiler catch errors
- Get IDE autocomplete support

### MessageType Enum Issue

**Current code in [MessageType.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/Sources/GitBrainSwift/Models/MessageType.swift):**
```swift
public enum MessageType: String, Codable, Sendable {
    case task = "task"
    case code = "code"
    case review = "review"
    // ...
}
```

**Problems:**
1. **Barely used** - MessageValidator uses String, not this enum
2. **Incomplete** - Missing score_request, score_award, score_reject from SYSTEM_DESIGN.md
3. **Potentially unnecessary** - If each message type has its own table, the table name IS the type discriminator

**Question:** Do we even need a MessageType field in database if each type has its own table?

### Design Decision for MessageCache

**Option A:** Keep separate tables per message type (as per SYSTEM_DESIGN.md)
- No type field needed in each table
- Type is implicit from table name
- Cleaner schema

**Option B:** Single messages table with type field
- Requires MessageType field
- Less tables to manage
- But loses type-specific indexing and constraints

**Recommendation:** Follow SYSTEM_DESIGN.md - separate tables per message type. No MessageType field in models.

---

## Type Definitions

### TaskType Enum

**Swift's strength is strict types. Use enum for exhaustive, known cases.**

```swift
public enum TaskType: String, Codable, Sendable {
    case coding = "coding"
    case review = "review"
    case testing = "testing"
    case documentation = "documentation"
}
```

**Why enum, not struct:**
- These are the ONLY valid task types
- Compiler enforces exhaustive handling
- Swift pattern matching works with enums
- Type-safe at compile time

**If new types are needed:**
- Add to enum (requires code change - this is GOOD for type safety)
- NOT runtime extensibility (that's Python-style, not Swift-style)

### MessageStatus Enum

**From SYSTEM_DESIGN.md validators:**
```
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

**Already exists in [Message.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/Sources/GitBrainSwift/Communication/Message.swift):**

```swift
public enum MessageStatus: String, Codable, Sendable {
    case unread = "unread"
    case read = "read"
    case processed = "processed"
    case sent = "sent"
    case delivered = "delivered"
}
```

### MessagePriority Enum

**From SYSTEM_DESIGN.md validators:**
```
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
```

**Already exists in [Message.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/Sources/GitBrainSwift/Communication/Message.swift):**

```swift
public enum MessagePriority: Int, Codable, Sendable {
    case critical = 1
    case high = 2
    case normal = 3
    case low = 4
}
```

### ReviewComment Structure

**CRITICAL CORRECTION: Added 'file' field**

The SYSTEM_DESIGN.md shows comments without a file field, but this creates a logical problem:
- `files_reviewed` can contain multiple files
- Without file field in comments, we cannot know which file a comment refers to

**Corrected design with file field:**

```swift
public struct ReviewComment: Codable, Sendable {
    public let file: String
    public let line: Int
    public let type: CommentType
    public let message: String
    
    public enum CommentType: String, Codable, Sendable {
        case error = "error"
        case warning = "warning"
        case suggestion = "suggestion"
        case info = "info"
    }
    
    public init(file: String, line: Int, type: CommentType, message: String) {
        self.file = file
        self.line = line
        self.type = type
        self.message = message
    }
}
```

---

## Model Design

### TaskMessageModel

**Strict types - no SendableContent:**

```swift
import Fluent
import Foundation

public final class TaskMessageModel: Model, @unchecked Sendable {
    public static let schema = "task_messages"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "message_id")
    public var messageId: UUID
    
    @Field(key: "from_ai")
    public var fromAI: String
    
    @Field(key: "to_ai")
    public var toAI: String
    
    @Field(key: "timestamp")
    public var timestamp: Date
    
    @Field(key: "task_id")
    public var taskId: String
    
    @Field(key: "description")
    public var description: String
    
    @Field(key: "task_type")
    public var taskType: String  // Stored as String for DB, converted to TaskType enum in domain layer
    
    @Field(key: "priority")
    public var priority: Int
    
    @OptionalField(key: "files")
    public var files: [String]?
    
    @OptionalField(key: "deadline")
    public var deadline: Date?
    
    @Field(key: "status")
    public var status: String  // Stored as String for DB, converted to MessageStatus enum in domain layer
    
    @Field(key: "message_priority")
    public var messagePriority: Int  // Stored as Int for DB, converted to MessagePriority enum in domain layer
    
    @Field(key: "created_at")
    public var createdAt: Date
    
    @Field(key: "updated_at")
    public var updatedAt: Date
    
    public init() {}
    
    public init(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        timestamp: Date,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]? = nil,
        deadline: Date? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.taskId = taskId
        self.description = description
        self.taskType = taskType.rawValue
        self.priority = priority
        self.files = files
        self.deadline = deadline
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = timestamp
        self.updatedAt = timestamp
    }
    
    public var taskTypeEnum: TaskType? {
        return TaskType(rawValue: taskType)
    }
    
    public var statusEnum: MessageStatus? {
        return MessageStatus(rawValue: status)
    }
    
    public var messagePriorityEnum: MessagePriority? {
        return MessagePriority(rawValue: messagePriority)
    }
}
```

### ReviewMessageModel

**Strict types - no SendableContent:**

```swift
import Fluent
import Foundation

public final class ReviewMessageModel: Model, @unchecked Sendable {
    public static let schema = "review_messages"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "message_id")
    public var messageId: UUID
    
    @Field(key: "from_ai")
    public var fromAI: String
    
    @Field(key: "to_ai")
    public var toAI: String
    
    @Field(key: "timestamp")
    public var timestamp: Date
    
    @Field(key: "task_id")
    public var taskId: String
    
    @Field(key: "approved")
    public var approved: Bool
    
    @Field(key: "reviewer")
    public var reviewer: String
    
    @OptionalField(key: "comments")
    public var comments: [ReviewComment]?  // Strict type - array of ReviewComment structs
    
    @OptionalField(key: "feedback")
    public var feedback: String?
    
    @OptionalField(key: "files_reviewed")
    public var filesReviewed: [String]?
    
    @Field(key: "status")
    public var status: String  // Stored as String for DB, converted to MessageStatus enum in domain layer
    
    @Field(key: "message_priority")
    public var messagePriority: Int  // Stored as Int for DB, converted to MessagePriority enum in domain layer
    
    @Field(key: "created_at")
    public var createdAt: Date
    
    @Field(key: "updated_at")
    public var updatedAt: Date
    
    public init() {}
    
    public init(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        timestamp: Date,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]? = nil,
        feedback: String? = nil,
        filesReviewed: [String]? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.messageId = messageId
        self.fromAI = fromAI
        self.toAI = toAI
        self.timestamp = timestamp
        self.taskId = taskId
        self.approved = approved
        self.reviewer = reviewer
        self.comments = comments
        self.feedback = feedback
        self.filesReviewed = filesReviewed
        self.status = status.rawValue
        self.messagePriority = messagePriority.rawValue
        self.createdAt = timestamp
        self.updatedAt = timestamp
    }
    
    public var statusEnum: MessageStatus? {
        return MessageStatus(rawValue: status)
    }
    
    public var messagePriorityEnum: MessagePriority? {
        return MessagePriority(rawValue: messagePriority)
    }
    
    public func getCommentsByFile() -> [String: [ReviewComment]] {
        guard let comments = comments else { return [:] }
        var result: [String: [ReviewComment]] = [:]
        for comment in comments {
            if result[comment.file] == nil {
                result[comment.file] = []
            }
            result[comment.file]?.append(comment)
        }
        return result
    }
}
```

---

## Protocol Design

### MessageCacheRepositoryProtocol

```swift
import Foundation

public protocol MessageCacheRepositoryProtocol: Sendable {
    // Task Messages
    func sendTaskMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws
    
    func getTaskMessages(forAI aiName: String, status: MessageStatus?) async throws -> [TaskMessageModel]
    func markTaskMessageAsRead(messageId: UUID) async throws -> Bool
    func markTaskMessageAsProcessed(messageId: UUID) async throws -> Bool
    func deleteTaskMessage(messageId: UUID) async throws -> Bool
    
    // Review Messages
    func sendReviewMessage(
        messageId: UUID,
        fromAI: String,
        toAI: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]?,
        feedback: String?,
        filesReviewed: [String]?,
        messagePriority: MessagePriority
    ) async throws
    
    func getReviewMessages(forAI aiName: String, status: MessageStatus?) async throws -> [ReviewMessageModel]
    func markReviewMessageAsRead(messageId: UUID) async throws -> Bool
    func markReviewMessageAsProcessed(messageId: UUID) async throws -> Bool
    func deleteReviewMessage(messageId: UUID) async throws -> Bool
}

// Note: ReviewComment now includes 'file' field for multi-file review support
// Example usage:
// let comments = [
//     ReviewComment(file: "Sources/Main.swift", line: 10, type: .error, message: "Fix this"),
//     ReviewComment(file: "Sources/Helper.swift", line: 25, type: .warning, message: "Consider refactoring")
// ]
```

### MessageCacheProtocol

```swift
import Foundation

public protocol MessageCacheProtocol: Sendable {
    // Task Messages
    func sendTask(
        to: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveTasks(for aiName: String) async throws -> [TaskMessageModel]
    func markTaskAsRead(messageId: UUID) async throws -> Bool
    func markTaskAsProcessed(messageId: UUID) async throws -> Bool
    
    // Review Messages
    func sendReview(
        to: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [ReviewComment]?,
        feedback: String?,
        filesReviewed: [String]?,
        messagePriority: MessagePriority
    ) async throws -> UUID
    
    func receiveReviews(for aiName: String) async throws -> [ReviewMessageModel]
    func markReviewAsRead(messageId: UUID) async throws -> Bool
    func markReviewAsProcessed(messageId: UUID) async throws -> Bool
}
```

---

## Corrections Made

### 1. ReviewComment Structure - CRITICAL FIX

**Wrong (SYSTEM_DESIGN.md):**
```swift
public struct ReviewComment: Codable, Sendable {
    public let line: Int
    public let type: CommentType
    public let message: String
    // ❌ Missing file field - cannot determine which file comment refers to
}
```

**Correct (with file field):**
```swift
public struct ReviewComment: Codable, Sendable {
    public let file: String  // ✅ Required for multi-file reviews
    public let line: Int
    public let type: CommentType
    public let message: String
}
```

**Rationale:** When `files_reviewed` contains multiple files, we need to know which file each comment refers to. This is a logical necessity that SYSTEM_DESIGN.md missed.

### 2. message_priority Field

**Wrong (my initial design):**
- Missing message_priority field entirely

**Correct:**
- Added message_priority field to both models
- Uses existing MessagePriority enum

### 3. Using Existing Types

**Already exist (do not recreate):**
- `MessageStatus` - in Message.swift
- `MessagePriority` - in Message.swift

**Need to create:**
- `TaskType` - new enum (doesn't exist yet)
- `ReviewComment` - new struct (doesn't exist yet)

---

## Next Steps

1. **Create TaskType enum** - Add to MessageType.swift or separate file
2. **Create ReviewComment struct** - New file for review-related types
3. **Define protocols** - Create protocol files
4. **Submit for OverseerAI review** - Before any implementation
5. **Write tests** - Test protocol correctness
6. **Implement models** - Create Fluent models
7. **Implement repository** - Create MessageCacheRepository
8. **Implement manager** - Create MessageCacheManager
9. **Create migrations** - Database migrations
10. **Integration** - Refactor BrainStateCommunication

---

**Awaiting OverseerAI review before proceeding.**
