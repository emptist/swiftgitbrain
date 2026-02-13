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
│  │  • type: MessageType                                  │  │
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

### MessageCache Tables

**IMPORTANT:** Each message type has its own table with specific fields for type safety and performance.

#### task_messages Table

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

#### code_messages Table

```sql
CREATE TABLE code_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    code TEXT NOT NULL,
    language VARCHAR(50) NOT NULL,
    files TEXT[],
    description TEXT,
    commit_hash VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_code_messages_to_ai ON code_messages(to_ai);
CREATE INDEX idx_code_messages_from_ai ON code_messages(from_ai);
CREATE INDEX idx_code_messages_status ON code_messages(status);
CREATE INDEX idx_code_messages_timestamp ON code_messages(timestamp);
CREATE INDEX idx_code_messages_task_id ON code_messages(task_id);
CREATE INDEX idx_code_messages_language ON code_messages(language);

-- Composite indexes
CREATE INDEX idx_code_messages_to_status ON code_messages(to_ai, status);
CREATE INDEX idx_code_messages_to_timestamp ON code_messages(to_ai, timestamp DESC);
CREATE INDEX idx_code_messages_to_task_id ON code_messages(to_ai, task_id);

-- Validators
-- language: 'swift', 'python', 'javascript', 'rust', 'go', 'java'
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### review_messages Table

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

#### feedback_messages Table

```sql
CREATE TABLE feedback_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(50),
    suggestions TEXT[],
    files TEXT[],
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_feedback_messages_to_ai ON feedback_messages(to_ai);
CREATE INDEX idx_feedback_messages_from_ai ON feedback_messages(from_ai);
CREATE INDEX idx_feedback_messages_status ON feedback_messages(status);
CREATE INDEX idx_feedback_messages_timestamp ON feedback_messages(timestamp);
CREATE INDEX idx_feedback_messages_task_id ON feedback_messages(task_id);
CREATE INDEX idx_feedback_messages_severity ON feedback_messages(severity);

-- Composite indexes
CREATE INDEX idx_feedback_messages_to_status ON feedback_messages(to_ai, status);
CREATE INDEX idx_feedback_messages_to_timestamp ON feedback_messages(to_ai, timestamp DESC);
CREATE INDEX idx_feedback_messages_to_task_id ON feedback_messages(to_ai, task_id);

-- Validators
-- severity: 'critical', 'major', 'minor', 'info'
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### approval_messages Table

```sql
CREATE TABLE approval_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    approver VARCHAR(255) NOT NULL,
    approved_at TIMESTAMP,
    commit_hash VARCHAR(255),
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_approval_messages_to_ai ON approval_messages(to_ai);
CREATE INDEX idx_approval_messages_from_ai ON approval_messages(from_ai);
CREATE INDEX idx_approval_messages_status ON approval_messages(status);
CREATE INDEX idx_approval_messages_timestamp ON approval_messages(timestamp);
CREATE INDEX idx_approval_messages_task_id ON approval_messages(task_id);
CREATE INDEX idx_approval_messages_approver ON approval_messages(approver);

-- Composite indexes
CREATE INDEX idx_approval_messages_to_status ON approval_messages(to_ai, status);
CREATE INDEX idx_approval_messages_to_timestamp ON approval_messages(to_ai, timestamp DESC);
CREATE INDEX idx_approval_messages_to_task_id ON approval_messages(to_ai, task_id);

-- Validators
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### rejection_messages Table

```sql
CREATE TABLE rejection_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    rejecter VARCHAR(255) NOT NULL,
    reason TEXT NOT NULL,
    rejected_at TIMESTAMP,
    feedback TEXT,
    suggestions TEXT[],
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_rejection_messages_to_ai ON rejection_messages(to_ai);
CREATE INDEX idx_rejection_messages_from_ai ON rejection_messages(from_ai);
CREATE INDEX idx_rejection_messages_status ON rejection_messages(status);
CREATE INDEX idx_rejection_messages_timestamp ON rejection_messages(timestamp);
CREATE INDEX idx_rejection_messages_task_id ON rejection_messages(task_id);
CREATE INDEX idx_rejection_messages_rejecter ON rejection_messages(rejecter);

