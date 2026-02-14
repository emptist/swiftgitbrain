# GitBrainSwift - New System Design

**Date:** 2026-02-14
**Status:** Design Phase - Awaiting Discussion
**Author:** CoderAI

## Overview

This document details the new system design for GitBrainSwift, maintaining clear boundaries between three independent systems: **BrainState**, **MessageCache**, and **KnowledgeBase**.

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
│  BrainState  │  │MessageCache│  │ KnowledgeBase│
│   System     │  │   System     │  │   System     │
└──────────────┘  └──────────────┘  └──────────────┘
        │                 │                 │
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ brain_states │  │message_history│  │knowledge_items│
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
│  │      MessageCache System (Communication)            │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Purpose: Manage AI communication messages           │  │
│  │  Table: message_history                               │  │
│  │  Manager: MessageCacheManager                      │  │
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
│  │  • Send/Receive messages                               │  │
│  │  • Mark as read/processed                              │  │
│  │  • Cleanup old messages                                 │  │
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

### message_history Table

```sql
CREATE TABLE message_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    content JSONB NOT NULL,
    status VARCHAR(50) NOT NULL,
    priority INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_message_history_to_ai ON message_history(to_ai);
CREATE INDEX idx_message_history_from_ai ON message_history(from_ai);
CREATE INDEX idx_message_history_status ON message_history(status);
CREATE INDEX idx_message_history_timestamp ON message_history(timestamp);
CREATE INDEX idx_message_history_created_at ON message_history(created_at);

-- Composite indexes for common queries
CREATE INDEX idx_message_history_to_status ON message_history(to_ai, status);
CREATE INDEX idx_message_history_to_timestamp ON message_history(to_ai, timestamp DESC);

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
├── MessageRepository Protocol
│   └── protocol MessageRepositoryProtocol
├── MessageRepository
│   └── actor MessageRepository: MessageRepositoryProtocol
├── MessageCondition Struct
│   └── struct MessageCondition: Sendable
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
```

#### MessageRepository

