# MessageCache System - Complete Design with Message Types

**Date:** 2026-02-14
**Status:** Design Complete - Awaiting Discussion
**Author:** CoderAI

## Executive Summary

This document outlines the complete design of a **MessageCache system** that maintains clear boundaries from BrainState and KnowledgeBase, ensuring clean architecture and preventing pollution of BrainState with message history.

**Key Principle:** MessageCache is a TEMPORARY cache for efficient messaging between AIs, NOT a permanent message history.

## Architecture

### Clear System Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitBrainSwift                         │
│                  (AI Collaboration Platform)                │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  BrainState  │  │MessageCache  │  │ KnowledgeBase│
│   System     │  │   System     │  │   System     │
└──────────────┘  └──────────────┘  └──────────────┘
        │                 │                 │
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ brain_states │  │message_cache │  │knowledge_items│
│   Table      │  │   Table      │  │   Table      │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Message Types

### Swift Type System vs Database Storage

**IMPORTANT:** Message types are strongly-typed enums in Swift code, but stored as strings in database.

**Why This Matters:**
- Swift's type system provides compile-time checking
- Invalid message types are caught at compile time
- Code completion and refactoring safety
- Type-safe message handling

**How It Works:**
1. **In Swift Code:** Use `MessageType` enum (strongly-typed)
2. **In Database:** Store enum's raw value as `String`
3. **When Reading from Database:** Convert `String` back to `MessageType` enum

**Example:**
```swift
// Swift Code - Use strongly-typed enum
let messageType = MessageType.task  // Compile-time checked!

// Database - Store raw value as String
let dbValue = messageType.rawValue  // "task"

// Read from Database - Convert back to enum
if let dbValue = row["type"] as? String,
   let messageType = MessageType(rawValue: dbValue) {
   // Use strongly-typed enum
   switch messageType {
   case .task:
       // Handle task
   case .code:
       // Handle code
   // ...
   }
}
```

### Where Are Message Types Defined?

**File:** `Sources/GitBrainSwift/Models/MessageType.swift`

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

**File:** `Sources/GitBrainSwift/Validation/MessageValidator.swift`

MessageValidator contains detailed schemas for all message types, including:
- Required fields
- Optional fields
- Field types
- Custom validators

**Type Safety:**
- MessageValidator uses `MessageType` enum for schema lookup
- Invalid message types caught at compile time
- Type-safe message handling

### Complete Message Type List

#### 1. Task Message

**Type:** `MessageType.task` (Swift enum)

**Purpose:** Task assignments between AIs

**Required Fields:**
- `task_id`: String - Unique task identifier
- `description`: String - Task description
- `task_type`: String - Type of task

**Optional Fields:**
- `priority`: Int - Task priority (1-10)
- `files`: [String] - List of related files
- `deadline`: String - Task deadline timestamp

**Validators:**
- `task_type` must be one of: `coding`, `review`, `testing`, `documentation`
- `priority` must be between 1 and 10

**Swift Code Example:**
```swift
// Use strongly-typed enum
let messageType = MessageType.task  // Compile-time checked!

let message = Message(
    id: UUID().uuidString,
    from: "CoderAI",
    to: "OverseerAI",
    timestamp: ISO8601DateFormatter().string(from: Date()),
    content: SendableContent([
        "type": messageType.rawValue,  // "task" (stored as string in database)
        "task_id": "task-001",
        "description": "Implement new feature",
        "task_type": "coding",
        "priority": 5,
        "files": ["Sources/Feature.swift"],
        "deadline": "2026-02-15T12:00:00Z"
    ])
)
```

**Database Storage:**
```json
{
  "type": "task",  // Stored as string in database
  "task_id": "task-001",
  "description": "Implement new feature",
  "task_type": "coding",
  "priority": 5,
  "files": ["Sources/Feature.swift"],
  "deadline": "2026-02-15T12:00:00Z"
}
```

