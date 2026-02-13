# CORRECTED ARCHITECTURE: MessageCache vs MessageHistory

**Date:** 2026-02-14
**Status:** CORRECTED
**Author:** CoderAI

## Critical Correction

**User's Correction (CORRECT):**
> "you will not need a MessageHistory in database. what you need is a MessageCache table. it has only one role: to make messaging more efficient between AIs. So, a manual made message will never be able to get into the database, since it will only recieve function generated well typed good quallity messages. After the messages been marked has been dealt correctly with according to their types and closed, they will be moved to disk archieves."

## Correct Architecture

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

## System 1: BrainState (AI State Management)

**Purpose:** Manage AI state and context

**Table:** `brain_states`

**Data:**
- `ai_name`: AI identifier
- `role`: AI role (coder/overseer)
- `state`: JSON-encoded state containing:
  - `current_task`: String
  - `progress`: [String: Any]
  - `context`: [String: Any]
  - `working_memory`: [String: Any]

**❌ NOT in BrainState:**
- `messages`: NO!
- `inbox`: NO!
- `outbox`: NO!
- `communication_history`: NO!

**Manager:** `BrainStateManager`

## System 2: MessageCache (Temporary Messaging Cache)

**Purpose:** Make messaging more efficient between AIs (temporary cache only!)

**Table:** `message_cache`

**Data:**
- `message_id`: UUID
- `from_ai`: String
- `to_ai`: String
- `timestamp`: Timestamp
- `content`: JSONB (well-typed, function-generated)
- `status`: MessageStatus (pending, delivered, processed, closed)
- `priority`: MessagePriority

**Key Characteristics:**
- **Temporary cache** - NOT permanent history
- **Function-generated only** - NO manual messages
- **Well-typed** - Only Message model types
- **Good quality** - Validated by MessageValidator
- **Auto-cleanup** - Messages moved to disk archives after processing

**Manager:** `MessageCacheManager`

**Workflow:**
1. AI sends message via function (well-typed, good quality)
2. Message stored in `message_cache` table (temporary)
3. Receiving AI reads from `message_cache`
4. After message is dealt with and closed, moved to disk archives
5. `message_cache` table cleared

## System 3: KnowledgeBase (Knowledge Storage)

**Purpose:** Manage knowledge items

**Table:** `knowledge_items`

**Data:**
- `category`: String
- `key`: String
- `value`: JSONB
- `metadata`: JSONB

**Manager:** `KnowledgeBase`

**Features:**
- Add/Get/Update/Delete knowledge
- Search knowledge
- List categories and keys

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

## Database Schema

### message_cache Table

```sql
CREATE TABLE message_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL UNIQUE,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    content JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    priority INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_message_cache_to_ai ON message_cache(to_ai);
CREATE INDEX idx_message_cache_status ON message_cache(status);
CREATE INDEX idx_message_cache_timestamp ON message_cache(timestamp);

-- Trigger for auto-cleanup
CREATE OR REPLACE FUNCTION cleanup_closed_messages()
RETURNS TRIGGER AS $$
BEGIN
    -- Move closed messages to disk archive
    -- This would be implemented by MessageCacheManager
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_closed_messages
AFTER UPDATE ON message_cache
FOR EACH ROW
WHEN (NEW.status = 'closed')
EXECUTE FUNCTION cleanup_closed_messages();
```

### brain_states Table

```sql
CREATE TABLE brain_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ai_name VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    state JSONB NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    last_updated TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_brain_states_ai_name ON brain_states(ai_name);
```

### knowledge_items Table

```sql
CREATE TABLE knowledge_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(255) NOT NULL,
    key VARCHAR(255) NOT NULL,
    value JSONB NOT NULL,
    metadata JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_knowledge_items_category ON knowledge_items(category);
CREATE INDEX idx_knowledge_items_key ON knowledge_items(key);
CREATE UNIQUE INDEX idx_knowledge_items_category_key ON knowledge_items(category, key);
```

## MessageCache Manager

### Interface

```swift
public actor MessageCacheManager: @unchecked Sendable {
    private let database: Database
    private let messageCacheRepository: MessageCacheRepository
    
    public init(database: Database, repository: MessageCacheRepository)
    
    // Send message to cache (well-typed, function-generated only)
    public func sendMessage(_ message: Message) async throws
    
    // Receive unread messages from cache
    public func receiveMessages(for aiName: String) async throws -> [Message]
    
    // Mark message as delivered
    public func markAsDelivered(_ messageId: String) async throws
    
    // Mark message as processed
    public func markAsProcessed(_ messageId: String) async throws
    
    // Mark message as closed and move to disk archive
    public func closeMessage(_ messageId: String) async throws
    
    // Cleanup closed messages from cache
    public func cleanupCache() async throws
}
```

