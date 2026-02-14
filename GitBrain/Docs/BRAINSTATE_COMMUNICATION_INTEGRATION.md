# BrainState-Based Communication Integration Design

> **⚠️ DEPRECATED - This document is archived for historical reference only.**
> 
> **Current Implementation:** Use `MessageCache` and `AIDaemon` for AI communication.
> 
> **See Also:**
> - [API.md](API.md) - Current API documentation
> - [CLI_TOOLS.md](CLI_TOOLS.md) - CLI commands for messaging
> - [KEEP_ALIVE_SYSTEM.md](KEEP_ALIVE_SYSTEM.md) - Keep-alive mechanisms

**Date:** 2026-02-13
**Phase:** Phase 1: Investigation
**Status:** ~~Design Complete~~ **Superseded by MessageCache**

## Executive Summary

This document describes how to integrate BrainState infrastructure for inter-AI communication, replacing the file-based messaging system with database-backed real-time communication.

## Current State Analysis

### BrainState Infrastructure (Existing)

**Components:**
- `BrainStateManager` - Manages persistent AI brainstate
- `FluentBrainStateRepository` - PostgreSQL implementation
- `BrainStateModel` - Database model (ai_name, role, state, timestamp)

**Capabilities:**
- `createBrainState()` - Create new brainstate for an AI
- `loadBrainState()` - Load existing brainstate
- `saveBrainState()` - Update brainstate with new data
- `updateBrainState()` - Update specific key in brainstate
- `getBrainStateValue()` - Get specific value from brainstate
- `deleteBrainState()` - Delete brainstate
- `listBrainStates()` - List all brainstates
- `backupBrainState()` / `restoreBrainState()` - Backup/restore

**Key Insight:** BrainState's `state` field is a JSON object that can store any data, including messages, current task, context, communication history, and pending messages.

### File-Based Messaging System (To Be Replaced)

**Components:**
- `FileBasedCommunication` - File-based messaging
- Message files in `GitBrain/Memory/ToProcess/` (660+ files)
- Polling scripts (5+ minute intervals)

**Issues:**
- 5+ minute polling delay
- No real-time notifications
- 660+ message files cluttering file system
- No transactional safety

## Integration Design

### Architecture

**BrainState-Based Communication:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    PostgreSQL Database                        │
│                                                           │
│  ┌──────────────┐  ┌──────────────┐             │
│  │ BrainState   │  │ BrainState   │             │
│  │ (Creator)    │  │ (Monitor) │             │
│  └──────────────┘  └──────────────┘             │
│         │                  │                        │
│         ▼                  ▼                        │
│  ┌──────────────────────────────────┐                │
│  │  BrainState-Based Communication  │                │
│  └──────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### Message Flow

**Sending a Message:**

1. Sender creates message object
2. Sender loads recipient's BrainState
3. Sender appends message to recipient's message queue in BrainState
4. Sender saves recipient's BrainState
5. Database triggers notification (via LISTEN/NOTIFY)
6. Recipient receives notification and loads BrainState
7. Recipient processes new messages

**Receiving Messages:**

1. AI loads its own BrainState
2. AI checks for new messages in message queue
3. AI processes each message
4. AI updates its BrainState with processed status
5. AI saves its BrainState

### BrainState Structure

**BrainState for AI Communication:**

```json
{
  "aiName": "Creator",
  "role": "creator",
  "version": "1.0.0",
  "lastUpdated": "2026-02-13T22:45:00Z",
  "state": {
    "messages": {
      "inbox": [
        {
          "id": "msg_001",
          "from": "Monitor",
          "to": "Creator",
          "timestamp": "2026-02-13T22:30:00Z",
          "content": {
            "type": "status_update",
            "message": "Reviewing code..."
          },
          "status": "unread",
          "priority": "normal"
        }
      ],
      "outbox": [
        {
          "id": "msg_002",
          "from": "Creator",
          "to": "Monitor",
          "timestamp": "2026-02-13T22:35:00Z",
          "content": {
            "type": "task_update",
            "message": "Task completed"
          },
          "status": "sent",
          "priority": "normal"
        }
      ]
    },
    "currentTask": {
      "id": "task_001",
      "description": "Implement BrainState communication",
      "status": "in_progress",
      "progress": 50
    },
    "context": {
      "session": "2026-02-13",
      "branch": "feature/migration-v2",
      "lastActivity": "2026-02-13T22:45:00Z"
    }
  }
}
```

### Message Structure

**Message Object:**