-- Composite indexes
CREATE INDEX idx_rejection_messages_to_status ON rejection_messages(to_ai, status);
CREATE INDEX idx_rejection_messages_to_timestamp ON rejection_messages(to_ai, timestamp DESC);
CREATE INDEX idx_rejection_messages_to_task_id ON rejection_messages(to_ai, task_id);

-- Validators
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### status_messages Table

```sql
CREATE TABLE status_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    message TEXT,
    progress INTEGER,
    current_task JSONB,
    status_timestamp TIMESTAMP,
    message_status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_status_messages_to_ai ON status_messages(to_ai);
CREATE INDEX idx_status_messages_from_ai ON status_messages(from_ai);
CREATE INDEX idx_status_messages_status ON status_messages(status);
CREATE INDEX idx_status_messages_timestamp ON status_messages(timestamp);
CREATE INDEX idx_status_messages_status_value ON status_messages(status);

-- Composite indexes
CREATE INDEX idx_status_messages_to_status ON status_messages(to_ai, message_status);
CREATE INDEX idx_status_messages_to_timestamp ON status_messages(to_ai, timestamp DESC);

-- Validators
-- status: 'idle', 'working', 'waiting', 'completed', 'error'
-- progress: 0-100
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- message_status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### heartbeat_messages Table

```sql
CREATE TABLE heartbeat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    ai_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    heartbeat_timestamp TIMESTAMP,
    status VARCHAR(50),
    capabilities TEXT[],
    message_status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_heartbeat_messages_to_ai ON heartbeat_messages(to_ai);
CREATE INDEX idx_heartbeat_messages_from_ai ON heartbeat_messages(from_ai);
CREATE INDEX idx_heartbeat_messages_status ON heartbeat_messages(message_status);
CREATE INDEX idx_heartbeat_messages_timestamp ON heartbeat_messages(timestamp);
CREATE INDEX idx_heartbeat_messages_ai_name ON heartbeat_messages(ai_name);
CREATE INDEX idx_heartbeat_messages_role ON heartbeat_messages(role);

-- Composite indexes
CREATE INDEX idx_heartbeat_messages_to_status ON heartbeat_messages(to_ai, message_status);
CREATE INDEX idx_heartbeat_messages_to_timestamp ON heartbeat_messages(to_ai, timestamp DESC);

-- Validators
-- role: 'coder', 'overseer'
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- message_status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### score_request_messages Table

```sql
CREATE TABLE score_request_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    requester VARCHAR(50) NOT NULL,
    target_ai VARCHAR(50) NOT NULL,
    requested_score INTEGER NOT NULL,
    quality_justification TEXT NOT NULL,
    message_status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_score_request_messages_to_ai ON score_request_messages(to_ai);
CREATE INDEX idx_score_request_messages_from_ai ON score_request_messages(from_ai);
CREATE INDEX idx_score_request_messages_status ON score_request_messages(message_status);
CREATE INDEX idx_score_request_messages_timestamp ON score_request_messages(timestamp);
CREATE INDEX idx_score_request_messages_task_id ON score_request_messages(task_id);
CREATE INDEX idx_score_request_messages_requester ON score_request_messages(requester);
CREATE INDEX idx_score_request_messages_target_ai ON score_request_messages(target_ai);

-- Composite indexes
CREATE INDEX idx_score_request_messages_to_status ON score_request_messages(to_ai, message_status);
CREATE INDEX idx_score_request_messages_to_timestamp ON score_request_messages(to_ai, timestamp DESC);
CREATE INDEX idx_score_request_messages_to_task_id ON score_request_messages(to_ai, task_id);

-- Validators
-- requester: 'coder', 'overseer'
-- target_ai: 'coder', 'overseer'
-- requested_score: positive integer
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- message_status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### score_award_messages Table

```sql
CREATE TABLE score_award_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    request_id INTEGER NOT NULL,
    awarder VARCHAR(50) NOT NULL,
    awarded_score INTEGER NOT NULL,
    reason TEXT NOT NULL,
    message_status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_score_award_messages_to_ai ON score_award_messages(to_ai);