```swift
public actor MessageRepository: MessageRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
        GitBrainLogger.info("MessageRepository initialized")
    }
    
    public func add(_ message: Message) async throws {
        let query = MessageRecord(
            id: UUID(uuidString: message.id)!,
            fromAI: message.from,
            toAI: message.to,
            timestamp: ISO8601DateFormatter().date(from: message.timestamp)!,
            content: message.content.data,
            status: message.status.rawValue,
            priority: message.priority.rawValue
        )
        try await query.create(on: database)
        GitBrainLogger.info("Message added: \(message.id)")
    }
    
    public func get(messageId: String) async throws -> Message? {
        guard let uuid = UUID(uuidString: messageId) else {
            return nil
        }
        guard let record = try await MessageRecord.find(uuid, on: database) else {
            return nil
        }
        return Message(
            id: record.id.uuidString,
            from: record.fromAI,
            to: record.toAI,
            timestamp: ISO8601DateFormatter().string(from: record.timestamp),
            content: SendableContent(record.content),
            status: MessageStatus(rawValue: record.status) ?? .unread,
            priority: MessagePriority(rawValue: record.priority) ?? .normal
        )
    }
    
    public func getUnread(for aiName: String) async throws -> [Message] {
        let records = try await MessageRecord.query(on: database)
            .filter(\.$toAI == aiName)
            .filter(\.$status == MessageStatus.unread.rawValue)
            .sort(\.$timestamp, .descending)
            .all()
        
        return records.map { record in
            Message(
                id: record.id.uuidString,
                from: record.fromAI,
                to: record.toAI,
                timestamp: ISO8601DateFormatter().string(from: record.timestamp),
                content: SendableContent(record.content),
                status: MessageStatus(rawValue: record.status) ?? .unread,
                priority: MessagePriority(rawValue: record.priority) ?? .normal
            )
        }
    }
    
    public func getAll(for aiName: String) async throws -> [Message] {
        let records = try await MessageRecord.query(on: database)
            .filter(\.$toAI == aiName)
            .sort(\.$timestamp, .descending)
            .all()
        
        return records.map { record in
            Message(
                id: record.id.uuidString,
                from: record.fromAI,
                to: record.toAI,
                timestamp: ISO8601DateFormatter().string(from: record.timestamp),
                content: SendableContent(record.content),
                status: MessageStatus(rawValue: record.status) ?? .unread,
                priority: MessagePriority(rawValue: record.priority) ?? .normal
            )
        }
    }
    
    public func updateStatus(messageId: String, status: MessageStatus) async throws -> Bool {
        guard let uuid = UUID(uuidString: messageId) else {
            return false
        }
        guard let record = try await MessageRecord.find(uuid, on: database) else {
            return false
        }
        record.status = status.rawValue
        try await record.update(on: database)
        GitBrainLogger.info("Message status updated: \(messageId) -> \(status.rawValue)")
        return true
    }
    
    public func delete(messageId: String) async throws -> Bool {
        guard let uuid = UUID(uuidString: messageId) else {
            return false
        }
        guard let record = try await MessageRecord.find(uuid, on: database) else {
            return false
        }
        try await record.delete(on: database)
        GitBrainLogger.info("Message deleted: \(messageId)")
        return true
    }
    
    public func deleteOldMessages(before date: Date) async throws -> Int {
        let records = try await MessageRecord.query(on: database)
            .filter(\.$timestamp < date)
            .all()
        
        for record in records {
            try await record.delete(on: database)
        }
        
        GitBrainLogger.info("Deleted \(records.count) old messages before \(date)")
        return records.count
    }
    
    public func deleteByCondition(_ condition: MessageCondition) async throws -> Int {
        var query = MessageRecord.query(on: database)
        
        switch condition.type {
        case .olderThan(let date):
            query = query.filter(\.$timestamp < date)
        case .status(let status):
            query = query.filter(\.$status == status.rawValue)
        case .priority(let priority):
            query = query.filter(\.$priority == priority.rawValue)
        case .from(let fromAI):
            query = query.filter(\.$fromAI == fromAI)
        case .to(let toAI):
            query = query.filter(\.$toAI == toAI)
        case .custom(let predicate):
            let allRecords = try await query.all()
            let matchingRecords = allRecords.filter { record in
                let message = Message(
                    id: record.id.uuidString,
                    from: record.fromAI,
                    to: record.toAI,
                    timestamp: ISO8601DateFormatter().string(from: record.timestamp),
                    content: SendableContent(record.content),
                    status: MessageStatus(rawValue: record.status) ?? .unread,
                    priority: MessagePriority(rawValue: record.priority) ?? .normal
                )
                return predicate(message)
            }
            for record in matchingRecords {
                try await record.delete(on: database)
            }
            GitBrainLogger.info("Deleted \(matchingRecords.count) messages by custom condition: \(condition.description)")
            return matchingRecords.count
        }
        
        let records = try await query.all()
        for record in records {
            try await record.delete(on: database)
        }
        
        GitBrainLogger.info("Deleted \(records.count) messages by condition: \(condition.description)")
        return records.count
    }
}
```

#### MessageCacheManager

```swift
public actor MessageCacheManager {
    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
        GitBrainLogger.info("MessageCacheManager initialized")
    }
    
    public func sendMessage(_ message: Message) async throws {
        try await repository.add(message)
        GitBrainLogger.info("Message sent: \(message.id)")
    }
    
    public func receiveMessages(for aiName: String, unreadOnly: Bool = true) async throws -> [Message] {
        if unreadOnly {
            return try await repository.getUnread(for: aiName)
        } else {
            return try await repository.getAll(for: aiName)
        }
    }
    
    public func markAsRead(_ messageId: String) async throws {
        _ = try await repository.updateStatus(messageId, status: .read)
        GitBrainLogger.info("Message marked as read: \(messageId)")
    }
    
    public func markAsProcessed(_ messageId: String) async throws {
        _ = try await repository.updateStatus(messageId, status: .processed)
        GitBrainLogger.info("Message marked as processed: \(messageId)")
    }
    
    public func cleanupOldMessages(olderThan days: Int) async throws -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        return try await repository.deleteOldMessages(before: cutoffDate)
    }
    
    public func cleanupByCondition(_ condition: MessageCondition) async throws -> Int {
        return try await repository.deleteByCondition(condition)
    }
}
```

