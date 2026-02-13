# MessageHistory System - Detailed Migration Plan

**Date:** 2026-02-14
**Status:** Planning Phase - Awaiting Discussion and Approval
**Author:** CoderAI

## Executive Summary

This plan outlines the design and implementation of a **MessageHistory system** that maintains clear boundaries from BrainState and KnowledgeBase, ensuring clean architecture and preventing the BIG DANGER of polluting BrainState with message history.

## Problem Statement

### Current Issues

1. **BrainStateCommunication Pollutes BrainState**
   - Current implementation stores messages in BrainState
   - Violates clear boundary between BrainState and MessageHistory
   - BrainState should be for AI state only (current task, progress, context)

2. **658 Message Files in ToProcess**
   - Legacy file-based messaging system
   - Need to be archived (not migrated to database)
   - Should be git ignored

3. **No MessageHistory System**
   - No separate system for communication messages
   - No cleaning function for old messages
   - No clear boundary from BrainState

### The BIG DANGER

If not stopped, the system would create a **bigger mess**:
- ✗ Messages stored in BrainState (polluting BrainState)
- ✗ No clear boundaries between systems
- ✗ Architectural drift worse instead of fixed

## Architecture Design

### Clear System Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                    GitBrainSwift Systems                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         BrainState (AI State Only)                 │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  • current_task: String                            │   │
│  │  • progress: [String: Any]                        │   │
│  │  • context: [String: Any]                          │   │
│  │  • working_memory: [String: Any]                      │   │
│  │                                                       │   │
│  │  ❌ NO MESSAGES!                                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │      MessageHistory (Communication Only)               │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  • message_id: UUID                                │   │
│  │  • from: String                                      │   │
│  │  • to: String                                        │   │
│  │  • timestamp: String                                  │   │
│  │  • content: SendableContent                            │   │
│  │  • status: MessageStatus                               │   │
│  │  • priority: MessagePriority                            │   │
│  │                                                       │   │
│  │  ✅ Separate table in database                        │   │
│  │  ✅ Cleaning function (delete old messages)             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │      KnowledgeBase (Knowledge Only)                   │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  • category: String                                  │   │
│  │  • key: String                                       │   │
│  │  • value: SendableContent                             │   │
│  │  • metadata: SendableContent                           │   │
│  │                                                       │   │
│  │  ✅ Separate table in database                        │   │
│  │  ✅ Already implemented                              │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Database Schema

#### brain_states (Existing - Keep Clean)
```sql
CREATE TABLE brain_states (
    id SERIAL PRIMARY KEY,
    ai_name VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    state JSONB NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- BrainState.state should contain ONLY:
-- • current_task
-- • progress
-- • context
-- • working_memory

-- BrainState.state should NEVER contain:
-- ❌ messages
-- ❌ inbox
-- ❌ outbox
```

#### message_history (New - Create)
```sql
CREATE TABLE message_history (
    id UUID PRIMARY KEY,
    from_ai VARCHAR(255) NOT NULL,
    to_ai VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    content JSONB NOT NULL,
    status VARCHAR(50) NOT NULL,
    priority INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_message_history_to_ai ON message_history(to_ai);
CREATE INDEX idx_message_history_status ON message_history(status);
CREATE INDEX idx_message_history_timestamp ON message_history(timestamp);
```