CREATE INDEX idx_score_award_messages_from_ai ON score_award_messages(from_ai);
CREATE INDEX idx_score_award_messages_status ON score_award_messages(message_status);
CREATE INDEX idx_score_award_messages_timestamp ON score_award_messages(timestamp);
CREATE INDEX idx_score_award_messages_request_id ON score_award_messages(request_id);
CREATE INDEX idx_score_award_messages_awarder ON score_award_messages(awarder);

-- Composite indexes
CREATE INDEX idx_score_award_messages_to_status ON score_award_messages(to_ai, message_status);
CREATE INDEX idx_score_award_messages_to_timestamp ON score_award_messages(to_ai, timestamp DESC);
CREATE INDEX idx_score_award_messages_to_request_id ON score_award_messages(to_ai, request_id);

-- Validators
-- awarder: 'coder', 'overseer'
-- awarded_score: positive integer
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- message_status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

#### score_reject_messages Table

```sql
CREATE TABLE score_reject_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    request_id INTEGER NOT NULL,
    rejecter VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    message_status VARCHAR(50) NOT NULL DEFAULT 'unread',
    message_priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_score_reject_messages_to_ai ON score_reject_messages(to_ai);
CREATE INDEX idx_score_reject_messages_from_ai ON score_reject_messages(from_ai);
CREATE INDEX idx_score_reject_messages_status ON score_reject_messages(message_status);
CREATE INDEX idx_score_reject_messages_timestamp ON score_reject_messages(timestamp);
CREATE INDEX idx_score_reject_messages_request_id ON score_reject_messages(request_id);
CREATE INDEX idx_score_reject_messages_rejecter ON score_reject_messages(rejecter);

-- Composite indexes
CREATE INDEX idx_score_reject_messages_to_status ON score_reject_messages(to_ai, message_status);
CREATE INDEX idx_score_reject_messages_to_timestamp ON score_reject_messages(to_ai, timestamp DESC);
CREATE INDEX idx_score_reject_messages_to_request_id ON score_reject_messages(to_ai, request_id);

-- Validators
-- rejecter: 'coder', 'overseer'
-- message_priority: 1 (critical), 2 (high), 3 (normal), 4 (low)
-- message_status: 'unread', 'read', 'processed', 'sent', 'delivered'
```

**IMPORTANT: All message tables are TEMPORARY cache!**
- Messages are archived to disk after processing
- Archive location: GitBrain/Memory/Archive/
- Common fields across all tables:
  - id: UUID PRIMARY KEY
  - message_id: UUID UNIQUE
  - from_ai: VARCHAR(255) NOT NULL
  - to_ai: VARCHAR(255) NOT NULL
  - timestamp: TIMESTAMP NOT NULL
  - message_status: VARCHAR(50) NOT NULL DEFAULT 'unread'
  - message_priority: INTEGER NOT NULL DEFAULT 3
  - created_at: TIMESTAMP NOT NULL DEFAULT NOW()
  - updated_at: TIMESTAMP NOT NULL DEFAULT NOW()

**Message Status Values:**
- 'unread', 'read', 'processed', 'sent', 'delivered'

**Message Priority Values:**
- 1 (critical), 2 (high), 3 (normal), 4 (low)

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
├── Message Models (11 types)
│   ├── TaskMessage: Codable, Sendable
│   ├── CodeMessage: Codable, Sendable
│   ├── ReviewMessage: Codable, Sendable
│   ├── FeedbackMessage: Codable, Sendable
│   ├── ApprovalMessage: Codable, Sendable
│   ├── RejectionMessage: Codable, Sendable
│   ├── StatusMessage: Codable, Sendable
│   ├── HeartbeatMessage: Codable, Sendable
│   ├── ScoreRequestMessage: Codable, Sendable
│   ├── ScoreAwardMessage: Codable, Sendable
│   └── ScoreRejectMessage: Codable, Sendable
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