#### MessageCondition

```swift
public struct MessageCondition: Sendable {
    public enum ConditionType {
        case olderThan(Date)
        case status(MessageStatus)
        case priority(MessagePriority)
        case from(String)
        case to(String)
        case custom((Message) -> Bool)
    }
    
    public let type: ConditionType
    public let description: String
    
    public init(type: ConditionType, description: String) {
        self.type = type
        self.description = description
    }
}
```

#### MessageCleanupScheduler

```swift
public actor MessageCleanupScheduler {
    private let MessageCacheManager: MessageCacheManager
    private var isRunning = false
    
    public init(MessageCacheManager: MessageCacheManager) {
        self.MessageCacheManager = MessageCacheManager
        GitBrainLogger.info("MessageCleanupScheduler initialized")
    }
    
    public func startDailyCleanup() async {
        guard !isRunning else {
            GitBrainLogger.warning("Cleanup scheduler already running")
            return
        }
        
        isRunning = true
        GitBrainLogger.info("Starting daily cleanup scheduler")
        
        while isRunning {
            do {
                try await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000) // 24 hours
                
                let deletedCount = try await MessageCacheManager.cleanupOldMessages(olderThan: 30)
                GitBrainLogger.info("Daily cleanup: Deleted \(deletedCount) messages older than 30 days")
                
                let processedCondition = MessageCondition(
                    type: .status(.processed),
                    description: "Delete processed messages"
                )
                let processedDeleted = try await MessageCacheManager.cleanupByCondition(processedCondition)
                GitBrainLogger.info("Daily cleanup: Deleted \(processedDeleted) processed messages")
                
            } catch {
                GitBrainLogger.error("Daily cleanup failed: \(error)")
            }
        }
    }
    
    public func stop() {
        isRunning = false
        GitBrainLogger.info("Stopping daily cleanup scheduler")
    }
}
```

### KnowledgeBase System

#### Components

```
KnowledgeBase System:
├── KnowledgeRepository Protocol
│   └── protocol KnowledgeRepositoryProtocol
├── KnowledgeRepository
│   └── actor KnowledgeRepository: KnowledgeRepositoryProtocol
└── KnowledgeBase
    └── actor KnowledgeBase: KnowledgeBaseProtocol
```

#### KnowledgeBase

```swift
public actor KnowledgeBase: KnowledgeBaseProtocol {
    private let repository: KnowledgeRepositoryProtocol
    
    public init(repository: KnowledgeRepositoryProtocol) {
        self.repository = repository
        GitBrainLogger.info("KnowledgeBase initialized")
    }
    
    public func addKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws {
        try await repository.add(category: category, key: key, value: value, metadata: metadata ?? SendableContent([:]), timestamp: Date())
        GitBrainLogger.info("Knowledge added: \(category)/\(key)")
    }
    
    public func getKnowledge(category: String, key: String) async throws -> SendableContent? {
        guard let result = try await repository.get(category: category, key: key) else {
            return nil
        }
        return result.value
    }
    
    public func updateKnowledge(category: String, key: String, value: SendableContent, metadata: SendableContent? = nil) async throws -> Bool {
        let result = try await repository.update(category: category, key: key, value: value, metadata: metadata ?? SendableContent([:]), timestamp: Date())
        return result
    }
    
    public func deleteKnowledge(category: String, key: String) async throws -> Bool {
        let result = try await repository.delete(category: category, key: key)
        return result
    }
    
    public func listCategories() async throws -> [String] {
        return try await repository.listCategories()
    }
    
    public func listKeys(category: String) async throws -> [String] {
        return try await repository.listKeys(category: category)
    }
    
    public func searchKnowledge(category: String, query: String) async throws -> [SendableContent] {
        let results = try await repository.search(category: category, query: query)
        return results.map { $0.value }
    }
}
```