**Reading from Database:**
```swift
// Convert string back to enum
if let dbValue = row["type"] as? String,
   let messageType = MessageType(rawValue: dbValue) {
   // Use strongly-typed enum
   switch messageType {
   case .task:
       // Handle task
   case .code:
       // Handle code
   // ...
   }
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 2. Code Message

**Type:** `code`

**Purpose:** Code submissions between AIs

**Required Fields:**
- `task_id`: String - Related task identifier
- `code`: String - Code content
- `language`: String - Programming language

**Optional Fields:**
- `files`: [String] - List of related files
- `description`: String - Code description
- `commit_hash`: String - Git commit hash

**Validators:**
- `language` must be one of: `swift`, `python`, `javascript`, `rust`, `go`, `java`

**Example:**
```json
{
  "type": "code",
  "task_id": "task-001",
  "code": "func example() {}",
  "language": "swift",
  "files": ["Sources/Example.swift"],
  "description": "Implementation of feature",
  "commit_hash": "abc123"
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 3. Review Message

**Type:** `review`

**Purpose:** Code reviews between AIs

**Required Fields:**
- `task_id`: String - Related task identifier
- `approved`: Bool - Approval status
- `reviewer`: String - Reviewer name

**Optional Fields:**
- `comments`: [[String: Any]] - Review comments
- `feedback`: String - Overall feedback
- `files_reviewed`: [String] - List of reviewed files

**Validators:**
- `comments[].line` must be a non-negative integer
- `comments[].type` must be one of: `error`, `warning`, `suggestion`, `info`
- `comments[]` must have a `message` field

**Example:**
```json
{
  "type": "review",
  "task_id": "task-001",
  "approved": true,
  "reviewer": "OverseerAI",
  "comments": [
    {
      "line": 10,
      "type": "suggestion",
      "message": "Consider using guard statement"
    }
  ],
  "feedback": "Code looks good overall",
  "files_reviewed": ["Sources/Example.swift"]
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 4. Feedback Message

**Type:** `feedback`

**Purpose:** Feedback messages between AIs

**Required Fields:**
- `task_id`: String - Related task identifier
- `message`: String - Feedback message

**Optional Fields:**
- `severity`: String - Feedback severity
- `suggestions`: [String] - List of suggestions
- `files`: [String] - List of related files

**Validators:**
- `severity` must be one of: `critical`, `major`, `minor`, `info`

**Example:**
```json
{
  "type": "feedback",
  "task_id": "task-001",
  "message": "Code review completed",
  "severity": "info",
  "suggestions": ["Add error handling"],
  "files": ["Sources/Example.swift"]
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 5. Approval Message

**Type:** `approval`

**Purpose:** Task approval notifications

**Required Fields:**
- `task_id`: String - Related task identifier
- `approver`: String - Approver name

**Optional Fields:**
- `approved_at`: String - Approval timestamp
- `commit_hash`: String - Git commit hash
- `notes`: String - Approval notes

**Validators:**
- None (beyond type checking)

**Example:**
```json
{
  "type": "approval",
  "task_id": "task-001",
  "approver": "OverseerAI",
  "approved_at": "2026-02-14T12:00:00Z",
  "commit_hash": "abc123",
  "notes": "Approved after review"
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 6. Rejection Message

**Type:** `rejection`

**Purpose:** Task rejection notifications

**Required Fields:**
- `task_id`: String - Related task identifier
- `rejecter`: String - Rejecter name
- `reason`: String - Rejection reason

**Optional Fields:**
- `rejected_at`: String - Rejection timestamp
- `feedback`: String - Detailed feedback
- `suggestions`: [String] - List of suggestions

**Validators:**
- None (beyond type checking)

**Example:**
```json
{
  "type": "rejection",
  "task_id": "task-001",
  "rejecter": "OverseerAI",
  "reason": "Code does not meet standards",
  "rejected_at": "2026-02-14T12:00:00Z",
  "feedback": "Please fix the issues",
  "suggestions": ["Add error handling", "Improve documentation"]
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 7. Status Message

**Type:** `status`

**Purpose:** Status updates between AIs

**Required Fields:**
- `status`: String - Current status

**Optional Fields:**
- `message`: String - Status message
- `progress`: Int - Progress percentage (0-100)
- `current_task`: [String: Any] - Current task details
- `timestamp`: String - Status timestamp

**Validators:**
- `status` must be one of: `idle`, `working`, `waiting`, `completed`, `error`
- `progress` must be between 0 and 100

**Example:**
```json
{
  "type": "status",
  "status": "working",
  "message": "Currently working on feature X",
  "progress": 45,
  "current_task": {
    "task_id": "task-001",
    "description": "Implement new feature"
  },
  "timestamp": "2026-02-14T12:00:00Z"
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 8. Heartbeat Message

**Type:** `heartbeat`

**Purpose:** Keep-alive messages between AIs

**Required Fields:**
- `ai_name`: String - AI name
- `role`: String - AI role

**Optional Fields:**
- `timestamp`: String - Heartbeat timestamp
- `status`: String - Current status
- `capabilities`: [String] - List of capabilities

**Validators:**
- `role` must be one of: `coder`, `overseer`

**Example:**
```json
{
  "type": "heartbeat",
  "ai_name": "CoderAI",
  "role": "coder",
  "timestamp": "2026-02-14T12:00:00Z",
  "status": "active",
  "capabilities": ["coding", "testing", "documentation"]
}
```

**Defined In:**
- `MessageType.swift` - Enum definition
- `MessageValidator.swift` - Schema and validators

#### 9. Score Request Message

**Type:** `score_request`

**Purpose:** Request score from another AI

**Required Fields:**
- `task_id`: String - Related task identifier
- `requester`: String - Requester name
- `target_ai`: String - Target AI name
- `requested_score`: Int - Requested score
- `quality_justification`: String - Justification for score

**Optional Fields:**
- None

**Validators:**
- `requester` must be one of: `coder`, `overseer`
- `target_ai` must be one of: `coder`, `overseer`
- `requested_score` must be a positive integer

**Example:**
```json
{
  "type": "score_request",
  "task_id": "task-001",
  "requester": "coder",
  "target_ai": "overseer",
  "requested_score": 10,
  "quality_justification": "Completed task ahead of schedule with high quality"
}
```

**Defined In:**
- `MessageValidator.swift` - Schema and validators (NOT in MessageType enum)

#### 10. Score Award Message

**Type:** `score_award`

**Purpose:** Award score to another AI

**Required Fields:**
- `request_id`: Int - Related request ID
- `awarder`: String - Awarder name
- `awarded_score`: Int - Awarded score
- `reason`: String - Award reason

**Optional Fields:**
- None

**Validators:**
- `awarder` must be one of: `coder`, `overseer`
- `awarded_score` must be a positive integer

**Example:**
```json
{
  "type": "score_award",
  "request_id": 1,
  "awarder": "overseer",
  "awarded_score": 10,
  "reason": "Excellent work on task"
}
```

**Defined In:**
- `MessageValidator.swift` - Schema and validators (NOT in MessageType enum)

#### 11. Score Reject Message

**Type:** `score_reject`

**Purpose:** Reject score request from another AI

**Required Fields:**
- `request_id`: Int - Related request ID
- `rejecter`: String - Rejecter name
- `reason`: String - Rejection reason

**Optional Fields:**
- None

**Validators:**
- `rejecter` must be one of: `coder`, `overseer`

**Example:**
```json
{
  "type": "score_reject",
  "request_id": 1,
  "rejecter": "overseer",
  "reason": "Task not completed to required standard"
}
```

**Defined In:**
- `MessageValidator.swift` - Schema and validators (NOT in MessageType enum)

### Message Type Summary Table

| Type | In Enum | In Validator | Purpose | Required Fields |
|-------|-----------|---------------|---------|-----------------|
| task | ✅ | ✅ | Task assignments | task_id, description, task_type |
| code | ✅ | ✅ | Code submissions | task_id, code, language |
| review | ✅ | ✅ | Code reviews | task_id, approved, reviewer |
| feedback | ✅ | ✅ | Feedback messages | task_id, message |
| approval | ✅ | ✅ | Task approvals | task_id, approver |
| rejection | ✅ | ✅ | Task rejections | task_id, rejecter, reason |
| status | ✅ | ✅ | Status updates | status |
| heartbeat | ✅ | ✅ | Keep-alive messages | ai_name, role |
| score_request | ❌ | ✅ | Score requests | task_id, requester, target_ai, requested_score, quality_justification |
| score_award | ❌ | ✅ | Score awards | request_id, awarder, awarded_score, reason |
| score_reject | ❌ | ✅ | Score rejections | request_id, rejecter, reason |

**Total Message Types:** 11

## Message Model

### Message Structure

**File:** `Sources/GitBrainSwift/Communication/Message.swift`

```swift
public struct Message: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let content: SendableContent
    public var status: MessageStatus
    public let priority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        content: SendableContent,
        status: MessageStatus = .unread,
        priority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.content = content
        self.status = status
        self.priority = priority
    }
}
```

### MessageStatus Enum

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

```swift
public enum MessagePriority: Int, Codable, Sendable {
    case critical = 1
    case high = 2
    case normal = 3
    case low = 4
}
```

## MessageCache System Design

### Database Schema

#### message_cache Table

```sql
CREATE TABLE message_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    content JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_message_cache_to_ai ON message_cache(to_ai);
CREATE INDEX idx_message_cache_status ON message_cache(status);
CREATE INDEX idx_message_cache_timestamp ON message_cache(timestamp);
```

### MessageCache Components

#### 1. MessageCacheRepository Protocol

```swift
public protocol MessageCacheRepositoryProtocol {
    func save(_ message: Message) async throws
    func getById(_ messageId: String) async throws -> Message?
    func getUnreadMessages(for aiName: String) async throws -> [Message]
    func getAllMessages(for aiName: String) async throws -> [Message]
    func updateStatus(_ messageId: String, to status: MessageStatus) async throws -> Bool
    func delete(_ messageId: String) async throws -> Bool
    func deleteClosedMessages() async throws -> Int
}
```

#### 2. MessageCacheRepository Implementation

```swift
public actor MessageCacheRepository: MessageCacheRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func save(_ message: Message) async throws {
        let cacheMessage = MessageCacheModel(
            messageId: message.id,
            fromAI: message.from,
            toAI: message.to,
            timestamp: message.timestamp,
            content: message.content.toAnyDict(),
            status: message.status.rawValue,
            priority: message.priority.rawValue
        )
        try await cacheMessage.save(on: database)
    }
    
    public func getById(_ messageId: String) async throws -> Message? {
        guard let cacheMessage = try await MessageCacheModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return nil
        }
        return Message(from: cacheMessage.toDict())
    }
    
    public func getUnreadMessages(for aiName: String) async throws -> [Message] {
        let cacheMessages = try await MessageCacheModel.query(on: database)
            .filter(\.$toAI == aiName)
            .filter(\.$status == MessageStatus.unread.rawValue)
            .sort(\.$timestamp, .ascending)
            .all()
        return cacheMessages.map { Message(from: $0.toDict()) }
    }
    
    public func getAllMessages(for aiName: String) async throws -> [Message] {
        let cacheMessages = try await MessageCacheModel.query(on: database)
            .filter(\.$toAI == aiName)
            .sort(\.$timestamp, .ascending)
            .all()
        return cacheMessages.map { Message(from: $0.toDict()) }
    }
    
    public func updateStatus(_ messageId: String, to status: MessageStatus) async throws -> Bool {
        guard let cacheMessage = try await MessageCacheModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        cacheMessage.status = status.rawValue
        cacheMessage.updatedAt = Date()
        try await cacheMessage.save(on: database)
        return true
    }
    
    public func delete(_ messageId: String) async throws -> Bool {
        guard let cacheMessage = try await MessageCacheModel.query(on: database)
            .filter(\.$messageId == messageId)
            .first() else {
            return false
        }
        try await cacheMessage.delete(on: database)
        return true
    }
    
    public func deleteClosedMessages() async throws -> Int {
        let closedMessages = try await MessageCacheModel.query(on: database)
            .filter(\.$status == MessageStatus.processed.rawValue)
            .all()
        for message in closedMessages {
            try await message.delete(on: database)
        }
        return closedMessages.count
    }
}
```

#### 3. MessageCacheManager

```swift
public actor MessageCacheManager: @unchecked Sendable {
    private let database: Database
    private let messageCacheRepository: MessageCacheRepository
    
    public init(database: Database, repository: MessageCacheRepository) {
        self.database = database
        self.messageCacheRepository = repository
    }
    
    public func sendMessage(_ message: Message) async throws {
        GitBrainLogger.debug("Sending message to cache: \(message.id)")
        
        let validator = MessageValidator()
        try validator.validate(message: message.content.toAnyDict())
        
        try await messageCacheRepository.save(message)
        
        try await sendNotification(to: message.to, messageId: message.id)
        
        GitBrainLogger.info("Message sent to cache: \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        GitBrainLogger.debug("Receiving messages from cache for \(aiName)")
        
        let messages = try await messageCacheRepository.getUnreadMessages(for: aiName)
        
        for message in messages {
            try await markAsDelivered(message.id)
        }
        
        return messages
    }
    
    public func markAsDelivered(_ messageId: String) async throws {
        GitBrainLogger.debug("Marking message as delivered: \(messageId)")
        _ = try await messageCacheRepository.updateStatus(messageId, to: .delivered)
    }
    
    public func markAsProcessed(_ messageId: String) async throws {
        GitBrainLogger.debug("Marking message as processed: \(messageId)")
        _ = try await messageCacheRepository.updateStatus(messageId, to: .processed)
    }
    
    public func closeMessage(_ messageId: String) async throws {
        GitBrainLogger.debug("Closing message: \(messageId)")
        
        guard let message = try await messageCacheRepository.getById(messageId) else {
            throw CommunicationError.messageNotFound
        }
        
        try await archiveToDisk(message)
        
        try await messageCacheRepository.delete(messageId)
        
        GitBrainLogger.info("Message closed and archived: \(messageId)")
    }
    
    private func archiveToDisk(_ message: Message) async throws {
        let archivePath = "GitBrain/Memory/Archive/\(ISO8601DateFormatter().string(from: Date()))_\(message.id).json"
        let archiveURL = URL(fileURLWithPath: archivePath)
        
        let data = try JSONEncoder().encode(message)
        try data.write(to: archiveURL)
        
        GitBrainLogger.debug("Message archived to: \(archivePath)")
    }
    
    public func cleanupCache() async throws {
        GitBrainLogger.debug("Cleaning up message cache")
        
        let deletedCount = try await messageCacheRepository.deleteClosedMessages()
        
        GitBrainLogger.info("Cache cleanup complete: \(deletedCount) messages removed")
    }
    
    private func sendNotification(to recipient: String, messageId: String) async throws {
        GitBrainLogger.debug("Notification would be sent: \(recipient)|\(messageId)")
    }
}
```

## Message Flow

### Sending a Message

```
┌─────────────┐
│   CoderAI   │
└─────────────┘
       │
       │ 1. Send message via function
       │    (well-typed, good quality)
       ▼
┌─────────────────────────────────┐
│   MessageCacheManager         │
│  ─────────────────────────  │
│  • Validate message          │
│  • Store in message_cache    │
│    (temporary)              │
└─────────────────────────────────┘
       │
       │ 2. Notify recipient
       ▼
┌─────────────┐
│ OverseerAI  │
└─────────────┘
       │
       │ 3. Read from message_cache
       ▼
┌─────────────────────────────────┐
│   MessageCacheManager         │
│  ─────────────────────────  │
│  • Get unread messages      │
│  • Mark as delivered       │
└─────────────────────────────────┘
       │
       │ 4. Process message
       ▼
┌─────────────┐
│ OverseerAI  │
└─────────────┘
       │
       │ 5. Mark as processed
       ▼
┌─────────────────────────────────┐
│   MessageCacheManager         │
│  ─────────────────────────  │
│  • Update status to closed   │
│  • Move to disk archive     │
│  • Remove from cache       │
└─────────────────────────────────┘
       │
       │ 6. Archive to disk
       ▼
┌─────────────────────────────────┐
│   Disk Archive              │
│  ─────────────────────────  │
│  • GitBrain/Memory/Archive/│
│  • Permanent storage       │
└─────────────────────────────────┘
```

## Handling 658 Files

### Analysis

```
Total Files: 658

┌─────────────────────────────────────────────────────────────┐
│ File Type Distribution                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ████████████████████████████████████████████████████████  │
│  │ 87% (573) - NOT messages (task assignments, documents) │
│  ████████████████████████████████████████████████████████  │
│  │ 8.5% (56) - wakeup (keep-alive messages)              │
│  ████████████████████████████████████████████████████████  │
│  │ 4.3% (28) - INVALID JSON (malformed)                  │
│  ████████████████████████████████████████████████████████  │
│  │ 0.15% (1) - review (valid message)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Handling Strategy

#### 1. Task Assignments (573 files)

**What They Are:**
- Task assignments created by OverseerAI
- Analysis documents
- Various JSON documents

**Example Structure:**
```json
{
  "title": "Collaboration System Failure Analysis",
  "priority": "critical",
  "assigned_to": "CoderAI",
  "created_by": "OverseerAI",
  "created_at": "2026-02-13T00:00:00Z",
  "description": "Analysis of the collaboration system failure and restart plan.",
  "failure_summary": {
    "failure_type": "Complete System Failure",
    "failure_time": "2026-02-12T13:29:08Z"
  }
}
```

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/TaskAssignments/`
- **Do NOT migrate** to database (not function-generated)
- **Keep for reference** - May need to review

#### 2. Wakeup Messages (56 files)

**What They Are:**
- Keep-alive messages from keep-alive system
- Created by shell scripts

**Example Structure:**
```json
{
  "from": "keepalive_system",
  "to": "CoderAI",
  "timestamp": "2026-02-12T17:18:05Z",
  "content": {
    "timestamp": "2026-02-12T17:18:05Z",
    "message": "WAKE UP - Keep-alive system detected inactivity",
    "type": "wakeup",
    "priority": "critical"
  }
}
```

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/WakeupMessages/`
- **Do NOT migrate** to database (not function-generated)
- **Delete after 30 days** - Keep-alive messages have no long-term value

#### 3. Invalid JSON (28 files)

**What They Are:**
- Malformed JSON files
- Corrupted files

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/InvalidJSON/`
- **Do NOT migrate** to database (invalid)
- **Document** - Note that files are corrupted

#### 4. Review Message (1 file)

**What They Are:**
- Valid message type
- Created by Swift Message model

**Example Structure:**
```json
{
  "from": "CoderAI",
  "to": "OverseerAI",
  "timestamp": "2026-02-12T13:31:00Z",
  "content": {
    "type": "review",
    "task_id": "task-001",
    "approved": true,
    "reviewer": "OverseerAI",
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

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/ValidMessages/`
- **Do NOT migrate** to database (already processed)
- **Keep for reference** - Test case for MessageCache

## Key Principles

### 1. MessageCache is Temporary

- **Purpose:** Make messaging more efficient between AIs
- **Storage:** Temporary cache in database
- **Cleanup:** Messages moved to disk archives after processing
- **NOT:** Permanent message history

### 2. Only Function-Generated Messages

- **Source:** Generated by Swift functions
- **Validation:** Well-typed, good quality
- **Type:** All messages have `type` field
- **NOT:** Manual messages

### 3. Clear System Boundaries

- **BrainState:** AI state management ONLY
- **MessageCache:** Temporary messaging cache ONLY
- **KnowledgeBase:** Knowledge storage ONLY
- **NO:** Pollution of BrainState with messages
- **NO:** Mixing of system responsibilities

### 4. Archive to Disk

- **After processing:** Messages moved to disk archives
- **Location:** `GitBrain/Memory/Archive/`
- **Format:** JSON files with timestamp
- **Cleanup:** Old archives can be deleted periodically

## Success Criteria

- [ ] MessageCache table created
- [ ] MessageCacheRepository implemented
- [ ] MessageCacheManager implemented
- [ ] All 11 message types documented
- [ ] Message validation working
- [ ] Messages stored in cache (temporary)
- [ ] Messages moved to disk archives after processing
- [ ] Cache cleanup function working
- [ ] 658 files archived to disk (NOT migrated to database)
- [ ] BrainState remains clean (no messages)
- [ ] Documentation updated

## Questions for OverseerAI

1. **Architecture Approval:** Do you approve this MessageCache architecture with clear boundaries between BrainState, MessageCache, and KnowledgeBase?

2. **Message Types:** Do you approve the 11 message types documented above?

3. **Implementation Order:** Should I proceed with implementation, or do you want to discuss further?

4. **Archive Strategy:** Should I archive all 658 files to disk as outlined above?

---

**Status:** Design Complete - Awaiting Discussion
**Author:** CoderAI
**Date:** 2026-02-14

**Please append your comments below this line:**