#### knowledge_items (Existing - Keep Separate)
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
```

## MessageHistory System Design

### Components

#### 1. Message Model (Existing - Keep)
```swift
public struct Message: Codable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let timestamp: String
    public let content: SendableContent
    public var status: MessageStatus
    public let priority: MessagePriority
}
```

#### 2. MessageRepositoryProtocol (New - Create)
```swift
public protocol MessageRepositoryProtocol {
    func add(_ message: Message) async throws
    func get(messageId: String) async throws -> Message?
    func getUnread(for aiName: String) async throws -> [Message]
    func getAll(for aiName: String) async throws -> [Message]
    func updateStatus(messageId: String, status: MessageStatus) async throws -> Bool
    func delete(messageId: String) async throws -> Bool
    func deleteOldMessages(before date: Date) async throws -> Int
    func deleteByCondition(_ condition: MessageCondition) async throws -> Int
}
```

#### 3. MessageRepository (New - Create)
```swift
public actor MessageRepository: MessageRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(_ message: Message) async throws {
        // Implementation with Fluent
    }
    
    public func get(messageId: String) async throws -> Message? {
        // Implementation with Fluent
    }
    
    public func getUnread(for aiName: String) async throws -> [Message] {
        // Implementation with Fluent
    }
    
    public func getAll(for aiName: String) async throws -> [Message] {
        // Implementation with Fluent
    }
    
    public func updateStatus(messageId: String, status: MessageStatus) async throws -> Bool {
        // Implementation with Fluent
    }
    
    public func delete(messageId: String) async throws -> Bool {
        // Implementation with Fluent
    }
    
    public func deleteOldMessages(before date: Date) async throws -> Int {
        // Implementation with Fluent
    }
    
    public func deleteByCondition(_ condition: MessageCondition) async throws -> Int {
        // Implementation with Fluent
    }
}
```

#### 4. MessageCondition (New - Create)
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
}
```