```swift
struct Message: Codable, Sendable {
    let id: String
    let from: String
    let to: String
    let timestamp: String
    let content: SendableContent
    var status: MessageStatus
    let priority: MessagePriority
}

enum MessageStatus: String, Codable {
    case unread
    case read
    case processed
    case sent
    case delivered
}

enum MessagePriority: Int, Codable {
    case critical = 1
    case high = 2
    case normal = 3
    case low = 4
}
```

## Implementation Plan

### Phase 1: BrainState Communication Layer

**Component: BrainStateCommunication**

```swift
public actor BrainStateCommunication: @unchecked Sendable {
    private let brainStateManager: BrainStateManager
    private let database: Database
    
    public init(brainStateManager: BrainStateManager, database: Database) {
        self.brainStateManager = brainStateManager
        self.database = database
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        GitBrainLogger.debug("Sending message to \(recipient)")
        
        // Load recipient's BrainState
        guard let recipientState = try await brainStateManager.loadBrainState(aiName: recipient) else {
            throw CommunicationError.recipientNotFound
        }
        
        // Add message to recipient's inbox
        var state = recipientState.state.toAnyDict()
        if var inbox = state["messages"] as? [String: Any],
           var messages = inbox["inbox"] as? [[String: Any]] ?? [] {
            messages.append(message.toDict())
            inbox["inbox"] = messages
        } else {
            state["messages"] = ["inbox": [message.toDict()]]
        }
        
        // Update recipient's BrainState
        let updatedState = SendableContent(state)
        try await brainStateManager.saveBrainState(BrainState(
            aiName: recipient,
            role: recipientState.role,
            version: recipientState.version,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: updatedState
        ))
        
        // Send notification via PostgreSQL LISTEN/NOTIFY
        try await sendNotification(to: recipient, messageId: message.id)
        
        GitBrainLogger.info("Message sent to \(recipient): \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        GitBrainLogger.debug("Receiving messages for \(aiName)")
        
        // Load AI's BrainState
        guard let state = try await brainStateManager.loadBrainState(aiName: aiName) else {
            return []
        }
        
        // Get inbox messages
        guard let messages = state.state.toAnyDict()["messages"] as? [String: Any],
              let inbox = messages["inbox"] as? [[String: Any]] else {
            return []
        }
        
        // Filter unread messages
        let unreadMessages = inbox.compactMap { msgDict -> Message? in
            guard let msg = msgDict as? [String: Any],
                  let status = msg["status"] as? String,
                  status == "unread" else {
                return nil
            }
            return Message(from: msg)
        }
        
        return unreadMessages
    }
    
    public func markAsRead(_ messageId: String, for aiName: String) async throws {
        GitBrainLogger.debug("Marking message as read: \(messageId)")
        
        guard let state = try await brainStateManager.loadBrainState(aiName: aiName) else {
            throw CommunicationError.brainStateNotFound
        }
        
        var stateDict = state.state.toAnyDict()
        if var messages = stateDict["messages"] as? [String: Any],
           var inbox = messages["inbox"] as? [[String: Any]] {
            for index in inbox.indices {
                if inbox[index]["id"] as? String == messageId {
                    inbox[index]["status"] = "read"
                    break
                }
            }
            messages["inbox"] = inbox
            stateDict["messages"] = messages
        }
        
        let updatedState = SendableContent(stateDict)
        try await brainStateManager.saveBrainState(BrainState(
            aiName: aiName,
            role: state.role,
            version: state.version,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            state: updatedState
        ))
        
        GitBrainLogger.info("Message marked as read: \(messageId)")
    }
    
    private func sendNotification(to recipient: String, messageId: String) async throws {
        let sql = "NOTIFY messages_channel, '\(recipient)|\(messageId)'"
        try await database.raw(sql).run()
    }
}
```

### Phase 2: Database Schema Updates

**Add Notification Support:**

```sql
-- Add notification channel
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('messages_channel', NEW.ai_name || '|' || NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to brain_states table
CREATE TRIGGER brain_state_notification
AFTER INSERT OR UPDATE ON brain_states
FOR EACH ROW
EXECUTE FUNCTION notify_new_message();
```

### Phase 3: AI System Integration

**Update Creator:**

```swift
// Replace FileBasedCommunication with BrainStateCommunication
let brainStateManager = try await dbManager.createBrainStateManager()
let communication = BrainStateCommunication(
    brainStateManager: brainStateManager,
    database: dbManager.getDatabase()
)

// Send message to Monitor
let message = Message(
    id: UUID().uuidString,
    from: "Creator",
    to: "Monitor",
    timestamp: ISO8601DateFormatter().string(from: Date()),
    content: SendableContent(["type": "status", "message": "Working..."]),
    status: .sent,
    priority: .normal
)
try await communication.sendMessage(message, to: "Monitor")

// Receive messages
let messages = try await communication.receiveMessages(for: "Creator")
for message in messages {
    processMessage(message)
    try await communication.markAsRead(message.id, for: "Creator")
}
```

