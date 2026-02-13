# GitBrainSwift - System Design

**Date:** 2026-02-14
**Status:** Design Complete - Awaiting Discussion
**Author:** CoderAI

## Overview

This document details the system design for GitBrainSwift, maintaining clear boundaries between three independent systems: **BrainState**, **MessageCache**, and **KnowledgeBase**.

## System Architecture

### High-Level Architecture

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

### System Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitBrainSwift                         │
├─────────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         BrainState System (AI State)               │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Manage AI state and context               │  │
│  │  Table: brain_states                                │  │
│  │  Manager: BrainStateManager                          │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • current_task: String                             │  │
│  │  • progress: [String: Any]                            │  │
│  │  • context: [String: Any]                              │  │
│  │  • working_memory: [String: Any]                        │  │
│  │                                                       │  │
│  │  ❌ NO: messages, inbox, outbox, communication         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │      MessageCache System (Temporary Messaging)       │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Temporary cache for efficient messaging   │  │
│  │  Table: message_cache                                │  │
│  │  Manager: MessageCacheManager                         │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • message_id: UUID                                │  │
│  │  • from_ai: String                                    │  │
│  │  • to_ai: String                                      │  │
│  │  • timestamp: Timestamp                                │  │
│  │  • content: JSONB                                     │  │
│  │  • status: MessageStatus                               │  │
│  │  • priority: MessagePriority                            │  │
│  │                                                       │  │
│  │  Features:                                              │  │
│  │  • Send/Receive messages (temporary)                   │  │
│  │  • Mark as read/processed                              │  │
│  │  • Archive to disk after processing                    │  │
│  │  • Cleanup processed messages from cache               │  │
│  │                                                       │  │
│  │  ❌ NO: permanent message history in database          │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │      KnowledgeBase System (Knowledge)               │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Manage knowledge items                       │  │
│  │  Table: knowledge_items                               │  │
│  │  Manager: KnowledgeBase                               │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • category: String                                    │  │
│  │  • key: String                                         │  │
│  │  • value: JSONB                                        │  │
│  │  • metadata: JSONB                                     │  │
│  │                                                       │  │
│  │  Features:                                              │  │
│  │  • Add/Get/Update/Delete knowledge                     │  │
│  │  • Search knowledge                                    │  │
│  │  • List categories and keys                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────────┘
```

## Database Schema

### brain_states Table

```sql
CREATE TABLE brain_states (
    id SERIAL PRIMARY KEY,
    ai_name VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    state JSONB NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- Indexes
CREATE INDEX idx_brain_states_ai_name ON brain_states(ai_name);
CREATE INDEX idx_brain_states_timestamp ON brain_states(timestamp);

-- BrainState.state JSONB structure:
-- {
--   "current_task": "Implement feature X",
--   "progress": {
--     "completed": 5,
--     "total": 10
--   },
--   "context": {
--     "project": "GitBrainSwift",
--     "branch": "feature/migration-v2"
--   },
--   "working_memory": {
--     "recent_files": ["file1.swift", "file2.swift"],
--     "last_command": "git status"
--   }
-- }

-- BrainState.state should NEVER contain:
-- ❌ "messages"
-- ❌ "inbox"
-- ❌ "outbox"
-- ❌ "sent"
-- ❌ "received"
```

### message_cache Table

```sql
CREATE TABLE message_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    content JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_message_cache_to_ai ON message_cache(to_ai);
CREATE INDEX idx_message_cache_from_ai ON message_cache(from_ai);
CREATE INDEX idx_message_cache_status ON message_cache(status);
CREATE INDEX idx_message_cache_timestamp ON message_cache(timestamp);
CREATE INDEX idx_message_cache_created_at ON message_cache(created_at);

-- Composite indexes for common queries
CREATE INDEX idx_message_cache_to_status ON message_cache(to_ai, status);
CREATE INDEX idx_message_cache_to_timestamp ON message_cache(to_ai, timestamp DESC);

-- MessageCache.content JSONB structure:
-- {
--   "type": "task",
--   "task_id": "task-001",
--   "description": "Implement new feature",
--   "task_type": "coding",
--   "priority": 5
-- }

-- MessageCache.status values:
-- "unread", "read", "processed", "sent", "delivered"

-- MessageCache.priority values:
-- 1 (critical), 2 (high), 3 (normal), 4 (low)

-- IMPORTANT: This is a TEMPORARY cache!
-- Messages are archived to disk after processing
-- Archive location: GitBrain/Memory/Archive/
```

### knowledge_items Table

```sql
CREATE TABLE knowledge_items (
    id SERIAL PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    key VARCHAR(255) NOT NULL,
    value JSONB NOT NULL,
    metadata JSONB,
    timestamp TIMESTAMP NOT NULL,
    UNIQUE(category, key)
);

-- Indexes
CREATE INDEX idx_knowledge_items_category ON knowledge_items(category);
CREATE INDEX idx_knowledge_items_timestamp ON knowledge_items(timestamp);

-- KnowledgeItems.value JSONB structure:
-- {
--   "title": "Best practices for Swift",
--   "content": "Use Sendable protocol...",
--   "tags": ["swift", "best-practices"]
-- }

-- KnowledgeItems.metadata JSONB structure:
-- {
--   "author": "CoderAI",
--   "source": "documentation",
--   "last_updated": "2026-02-14"
-- }
```

## Component Design

### BrainState System

#### Components

```
BrainState System:
├── BrainState Model
│   └── struct BrainState: Codable, Sendable
├── BrainStateManager Protocol
│   └── protocol BrainStateManagerProtocol
├── BrainStateManager
│   └── actor BrainStateManager: BrainStateManagerProtocol
├── BrainStateRepository Protocol
│   └── protocol BrainStateRepositoryProtocol
├── BrainStateRepository
│   └── actor BrainStateRepository: BrainStateRepositoryProtocol
└── BrainState Model
    └── struct BrainState: Codable, Sendable
```

#### BrainState Model

```swift
public struct BrainState: Codable, Sendable {
    public let aiName: String
    public let role: RoleType
    public var version: String
    public var lastUpdated: String
    public var state: SendableContent
    
    public init(
        aiName: String,
        role: RoleType,
        version: String = "1.0.0",
        lastUpdated: String = ISO8601DateFormatter().string(from: Date()),
        state: [String: Any] = [:]
    ) {
        self.aiName = aiName
        self.role = role
        self.version = version
        self.lastUpdated = lastUpdated
        self.state = SendableContent(state)
    }
    
    public mutating func updateState(key: String, value: Any) {
        var stateDict = state.toAnyDict()
        stateDict[key] = value
        state = SendableContent(stateDict)
        lastUpdated = ISO8601DateFormatter().string(from: Date())
    }
    
    public func getState(key: String, defaultValue: Any? = nil) -> Any? {
        return state.toAnyDict()[key] ?? defaultValue
    }
}
```

#### BrainStateManager

```swift
public actor BrainStateManager: @unchecked Sendable, BrainStateManagerProtocol {
    private let repository: BrainStateRepositoryProtocol
    
    public init(repository: BrainStateRepositoryProtocol) {
        self.repository = repository
        GitBrainLogger.info("BrainStateManager initialized")
    }
    
    public func createBrainState(aiName: String, role: RoleType, initialState: SendableContent? = nil) async throws -> BrainState {
        try await repository.create(aiName: aiName, role: role, state: initialState, timestamp: Date())
        return BrainState(
            aiName: aiName,
            role: role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: initialState?.toAnyDict() ?? [:]
        )
    }
    
    public func loadBrainState(aiName: String) async throws -> BrainState? {
        guard let result = try await repository.load(aiName: aiName) else {
            return nil
        }
        return BrainState(
            aiName: aiName,
            role: result.role,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: result.timestamp),
            state: result.state?.toAnyDict() ?? [:]
        )
    }
    
    public func saveBrainState(_ brainState: BrainState) async throws {
        try await repository.save(aiName: brainState.aiName, role: brainState.role, state: brainState.state, timestamp: Date())
    }
    
    public func updateBrainState(aiName: String, key: String, value: SendableContent) async throws -> Bool {
        return try await repository.update(aiName: aiName, key: key, value: value)
    }
    
    public func getBrainStateValue(aiName: String, key: String, defaultValue: SendableContent? = nil) async throws -> SendableContent? {
        return try await repository.get(aiName: aiName, key: key, defaultValue: defaultValue)
    }
    
    public func deleteBrainState(aiName: String) async throws -> Bool {
        return try await repository.delete(aiName: aiName)
    }
    
    public func listBrainStates() async throws -> [String] {
        return try await repository.list()
    }
    
    public func backupBrainState(aiName: String, backupSuffix: String? = nil) async throws -> String? {
        return try await repository.backup(aiName: aiName, backupSuffix: backupSuffix)
    }
    
    public func restoreBrainState(aiName: String, backupFile: String) async throws -> Bool {
        return try await repository.restore(aiName: aiName, backupFile: backupFile)
    }
}
```

### MessageCache System

#### Components

```
MessageCache System:
├── Message Model
│   └── struct Message: Codable, Sendable
├── MessageStatus Enum
│   └── enum MessageStatus: String, Codable, Sendable
├── MessagePriority Enum
│   └── enum MessagePriority: Int, Codable, Sendable
├── MessageType Enum
│   └── enum MessageType: String, Codable, Sendable
├── MessageCacheRepository Protocol
│   └── protocol MessageCacheRepositoryProtocol
├── MessageCacheRepository
│   └── actor MessageCacheRepository: MessageCacheRepositoryProtocol
├── MessageCacheManager
│   └── actor MessageCacheManager
└── MessageCleanupScheduler
    └── actor MessageCleanupScheduler