#### Message Models

##### TaskMessage Model

```swift
public struct TaskMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let description: String
    public let taskType: String
    public let priority: Int
    public let files: [String]?
    public let deadline: String?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        description: String,
        taskType: String,
        priority: Int,
        files: [String]? = nil,
        deadline: String? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.description = description
        self.taskType = taskType
        self.priority = priority
        self.files = files
        self.deadline = deadline
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### CodeMessage Model

```swift
public struct CodeMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let code: String
    public let language: String
    public let files: [String]?
    public let description: String?
    public let commitHash: String?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        code: String,
        language: String,
        files: [String]? = nil,
        description: String? = nil,
        commitHash: String? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.code = code
        self.language = language
        self.files = files
        self.description = description
        self.commitHash = commitHash
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### ReviewMessage Model

```swift
public struct ReviewMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let approved: Bool
    public let reviewer: String
    public let comments: [[String: Any]]?
    public let feedback: String?
    public let filesReviewed: [String]?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        approved: Bool,
        reviewer: String,
        comments: [[String: Any]]? = nil,
        feedback: String? = nil,
        filesReviewed: [String]? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.approved = approved
        self.reviewer = reviewer
        self.comments = comments
        self.feedback = feedback
        self.filesReviewed = filesReviewed
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### FeedbackMessage Model

```swift
public struct FeedbackMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let message: String
    public let severity: String?
    public let suggestions: [String]?
    public let files: [String]?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        message: String,
        severity: String? = nil,
        suggestions: [String]? = nil,
        files: [String]? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.message = message
        self.severity = severity
        self.suggestions = suggestions
        self.files = files
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### ApprovalMessage Model

```swift
public struct ApprovalMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let approver: String
    public let approvedAt: String?
    public let commitHash: String?
    public let notes: String?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        approver: String,
        approvedAt: String? = nil,
        commitHash: String? = nil,
        notes: String? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.approver = approver
        self.approvedAt = approvedAt
        self.commitHash = commitHash
        self.notes = notes
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### RejectionMessage Model

```swift
public struct RejectionMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let rejecter: String
    public let reason: String
    public let rejectedAt: String?
    public let feedback: String?
    public let suggestions: [String]?
    public var status: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        rejecter: String,
        reason: String,
        rejectedAt: String? = nil,
        feedback: String? = nil,
        suggestions: [String]? = nil,
        status: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.rejecter = rejecter
        self.reason = reason
        self.rejectedAt = rejectedAt
        self.feedback = feedback
        self.suggestions = suggestions
        self.status = status
        self.messagePriority = messagePriority
    }
}
```

##### StatusMessage Model

```swift
public struct StatusMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let status: String
    public let message: String?
    public let progress: Int?
    public let currentTask: [String: Any]?
    public let statusTimestamp: String?
    public var messageStatus: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        status: String,
        message: String? = nil,
        progress: Int? = nil,
        currentTask: [String: Any]? = nil,
        statusTimestamp: String? = nil,
        messageStatus: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.status = status
        self.message = message
        self.progress = progress
        self.currentTask = currentTask
        self.statusTimestamp = statusTimestamp
        self.messageStatus = messageStatus
        self.messagePriority = messagePriority
    }
}
```

##### HeartbeatMessage Model

```swift
public struct HeartbeatMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let aiName: String
    public let role: String
    public let heartbeatTimestamp: String?
    public let status: String?
    public let capabilities: [String]?
    public var messageStatus: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        aiName: String,
        role: String,
        heartbeatTimestamp: String? = nil,
        status: String? = nil,
        capabilities: [String]? = nil,
        messageStatus: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.aiName = aiName
        self.role = role
        self.heartbeatTimestamp = heartbeatTimestamp
        self.status = status
        self.capabilities = capabilities
        self.messageStatus = messageStatus
        self.messagePriority = messagePriority
    }
}
```

##### ScoreRequestMessage Model

```swift
public struct ScoreRequestMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let taskId: String
    public let requester: String
    public let targetAi: String
    public let requestedScore: Int
    public let qualityJustification: String
    public var messageStatus: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        taskId: String,
        requester: String,
        targetAi: String,
        requestedScore: Int,
        qualityJustification: String,
        messageStatus: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.taskId = taskId
        self.requester = requester
        self.targetAi = targetAi
        self.requestedScore = requestedScore
        self.qualityJustification = qualityJustification
        self.messageStatus = messageStatus
        self.messagePriority = messagePriority
    }
}
```

##### ScoreAwardMessage Model

```swift
public struct ScoreAwardMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let requestId: Int
    public let awarder: String
    public let awardedScore: Int
    public let reason: String
    public var messageStatus: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        requestId: Int,
        awarder: String,
        awardedScore: Int,
        reason: String,
        messageStatus: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.requestId = requestId
        self.awarder = awarder
        self.awardedScore = awardedScore
        self.reason = reason
        self.messageStatus = messageStatus
        self.messagePriority = messagePriority
    }
}
```

##### ScoreRejectMessage Model

```swift
public struct ScoreRejectMessage: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let requestId: Int
    public let rejecter: String
    public let reason: String
    public var messageStatus: MessageStatus
    public let messagePriority: MessagePriority
    
    public init(
        id: String,
        from: String,
        to: String,
        timestamp: String,
        requestId: Int,
        rejecter: String,
        reason: String,
        messageStatus: MessageStatus = .unread,
        messagePriority: MessagePriority = .normal
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.requestId = requestId
        self.rejecter = rejecter
        self.reason = reason
        self.messageStatus = messageStatus
        self.messagePriority = messagePriority
    }
}
```

#### Message Enums

```swift
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