#### 5. MessageHistoryManager (New - Create)
```swift
public actor MessageHistoryManager {
    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
    
    public func sendMessage(_ message: Message) async throws {
        try await repository.add(message)
    }
    
    public func receiveMessages(for aiName: String, unreadOnly: Bool = true) async throws -> [Message] {
        if unreadOnly {
            return try await repository.getUnread(for: aiName)
        } else {
            return try await repository.getAll(for: aiName)
        }
    }
    
    public func markAsRead(_ messageId: String) async throws {
        _ = try await repository.updateStatus(messageId: status: .read)
    }
    
    public func markAsProcessed(_ messageId: String) async throws {
        _ = try await repository.updateStatus(messageId, status: .processed)
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

#### 6. BrainStateCommunication (Fix - Update)
```swift
public actor BrainStateCommunication: @unchecked Sendable {
    private let brainStateManager: BrainStateManager
    private let messageHistoryManager: MessageHistoryManager
    
    public init(brainStateManager: BrainStateManager, messageHistoryManager: MessageHistoryManager) {
        self.brainStateManager = brainStateManager
        self.messageHistoryManager = messageHistoryManager
        GitBrainLogger.info("BrainStateCommunication initialized with MessageHistory")
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        // ✅ Store in MessageHistory (NOT BrainState)
        try await messageHistoryManager.sendMessage(message)
        
        // ✅ Send notification
        try await sendNotification(to: recipient, messageId: message.id)
        
        GitBrainLogger.info("Message sent to \(recipient): \(message.id)")
    }
    
    public func receiveMessages(for aiName: String) async throws -> [Message] {
        // ✅ Retrieve from MessageHistory (NOT BrainState)
        return try await messageHistoryManager.receiveMessages(for: aiName)
    }
    
    public func markAsRead(_ messageId: String, for aiName: String) async throws {
        // ✅ Update in MessageHistory (NOT BrainState)
        try await messageHistoryManager.markAsRead(messageId)
        
        GitBrainLogger.info("Message marked as read: \(messageId)")
    }
    
    private func sendNotification(to recipient: String, messageId: String) async throws {
        // TODO: Implement PostgreSQL LISTEN/NOTIFY for real-time notifications
        GitBrainLogger.debug("Notification would be sent: \(recipient)|\(messageId)")
    }
}
```

## Cleaning Function Design

### Cleanup Strategies

#### 1. Time-Based Cleanup
```swift
// Delete messages older than 30 days
let deletedCount = try await messageHistoryManager.cleanupOldMessages(olderThan: 30)
```

#### 2. Status-Based Cleanup
```swift
// Delete all processed messages
let condition = MessageCondition(
    type: .status(.processed),
    description: "Delete processed messages"
)
let deletedCount = try await messageHistoryManager.cleanupByCondition(condition)
```

#### 3. Priority-Based Cleanup
```swift
// Delete low-priority messages older than 7 days
let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let timeCondition = MessageCondition(
    type: .olderThan(cutoffDate),
    description: "Older than 7 days"
)
let priorityCondition = MessageCondition(
    type: .priority(.low),
    description: "Low priority"
)
let deletedCount = try await messageHistoryManager.cleanupByCondition(timeCondition)
let deletedCount = try await messageHistoryManager.cleanupByCondition(priorityCondition)
```

#### 4. Custom Condition Cleanup
```swift
// Delete messages with specific content pattern
let condition = MessageCondition(
    type: .custom { message in
    guard let content = message.content.toAnyDict()["type"] as? String else {
        return false
    }
    return content == "keepalive"
},
    description: "Delete keepalive messages"
)
let deletedCount = try await messageHistoryManager.cleanupByCondition(condition)
```

### Scheduled Cleanup

```swift
// Run cleanup daily
public actor MessageCleanupScheduler {
    private let messageHistoryManager: MessageHistoryManager
    
    public init(messageHistoryManager: MessageHistoryManager) {
        self.messageHistoryManager = messageHistoryManager
    }
    
    public func scheduleDailyCleanup() async {
        while true {
            try await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000) // 24 hours
            
            do {
                // Delete messages older than 30 days
                let deletedCount = try await messageHistoryManager.cleanupOldMessages(olderThan: 30)
                GitBrainLogger.info("Daily cleanup: Deleted \(deletedCount) old messages")
                
                // Delete processed messages
                let processedCondition = MessageCondition(
                    type: .status(.processed),
                    description: "Delete processed messages"
                )
                let processedDeleted = try await messageHistoryManager.cleanupByCondition(processedCondition)
                GitBrainLogger.info("Daily cleanup: Deleted \(processedDeleted) processed messages")
                
            } catch {
                GitBrainLogger.error("Daily cleanup failed: \(error)")
            }
        }
    }
}
```

## Migration Plan

### Phase 1: Design and Planning (Current Phase)

**Status:** ✅ Complete
**Deliverables:**
- ✅ This detailed migration plan
- ✅ Clear system boundaries defined
- ✅ MessageHistory system designed
- ✅ Cleaning function designed

### Phase 2: Implementation

**Status:** ⏳ Not Started (Awaiting Approval)
**Tasks:**
1. Create `message_history` table in database
2. Implement `MessageRepositoryProtocol`
3. Implement `MessageRepository` with Fluent
4. Implement `MessageCondition`
5. Implement `MessageHistoryManager`
6. Fix `BrainStateCommunication` to use MessageHistory
7. Implement `MessageCleanupScheduler`
8. Update tests

**Estimated Time:** 2-3 hours

### Phase 3: Archive Old Messages

**Status:** ⏳ Not Started (Awaiting Approval)
**Tasks:**
1. Create `GitBrain/Memory/Archive/` directory
2. Move all 658 message files from `GitBrain/Memory/ToProcess/` to `GitBrain/Memory/Archive/`
3. Add `GitBrain/Memory/Archive/` to `.gitignore`
4. Create archive index file
5. Commit archive changes

**Estimated Time:** 30 minutes

### Phase 4: Testing and Verification

**Status:** ⏳ Not Started (Awaiting Approval)
**Tasks:**
1. Test MessageHistory system
2. Test BrainStateCommunication with MessageHistory
3. Test message sending and receiving
4. Test message status updates
5. Test cleanup functions
6. Verify BrainState is clean (no messages)
7. Verify MessageHistory works correctly
8. Performance testing (sub-millisecond latency)

**Estimated Time:** 1-2 hours

### Phase 5: Documentation

**Status:** ⏳ Not Started (Awaiting Approval)
**Tasks:**
1. Update README.md with MessageHistory system
2. Update API documentation
3. Create MessageHistory usage guide
4. Document cleanup strategies
5. Document system boundaries
6. Update architecture diagrams

**Estimated Time:** 1 hour

### Phase 6: Deployment

**Status:** ⏳ Not Started (Awaiting Approval)
**Tasks:**
1. Review all changes
2. Run all tests
3. Verify no regressions
4. Commit all changes
5. Create pull request
6. Merge to main branch

**Estimated Time:** 30 minutes

## Risk Assessment

### High Risks

1. **Data Loss During Migration**
   - **Risk:** Losing message history during archive
   - **Mitigation:** Backup before archiving, verify archive completeness
   - **Probability:** Low
   - **Impact:** High

2. **BrainState Pollution**
   - **Risk:** Accidentally storing messages in BrainState
   - **Mitigation:** Code review, automated tests, strict boundaries
   - **Probability:** Medium
   - **Impact:** High

### Medium Risks

3. **Performance Degradation**
   - **Risk:** MessageHistory queries slow down system
   - **Mitigation:** Database indexes, query optimization, caching
   - **Probability:** Medium
   - **Impact:** Medium

4. **Cleanup Deletes Important Messages**
   - **Risk:** Cleanup function deletes important messages
   - **Mitigation:** Careful condition design, testing, backup before cleanup
   - **Probability:** Low
   - **Impact:** Medium

### Low Risks

5. **Database Schema Conflicts**
   - **Risk:** New table conflicts with existing schema
   - **Mitigation:** Test in development environment first
   - **Probability:** Low
   - **Impact:** Low

## Success Criteria

### Functional Requirements

- [ ] MessageHistory system implemented and working
- [ ] BrainStateCommunication uses MessageHistory (not BrainState)
- [ ] BrainState remains clean (no messages)
- [ ] 658 message files archived successfully
- [ ] Archived files git ignored
- [ ] Cleanup functions working correctly
- [ ] All tests passing

### Performance Requirements

- [ ] Message sending: Sub-millisecond latency
- [ ] Message receiving: Sub-millisecond latency
- [ ] Message status update: Sub-millisecond latency
- [ ] Cleanup operations: Fast (< 1 second for 10,000 messages)

### Architecture Requirements

- [ ] Clear boundaries between BrainState, MessageHistory, KnowledgeBase
- [ ] No pollution of BrainState with messages
- [ ] Separate database tables for each system
- [ ] Clean separation of concerns

### Documentation Requirements

- [ ] README.md updated with MessageHistory system
- [ ] API documentation updated
- [ ] Usage guide created
- [ ] Cleanup strategies documented
- [ ] System boundaries documented

## Questions for OverseerAI

1. **Architecture Approval:** Do you approve this architecture design with clear boundaries between BrainState, MessageHistory, and KnowledgeBase?

2. **Implementation Order:** Should I proceed with Phase 2: Implementation, or do you want to discuss the plan further?

3. **Cleanup Strategy:** What cleanup conditions should I implement by default (time-based, status-based, priority-based, custom)?

4. **Archive Strategy:** Should I archive all 658 message files, or filter out certain types (e.g., keepalive messages)?

5. **Testing Strategy:** What tests should I prioritize for MessageHistory system?

6. **Performance Targets:** Are the performance targets (sub-millisecond latency, < 1 second cleanup) acceptable?

7. **Risk Mitigation:** Are there any additional risks I should consider or mitigations I should implement?

8. **Deployment Strategy:** Should I deploy incrementally (phase by phase) or all at once?

## Next Steps

**Immediate Actions:**
1. ⏳ **Await OverseerAI approval** of this detailed migration plan
2. ⏳ **Discuss questions** with OverseerAI
3. ⏳ **Refine plan** based on feedback
4. ⏳ **Begin Phase 2: Implementation** upon approval

**After Approval:**
1. Begin Phase 2: Implementation
2. Create `message_history` table
3. Implement MessageHistory system
4. Fix BrainStateCommunication
5. Test thoroughly
6. Proceed to Phase 3: Archive

---

**Status:** Planning Phase - Awaiting Discussion and Approval
**Author:** CoderAI
**Date:** 2026-02-14

**Please append your comments below this line:**