## Communication System

> **⚠️ Note:** The `BrainStateCommunication` class documented below has been deprecated. Use `MessageCache` directly for messaging operations. See [API.md](Docs/API.md) for current documentation.

### BrainStateCommunication (Deprecated)

```swift
public actor BrainStateCommunication: @unchecked Sendable {
    private let brainStateManager: BrainStateManager
    private let MessageCacheManager: MessageCacheManager
    
    public init(brainStateManager: BrainStateManager, MessageCacheManager: MessageCacheManager) {
        self.brainStateManager = brainStateManager
        self.MessageCacheManager = MessageCacheManager
        GitBrainLogger.info("BrainStateCommunication initialized")
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        GitBrainLogger.debug("Sending message to \(recipient)")
        
        try await MessageCacheManager.sendMessage(message)
        
        try await sendNotification(to: recipient, messageId: message.id)
        
        GitBrainLogger.info("Message sent to \(recipient): \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        GitBrainLogger.debug("Receiving messages for \(aiName)")
        
        return try await MessageCacheManager.receiveMessages(for: aiName)
    }
    
    public func markAsRead(_ messageId: String, for aiName: String) async throws {
        GitBrainLogger.debug("Marking message as read: \(messageId)")
        
        try await MessageCacheManager.markAsRead(messageId)
        
        GitBrainLogger.info("Message marked as read: \(messageId)")
    }
    
    private func sendNotification(to recipient: String, messageId: String) async throws {
        GitBrainLogger.debug("Notification would be sent: \(recipient)|\(messageId)")
    }
}
```

## Data Flow

### Message Sending Flow

```
CoderAI
  │
  ├─> BrainStateCommunication.sendMessage(message, to: "OverseerAI")
  │       │
  │       ├─> MessageCacheManager.sendMessage(message)
  │       │       │
  │       │       └─> MessageRepository.add(message)
  │       │               │
  │       │               └─> message_history table
  │       │
  │       └─> sendNotification(to: "OverseerAI", messageId: message.id)
  │               │
  │               └─> PostgreSQL LISTEN/NOTIFY
  │
  └─> Message sent successfully
```

### Message Receiving Flow

```
OverseerAI
  │
  ├─> BrainStateCommunication.receiveMessages(for: "OverseerAI")
  │       │
  │       ├─> MessageCacheManager.receiveMessages(for: "OverseerAI", unreadOnly: true)
  │       │       │
  │       │       └─> MessageRepository.getUnread(for: "OverseerAI")
  │       │               │
  │       │               └─> SELECT * FROM message_history WHERE to_ai = 'OverseerAI' AND status = 'unread'
  │       │
  │       └─> Return [Message]
  │
  └─> Messages received
```

### BrainState Update Flow

```
CoderAI
  │
  ├─> BrainStateManager.updateBrainState(aiName: "CoderAI", key: "current_task", value: "Implement feature X")
  │       │
  │       └─> BrainStateRepository.update(aiName: "CoderAI", key: "current_task", value: value)
  │               │
  │               └─> UPDATE brain_states SET state = jsonb_set(state, '{current_task}', '...') WHERE ai_name = 'CoderAI'
  │
  └─> BrainState updated
```

### Knowledge Update Flow

```
CoderAI
  │
  ├─> KnowledgeBase.addKnowledge(category: "best-practices", key: "swift", value: content)
  │       │
  │       └─> KnowledgeRepository.add(category: "best-practices", key: "swift", value: content, ...)
  │               │
  │               └─> INSERT INTO knowledge_items (category, key, value, ...) VALUES (...)
  │
  └─> Knowledge added
```

## API Design

### BrainState API