**Update Monitor:**

```swift
// Replace FileBasedCommunication with BrainStateCommunication
let brainStateManager = try await dbManager.createBrainStateManager()
let communication = BrainStateCommunication(
    brainStateManager: brainStateManager,
    database: dbManager.getDatabase()
)

// Send message to Creator
let message = Message(
    id: UUID().uuidString,
    from: "Monitor",
    to: "Creator",
    timestamp: ISO8601DateFormatter().string(from: Date()),
    content: SendableContent(["type": "guidance", "message": "Continue..."]),
    status: .sent,
    priority: .normal
)
try await communication.sendMessage(message, to: "Creator")

// Receive messages
let messages = try await communication.receiveMessages(for: "Monitor")
for message in messages {
    processMessage(message)
    try await communication.markAsRead(message.id, for: "Monitor")
}
```

### Phase 4: Real-Time Notification System

**Listen for Notifications:**

```swift
public actor NotificationListener {
    private let database: Database
    private var isListening = false
    
    public init(database: Database) {
        self.database = database
    }
    
    public func startListening(onMessage: @escaping (String, String) -> Void) async throws {
        guard !isListening else { return }
        isListening = true
        
        GitBrainLogger.info("Starting to listen for messages")
        
        let sql = "LISTEN messages_channel"
        try await database.raw(sql).run()
        
        // Listen for notifications
        while isListening {
            // PostgreSQL will notify when BrainState is updated
            // This provides sub-millisecond latency
            await Task.sleep(nanoseconds: 100_000_000) // 100ms check
        }
    }
    
    public func stopListening() {
        isListening = false
        GitBrainLogger.info("Stopped listening for messages")
    }
}
```

## Migration Plan

### Phase 1: Migrate Message Files

**Tasks:**
1. Read all message files from `GitBrain/Memory/ToProcess/`
2. Parse each message file
3. Create BrainState for Creator and Monitor if not exists
4. Add messages to appropriate inbox/outbox
5. Save BrainStates to database
6. Move processed files to `GitBrain/Memory/Processed/`

**Estimated Time:** 1-2 hours

### Phase 2: Update AI Systems

**Tasks:**
1. Replace `FileBasedCommunication` with `BrainStateCommunication`
2. Update message sending logic
3. Update message receiving logic
4. Add notification listening
5. Test with real messages

**Estimated Time:** 1 day

### Phase 3: Remove File-Based System

**Tasks:**
1. Deprecate `FileBasedCommunication`
2. Remove polling scripts
3. Clean up file-based messaging code
4. Update documentation

**Estimated Time:** 4 hours

## Performance Improvements

### Expected Latency

| Operation | Current | New | Improvement |
|-----------|---------|------|-------------|
| Message Delivery | 5+ minutes | Sub-millisecond | 300,000x |
| Notification Check | 5+ minutes | Sub-millisecond | 300,000x |
| Message Read | File I/O | Database query | 100x |
| Message Write | File I/O | Database query | 100x |

### Scalability

**Current:**
- File system limited by I/O
- No concurrent access
- Polling overhead

**New:**
- Database-backed, highly scalable
- Concurrent access supported
- Real-time notifications

## Testing Plan

### Unit Tests

1. Test `BrainStateCommunication.sendMessage()`
2. Test `BrainStateCommunication.receiveMessages()`
3. Test `BrainStateCommunication.markAsRead()`
4. Test notification system
5. Test concurrent access

### Integration Tests

1. Test Creator → Monitor communication
2. Test Monitor → Creator communication
3. Test message ordering
4. Test message priority
5. Test real-time notifications

### Performance Tests

1. Measure message delivery latency
2. Measure notification latency
3. Test concurrent messaging
4. Compare with file-based system

## Next Steps

1. **Review this design** with Monitor
2. **Get approval** for implementation
3. **Implement Phase 1:** BrainState Communication Layer
4. **Implement Phase 2:** Database Schema Updates
5. **Implement Phase 3:** AI System Integration
6. **Implement Phase 4:** Real-Time Notification System
7. **Migrate message files** from file system to database
8. **Remove file-based system** completely
9. **Test performance** improvements
10. **Update documentation** to reflect correct architecture

---

**Status:** Design Complete - Awaiting Monitor Approval