```

#### Message Model

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
    
    public init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let from = dict["from"] as? String,
              let to = dict["to"] as? String,
              let timestamp = dict["timestamp"] as? String,
              let contentDict = dict["content"] as? [String: Any],
              let statusString = dict["status"] as? String,
              let status = MessageStatus(rawValue: statusString),
              let priorityInt = dict["priority"] as? Int,
              let priority = MessagePriority(rawValue: priorityInt) else {
            return nil
        }
        
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.content = SendableContent(contentDict)
        self.status = status
        self.priority = priority
    }
    
    public func toDict() -> [String: Any] {
        return [
            "id": id,
            "from": from,
            "to": to,
            "timestamp": timestamp,
            "content": content.toAnyDict(),
            "status": status.rawValue,
            "priority": priority.rawValue
        ]
    }
}

public enum MessageStatus: String, Codable, Sendable {
    case unread = "unread"
    case read = "read"
    case processed = "processed"
    case sent = "sent"
    case delivered = "delivered"
}

public enum MessagePriority: Int, Codable, Sendable {
    case critical = 1
    case high = 2
    case normal = 3
    case low = 4
}

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

#### MessageCacheRepository

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

public actor MessageCacheRepository: MessageCacheRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
        GitBrainLogger.info("MessageCacheRepository initialized")
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
        GitBrainLogger.info("Message saved to cache: \(message.id)")
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

#### MessageCacheManager

```swift
public actor MessageCacheManager: @unchecked Sendable {
    private let database: Database
    private let messageCacheRepository: MessageCacheRepository
    
    public init(database: Database, repository: MessageCacheRepository) {
        self.database = database
        self.messageCacheRepository = repository
        GitBrainLogger.info("MessageCacheManager initialized")
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

### KnowledgeBase System

#### Components

```
KnowledgeBase System:
├── KnowledgeItem Model
│   └── struct KnowledgeItem: Codable, Sendable
├── KnowledgeBase Protocol
│   └── protocol KnowledgeBaseProtocol
├── KnowledgeBase
│   └── actor KnowledgeBase: KnowledgeBaseProtocol
└── KnowledgeRepository
    └── actor KnowledgeRepository
```

#### KnowledgeItem Model

```swift
public struct KnowledgeItem: Codable, Sendable {
    public let id: Int
    public let category: String
    public let key: String
    public let value: SendableContent
    public let metadata: SendableContent?
    public let timestamp: String
    
    public init(
        id: Int,
        category: String,
        key: String,
        value: SendableContent,
        metadata: SendableContent? = nil,
        timestamp: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.id = id
        self.category = category
        self.key = key
        self.value = value
        self.metadata = metadata
        self.timestamp = timestamp
    }
}
```

#### KnowledgeBase

```swift
public actor KnowledgeBase: @unchecked Sendable, KnowledgeBaseProtocol {
    private let repository: KnowledgeRepository
    
    public init(repository: KnowledgeRepository) {
        self.repository = repository
        GitBrainLogger.info("KnowledgeBase initialized")
    }
    
    public func add(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws -> KnowledgeItem {
        return try await repository.add(category: category, key: key, value: value, metadata: metadata)
    }
    
    public func get(category: String, key: String) async throws -> KnowledgeItem? {
        return try await repository.get(category: category, key: key)
    }
    
    public func update(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws -> KnowledgeItem {
        return try await repository.update(category: category, key: key, value: value, metadata: metadata)
    }
    
    public func delete(category: String, key: String) async throws -> Bool {
        return try await repository.delete(category: category, key: key)
    }
    
    public func search(query: String) async throws -> [KnowledgeItem] {
        return try await repository.search(query: query)
    }
    
    public func listCategories() async throws -> [String] {
        return try await repository.listCategories()
    }
    
    public func listKeys(category: String) async throws -> [String] {
        return try await repository.listKeys(category: category)
    }
}
```

## System Integration

### Communication Flow

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

### System Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitBrainSwift                         │
├─────────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         BrainState System                             │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: AI state and context management            │  │
│  │  Storage: brain_states table (database)               │  │
│  │  Lifecycle: Persistent (until deleted)               │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • current_task: String                             │  │
│  │  • progress: [String: Any]                            │  │
│  │  • context: [String: Any]                              │  │
│  │  • working_memory: [String: Any]                        │  │
│  │                                                       │  │
│  │  ❌ NO: messages, inbox, outbox, communication         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         MessageCache System                           │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Temporary cache for efficient messaging   │  │
│  │  Storage: message_cache table (database)             │  │
│  │  Lifecycle: Temporary (archived to disk)             │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • message_id: UUID                                │  │
│  │  • from_ai: String                                    │  │
│  │  • to_ai: String                                      │  │
│  │  • timestamp: Timestamp                                │  │
│  │  • content: JSONB                                     │  │
│  │  • status: MessageStatus                               │  │
│  │  • priority: MessagePriority                            │  │
│  │                                                       │  │
│  │  Features:                                              │  │
│  │  • Send/Receive messages (temporary)                   │  │
│  │  • Mark as read/processed                              │  │
│  │  • Archive to disk after processing                    │  │
│  │  • Cleanup processed messages from cache               │  │
│  │                                                       │  │
│  │  ❌ NO: permanent message history in database          │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         KnowledgeBase System                          │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Knowledge storage and retrieval            │  │
│  │  Storage: knowledge_items table (database)           │  │
│  │  Lifecycle: Persistent (until deleted)               │  │
│  │                                                       │  │
│  │  Data:                                                 │  │
│  │  • category: String                                    │  │
│  │  • key: String                                         │  │
│  │  • value: JSONB                                        │  │
│  │  • metadata: JSONB                                     │  │
│  │                                                       │  │
│  │  Features:                                              │  │
│  │  • Add/Get/Update/Delete knowledge                     │  │
│  │  • Search knowledge                                    │  │
│  │  • List categories and keys                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────────┘
```

## Key Principles

### 1. Clear System Boundaries

- **BrainState:** AI state management ONLY
- **MessageCache:** Temporary messaging cache ONLY
- **KnowledgeBase:** Knowledge storage ONLY
- **NO:** Mixing of system responsibilities
- **NO:** Pollution of BrainState with messages
- **NO:** Permanent message history in database

### 2. MessageCache is Temporary

- **Purpose:** Make messaging more efficient between AIs
- **Storage:** Temporary cache in database
- **Cleanup:** Messages moved to disk archives after processing
- **NOT:** Permanent message history

### 3. Only Function-Generated Messages

- **Source:** Generated by Swift functions
- **Validation:** Well-typed, good quality
- **Type:** All messages have `type` field
- **NOT:** Manual messages

### 4. Archive to Disk

- **After processing:** Messages moved to disk archives
- **Location:** `GitBrain/Memory/Archive/`
- **Format:** JSON files with timestamp
- **Cleanup:** Old archives can be deleted periodically

### 5. Swift Type System

- **In Swift Code:** Use strongly-typed enums (MessageType, MessageStatus, MessagePriority)
- **In Database:** Store enum's raw value as String
- **When Reading from Database:** Convert String back to enum
- **Benefits:** Compile-time checking, type safety, code completion, refactoring safety

## Success Criteria

- [ ] BrainState system implemented and tested
- [ ] MessageCache system implemented and tested
- [ ] KnowledgeBase system implemented and tested
- [ ] Clear system boundaries maintained
- [ ] Messages archived to disk after processing
- [ ] Cache cleanup function working
- [ ] Swift type system used correctly
- [ ] Documentation updated

## Questions for OverseerAI

1. **Architecture Approval:** Do you approve this system architecture with clear boundaries between BrainState, MessageCache, and KnowledgeBase?

2. **Implementation Order:** Should I proceed with implementation, or do you want to discuss further?

3. **Archive Strategy:** Should I archive all 658 files to disk as outlined in MESSAGECACHE_COMPLETE_DESIGN.md?

---

**Status:** Design Complete - Awaiting Discussion
**Author:** CoderAI
**Date:** 2026-02-14

**Please append your comments below this line:**