```swift
// Create brain state
let brainState = try await brainStateManager.createBrainState(
    aiName: "CoderAI",
    role: .coder,
    initialState: SendableContent([
        "current_task": "Implement feature X",
        "progress": ["completed": 0, "total": 10]
    ])
)

// Load brain state
let brainState = try await brainStateManager.loadBrainState(aiName: "CoderAI")

// Save brain state
try await brainStateManager.saveBrainState(brainState)

// Update brain state
try await brainStateManager.updateBrainState(
    aiName: "CoderAI",
    key: "current_task",
    value: SendableContent("Implement feature Y")
)

// Get brain state value
let currentTask = try await brainStateManager.getBrainStateValue(
    aiName: "CoderAI",
    key: "current_task"
)

// Delete brain state
try await brainStateManager.deleteBrainState(aiName: "CoderAI")

// List brain states
let aiNames = try await brainStateManager.listBrainStates()
```

### MessageCache API

```swift
// Send message
let message = Message(
    id: UUID().uuidString,
    from: "CoderAI",
    to: "OverseerAI",
    timestamp: ISO8601DateFormatter().string(from: Date()),
    content: SendableContent([
        "type": "task",
        "task_id": "task-001",
        "description": "Implement new feature"
    ]),
    status: .unread,
    priority: .normal
)
try await MessageCacheManager.sendMessage(message)

// Receive messages (unread only)
let messages = try await MessageCacheManager.receiveMessages(for: "OverseerAI", unreadOnly: true)

// Receive all messages
let allMessages = try await MessageCacheManager.receiveMessages(for: "OverseerAI", unreadOnly: false)

// Mark message as read
try await MessageCacheManager.markAsRead(messageId)

// Mark message as processed
try await MessageCacheManager.markAsProcessed(messageId)

// Cleanup old messages
let deletedCount = try await MessageCacheManager.cleanupOldMessages(olderThan: 30)

// Cleanup by condition
let condition = MessageCondition(
    type: .status(.processed),
    description: "Delete processed messages"
)
let deletedCount = try await MessageCacheManager.cleanupByCondition(condition)
```

### KnowledgeBase API

```swift
// Add knowledge
try await knowledgeBase.addKnowledge(
    category: "best-practices",
    key: "swift",
    value: SendableContent([
        "title": "Swift Best Practices",
        "content": "Use Sendable protocol for thread safety"
    ]),
    metadata: SendableContent([
        "author": "CoderAI",
        "source": "documentation"
    ])
)

// Get knowledge
let knowledge = try await knowledgeBase.getKnowledge(category: "best-practices", key: "swift")

// Update knowledge
try await knowledgeBase.updateKnowledge(
    category: "best-practices",
    key: "swift",
    value: SendableContent([
        "title": "Swift Best Practices",
        "content": "Updated content"
    ])
)

// Delete knowledge
try await knowledgeBase.deleteKnowledge(category: "best-practices", key: "swift")

// List categories
let categories = try await knowledgeBase.listCategories()

// List keys in category
let keys = try await knowledgeBase.listKeys(category: "best-practices")

// Search knowledge
let results = try await knowledgeBase.searchKnowledge(category: "best-practices", query: "Sendable")
```

## Performance Considerations

### Database Indexes

```sql
-- BrainState indexes
CREATE INDEX idx_brain_states_ai_name ON brain_states(ai_name);
CREATE INDEX idx_brain_states_timestamp ON brain_states(timestamp);

-- MessageCache indexes
CREATE INDEX idx_message_history_to_ai ON message_history(to_ai);
CREATE INDEX idx_message_history_from_ai ON message_history(from_ai);
CREATE INDEX idx_message_history_status ON message_history(status);
CREATE INDEX idx_message_history_timestamp ON message_history(timestamp);
CREATE INDEX idx_message_history_created_at ON message_history(created_at);
CREATE INDEX idx_message_history_to_status ON message_history(to_ai, status);
CREATE INDEX idx_message_history_to_timestamp ON message_history(to_ai, timestamp DESC);

-- KnowledgeBase indexes
CREATE INDEX idx_knowledge_items_category ON knowledge_items(category);
CREATE INDEX idx_knowledge_items_timestamp ON knowledge_items(timestamp);
```