#### Message Types

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

#### Complete Message Type List

##### 1. Task Message

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
let messageType = MessageType.task
let message = Message(
    id: UUID().uuidString,
    from: "CoderAI",
    to: "OverseerAI",
    timestamp: ISO8601DateFormatter().string(from: Date()),
    content: SendableContent([
        "type": messageType.rawValue,
        "task_id": "task-001",
        "description": "Implement new feature",
        "task_type": "coding",
        "priority": 5,
        "files": ["Sources/Feature.swift"],
        "deadline": "2026-02-15T12:00:00Z"
    ])
)
```

##### 2. Code Message

**Type:** `MessageType.code` (Swift enum)

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

##### 3. Review Message

**Type:** `MessageType.review` (Swift enum)

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

##### 4. Feedback Message

**Type:** `MessageType.feedback` (Swift enum)

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

##### 5. Approval Message

**Type:** `MessageType.approval` (Swift enum)

**Purpose:** Task approval notifications

**Required Fields:**
- `task_id`: String - Related task identifier
- `approver`: String - Approver name

**Optional Fields:**
- `approved_at`: String - Approval timestamp
- `commit_hash`: String - Git commit hash
- `notes`: String - Approval notes

##### 6. Rejection Message

**Type:** `MessageType.rejection` (Swift enum)

**Purpose:** Task rejection notifications

**Required Fields:**
- `task_id`: String - Related task identifier
- `rejecter`: String - Rejecter name
- `reason`: String - Rejection reason

**Optional Fields:**
- `rejected_at`: String - Rejection timestamp
- `feedback`: String - Detailed feedback
- `suggestions`: [String] - List of suggestions

##### 7. Status Message

**Type:** `MessageType.status` (Swift enum)

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

##### 8. Heartbeat Message

**Type:** `MessageType.heartbeat` (Swift enum)

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

##### 9. Score Request Message

**Type:** `score_request` (String in validator)

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

##### 10. Score Award Message

**Type:** `score_award` (String in validator)

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

##### 11. Score Reject Message

**Type:** `score_reject` (String in validator)

**Purpose:** Reject score request from another AI

**Required Fields:**
- `request_id`: Int - Related request ID
- `rejecter`: String - Rejecter name
- `reason`: String - Rejection reason

**Optional Fields:**
- None

**Validators:**
- `rejecter` must be one of: `coder`, `overseer`

#### Message Type Summary Table

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