### Implementation

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
        
        // Validate message (well-typed, good quality)
        let validator = MessageValidator()
        try validator.validate(message: message.content.toAnyDict())
        
        // Store in message_cache (temporary)
        try await messageCacheRepository.save(message)
        
        // Notify recipient (via database trigger or notification)
        try await sendNotification(to: message.to, messageId: message.id)
        
        GitBrainLogger.info("Message sent to cache: \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        GitBrainLogger.debug("Receiving messages from cache for \(aiName)")
        
        // Get unread messages from cache
        let messages = try await messageCacheRepository.getUnreadMessages(for: aiName)
        
        // Mark as delivered
        for message in messages {
            try await markAsDelivered(message.id)
        }
        
        return messages
    }
    
    public func markAsDelivered(_ messageId: String) async throws {
        GitBrainLogger.debug("Marking message as delivered: \(messageId)")
        try await messageCacheRepository.updateStatus(messageId, to: .delivered)
    }
    
    public func markAsProcessed(_ messageId: String) async throws {
        GitBrainLogger.debug("Marking message as processed: \(messageId)")
        try await messageCacheRepository.updateStatus(messageId, to: .processed)
    }
    
    public func closeMessage(_ messageId: String) async throws {
        GitBrainLogger.debug("Closing message: \(messageId)")
        
        // Get message from cache
        guard let message = try await messageCacheRepository.getById(messageId) else {
            throw CommunicationError.messageNotFound
        }
        
        // Move to disk archive
        try await archiveToDisk(message)
        
        // Remove from cache
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
        
        // Remove closed messages from cache
        let deletedCount = try await messageCacheRepository.deleteClosedMessages()
        
        GitBrainLogger.info("Cache cleanup complete: \(deletedCount) messages removed")
    }
}
```

## Disk Archive Structure

```
GitBrain/Memory/Archive/
├── 2026-02-14T12:00:00Z_message-001.json
├── 2026-02-14T12:01:00Z_message-002.json
├── 2026-02-14T12:02:00Z_message-003.json
└── ...
```

## Message Types

### Function-Generated Messages (Well-Typed, Good Quality)

These messages are generated by Swift functions and validated by MessageValidator:

1. **task** - Task assignments
2. **code** - Code submissions
3. **review** - Code reviews
4. **feedback** - Feedback messages
5. **approval** - Task approvals
6. **rejection** - Task rejections
7. **status** - Status updates
8. **heartbeat** - Keep-alive messages
9. **score_request** - Score requests
10. **score_award** - Score awards
11. **score_reject** - Score rejections

### Manual Messages (NOT in Database)

These messages are NOT stored in database:

1. **Task assignments** - Created by OverseerAI (573 files)
2. **Analysis documents** - Created by OverseerAI
3. **Wakeup messages** - Created by keep-alive system (56 files)
4. **Invalid JSON** - Corrupted files (28 files)

These are archived to disk, NOT migrated to database.

## Handling the 658 Files

### Analysis

```
Total Files: 658

┌─────────────────────────────────────────────────────────────┐
│ File Type Distribution (CORRECTED)                        │
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

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/TaskAssignments/`
- **Do NOT migrate** to database (not function-generated)
- **Keep for reference** - May need to review

#### 2. Wakeup Messages (56 files)

**What They Are:**
- Keep-alive messages from keep-alive system
- Created by shell scripts

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

#### 4. Review Message (1 file)

**What They Are:**
- Valid message type
- Created by Swift Message model

**Handling:**
- **Archive to disk** - Move to `GitBrain/Memory/Archive/ValidMessages/`
- **Do NOT migrate** to database (already processed)
- **Keep for reference** - Test case for MessageCache

## Key Differences: MessageCache vs MessageHistory

### MessageCache (CORRECT)

**Purpose:** Temporary cache for efficient messaging

**Characteristics:**
- Temporary storage
- Function-generated only
- Well-typed messages
- Good quality messages
- Auto-cleanup
- Messages moved to disk archives after processing

**Database:** `message_cache` table

**Manager:** `MessageCacheManager`

**Workflow:**
1. Send message via function
2. Store in cache (temporary)
3. Read from cache
4. Process message
5. Close message
6. Move to disk archive
7. Remove from cache

### MessageHistory (WRONG)

**Purpose:** Permanent message history

**Characteristics:**
- Permanent storage
- All messages (including manual)
- Not well-typed
- Not good quality
- No auto-cleanup
- Messages stay in database forever

**Database:** `message_history` table

**Manager:** `MessageHistoryManager`

**Workflow:**
1. Send message
2. Store in history (permanent)
3. Read from history
4. Process message
5. Mark as read
6. Stay in history forever

## Success Criteria

- [ ] MessageCache table created (NOT MessageHistory)
- [ ] MessageCacheManager implemented
- [ ] MessageCacheRepository implemented
- [ ] Messages stored in cache (temporary)
- [ ] Messages moved to disk archives after processing
- [ ] Cache cleanup function working
- [ ] 658 files archived to disk (NOT migrated to database)
- [ ] Documentation updated (MessageCache vs MessageHistory)
- [ ] All tests pass

## Conclusion

**The correct architecture is MessageCache, NOT MessageHistory!**

**Key Points:**
1. MessageCache is temporary cache for efficient messaging
2. MessageCache stores function-generated, well-typed, good quality messages only
3. Manual messages NEVER get into database
4. After messages are processed and closed, they're moved to disk archives
5. MessageCache is cleared after archiving
6. The 658 files should be archived to disk, NOT migrated to database

---

**Status:** CORRECTED
**Author:** CoderAI
**Date:** 2026-02-14

**Please append your comments below this line:**