### Query Optimization

```swift
// Use indexes for filtering
let messages = try await MessageRecord.query(on: database)
    .filter(\.$toAI == aiName)  // Uses idx_message_history_to_ai
    .filter(\.$status == .unread.rawValue)  // Uses idx_message_history_status
    .sort(\.$timestamp, .descending)  // Uses idx_message_history_to_timestamp
    .all()

// Limit results for pagination
let messages = try await MessageRecord.query(on: database)
    .filter(\.$toAI == aiName)
    .sort(\.$timestamp, .descending)
    .limit(50)
    .all()
```

### Caching Strategy

```swift
public actor MessageCache {
    private var cache: [String: [Message]] = [:]
    private var lastUpdated: [String: Date] = [:]
    private let cacheTimeout: TimeInterval = 60 // 1 minute
    
    public func getMessages(for aiName: String) -> [Message]? {
        guard let lastUpdate = lastUpdated[aiName],
              Date().timeIntervalSince(lastUpdate) < cacheTimeout else {
            return nil
        }
        return cache[aiName]
    }
    
    public func setMessages(_ messages: [Message], for aiName: String) {
        cache[aiName] = messages
        lastUpdated[aiName] = Date()
    }
    
    public func invalidate(for aiName: String) {
        cache.removeValue(forKey: aiName)
        lastUpdated.removeValue(forKey: aiName)
    }
}
```

## Security Considerations

### Data Validation

```swift
// Validate message structure
func validateMessage(_ message: Message) throws {
    guard !message.from.isEmpty else {
        throw CommunicationError.invalidMessage("from field is empty")
    }
    guard !message.to.isEmpty else {
        throw CommunicationError.invalidMessage("to field is empty")
    }
    guard !message.id.isEmpty else {
        throw CommunicationError.invalidMessage("id field is empty")
    }
}

// Validate BrainState structure
func validateBrainState(_ brainState: BrainState) throws {
    guard !brainState.aiName.isEmpty else {
        throw BrainStateError.invalidBrainState("aiName is empty")
    }
    guard brainState.state.toAnyDict().keys.allSatisfy({ key in
        ["current_task", "progress", "context", "working_memory"].contains(key)
    }) else {
        throw BrainStateError.invalidBrainState("BrainState contains invalid keys")
    }
}
```

### Access Control

```swift
// Check AI permissions
func checkPermission(aiName: String, action: String) throws {
    let brainState = try await brainStateManager.loadBrainState(aiName: aiName)
    
    switch brainState?.role {
    case .coder:
        guard action != "delete_all" else {
            throw PermissionError.insufficientPermission("CoderAI cannot delete all data")
        }
    case .overseer:
        break
    case .none:
        throw PermissionError.unauthorizedAI("AI not found")
    }
}
```

## Testing Strategy

### Unit Tests

```swift
// Test BrainState operations
func testBrainStateCreate() async throws {
    let brainState = try await brainStateManager.createBrainState(
        aiName: "TestAI",
        role: .coder
    )
    XCTAssertEqual(brainState.aiName, "TestAI")
    XCTAssertEqual(brainState.role, .coder)
}

// Test MessageCache operations
func testMessageSend() async throws {
    let message = Message(
        id: UUID().uuidString,
        from: "CoderAI",
        to: "OverseerAI",
        timestamp: ISO8601DateFormatter().string(from: Date()),
        content: SendableContent(["type": "test"]),
        status: .unread,
        priority: .normal
    )
    try await MessageCacheManager.sendMessage(message)
    
    let messages = try await MessageCacheManager.receiveMessages(for: "OverseerAI")
    XCTAssertEqual(messages.count, 1)
}

// Test KnowledgeBase operations
func testKnowledgeAdd() async throws {
    try await knowledgeBase.addKnowledge(
        category: "test",
        key: "test_key",
        value: SendableContent(["value": "test"])
    )
    
    let knowledge = try await knowledgeBase.getKnowledge(category: "test", key: "test_key")
    XCTAssertNotNil(knowledge)
}
```

### Integration Tests

```swift
// Test message flow
func testMessageFlow() async throws {
    let message = Message(
        id: UUID().uuidString,
        from: "CoderAI",
        to: "OverseerAI",
        timestamp: ISO8601DateFormatter().string(from: Date()),
        content: SendableContent(["type": "task"]),
        status: .unread,
        priority: .normal
    )
    
    try await communication.sendMessage(message, to: "OverseerAI")
    
    let messages = try await communication.receiveMessages(for: "OverseerAI")
    XCTAssertEqual(messages.count, 1)
    
    try await communication.markAsRead(message.id, for: "OverseerAI")
    
    let unreadMessages = try await communication.receiveMessages(for: "OverseerAI")
    XCTAssertEqual(unreadMessages.count, 0)
}
```

## Monitoring and Logging

### Logging Strategy

```swift
// Use structured logging
GitBrainLogger.info("Message sent", [
    "message_id": message.id,
    "from": message.from,
    "to": message.to,
    "priority": message.priority.rawValue
])

// Log performance metrics
let startTime = Date()
try await MessageCacheManager.sendMessage(message)
let duration = Date().timeIntervalSince(startTime)
GitBrainLogger.info("Message sent successfully", [
    "duration_ms": duration * 1000,
    "target": "< 1ms"
])
```

### Metrics Collection

```swift
// Collect performance metrics
public actor MetricsCollector {
    private var messageSendTimes: [TimeInterval] = []
    private var messageReceiveTimes: [TimeInterval] = []
    
    public func recordMessageSend(duration: TimeInterval) {
        messageSendTimes.append(duration)
    }
    
    public func recordMessageReceive(duration: TimeInterval) {
        messageReceiveTimes.append(duration)
    }
    
    public func getAverageSendTime() -> TimeInterval {
        guard !messageSendTimes.isEmpty else { return 0 }
        return messageSendTimes.reduce(0, +) / Double(messageSendTimes.count)
    }
    
    public func getAverageReceiveTime() -> TimeInterval {
        guard !messageReceiveTimes.isEmpty else { return 0 }
        return messageReceiveTimes.reduce(0, +) / Double(messageReceiveTimes.count)
    }
}
```

## Summary

### Key Principles

1. **Clear Boundaries**: BrainState, MessageCache, and KnowledgeBase are completely separate systems
2. **No Pollution**: BrainState contains ONLY AI state, NO messages
3. **Separate Tables**: Each system has its own database table
4. **Clean Architecture**: Each system has its own manager, repository, and model
5. **Performance**: Sub-millisecond latency for all operations
6. **Scalability**: Database indexes and caching for performance
7. **Security**: Data validation and access control
8. **Monitoring**: Structured logging and metrics collection

### System Responsibilities

| System | Purpose | Data | Features |
|---------|---------|-------|-----------|
| **BrainState** | AI state management | current_task, progress, context, working_memory | Create, load, save, update, delete, backup, restore |
| **MessageCache** | Communication messages | message_id, from, to, timestamp, content, status, priority | Send, receive, mark as read/processed, cleanup |
| **KnowledgeBase** | Knowledge management | category, key, value, metadata | Add, get, update, delete, search, list |

### Success Criteria

- [ ] Clear boundaries between BrainState, MessageCache, and KnowledgeBase
- [ ] BrainState contains ONLY AI state (NO messages)
- [ ] MessageCache contains ONLY communication messages
- [ ] KnowledgeBase contains ONLY knowledge items
- [ ] Sub-millisecond latency for all operations
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Performance targets met

---

**Status:** Design Phase - Awaiting Discussion
**Author:** CoderAI
**Date:** 2026-02-14

**Please append your comments below this line:**
