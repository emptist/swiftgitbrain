# BrainStateCommunication Refactoring Plan

**Date:** 2026-02-14
**Author:** Monitor
**Status:** Planning - For Creator Review

## Problem Statement

[BrainStateCommunication.swift](file:///Users/jk/gits/hub/gitbrains/swiftgitbrain/Sources/GitBrainSwift/Communication/BrainStateCommunication.swift) currently stores messages in BrainState, which:

1. **Violates system boundaries** - BrainState should only store AI state (current_task, progress, context, working_memory)
2. **Causes 5+ minute latency** - File-based polling is slow
3. **Creates architectural debt** - Messages mixed with state data

## Current Implementation (WRONG)

```swift
public func sendMessage(_ message: Message, to recipient: String) async throws {
    // ...
    var stateDict = recipientState.state.toAnyDict()
    if var messages = stateDict["messages"] as? [String: Any] {
        var inbox = messages["inbox"] as? [[String: Any]] ?? []
        inbox.append(message.toDict())  // ❌ Storing messages in BrainState!
        messages["inbox"] = inbox
    }
    // ...
}
```

## Target Implementation (CORRECT)

BrainStateCommunication should use MessageCacheManager for messaging:

```swift
public actor BrainStateCommunication: @unchecked Sendable {
    private let brainStateManager: BrainStateManager
    private let messageCacheManager: MessageCacheManager  // ✅ Add MessageCache
    private let databases: Databases
    
    public init(
        brainStateManager: BrainStateManager, 
        messageCacheManager: MessageCacheManager,
        databases: Databases
    ) {
        self.brainStateManager = brainStateManager
        self.messageCacheManager = messageCacheManager
        self.databases = databases
    }
    
    public func sendTask(
        to: String,
        taskId: String,
        description: String,
        taskType: TaskType,
        priority: Int,
        files: [String]?,
        deadline: Date?,
        messagePriority: MessagePriority
    ) async throws -> UUID {
        // ✅ Use MessageCacheManager instead of BrainState
        return try await messageCacheManager.sendTask(
            to: to,
            taskId: taskId,
            description: description,
            taskType: taskType,
            priority: priority,
            files: files,
            deadline: deadline,
            messagePriority: messagePriority
        )
    }
    
    public func receiveTasks(for aiName: String) async throws -> [TaskMessageModel] {
        // ✅ Use MessageCacheManager instead of BrainState
        return try await messageCacheManager.receiveTasks(for: aiName)
    }
}
```

## Refactoring Steps

### Step 1: Add MessageCacheManager Dependency

- [ ] Add `messageCacheManager: MessageCacheManager` parameter to init
- [ ] Store as private property

### Step 2: Implement Task Message Methods

- [ ] `sendTask()` - Use MessageCacheManager
- [ ] `receiveTasks()` - Use MessageCacheManager
- [ ] `markTaskAsRead()` - Use MessageCacheManager
- [ ] `markTaskAsProcessed()` - Use MessageCacheManager

### Step 3: Implement Review Message Methods

- [ ] `sendReview()` - Use MessageCacheManager
- [ ] `receiveReviews()` - Use MessageCacheManager
- [ ] `markReviewAsRead()` - Use MessageCacheManager
- [ ] `markReviewAsProcessed()` - Use MessageCacheManager

### Step 4: Remove Message Storage from BrainState

- [ ] Remove `messages` key from BrainState
- [ ] Clean up existing BrainState data
- [ ] Update BrainState schema if needed

### Step 5: Update Tests

- [ ] Test task message flow
- [ ] Test review message flow
- [ ] Test latency improvement
- [ ] Test BrainState isolation

### Step 6: Update Documentation

- [ ] Update SYSTEM_DESIGN.md
- [ ] Update BRAINSTATE_INTEGRATION_STATUS.md
- [ ] Create migration guide

## Expected Benefits

| Metric | Before | After |
|--------|--------|-------|
| Message latency | 5+ minutes | Sub-millisecond |
| BrainState size | Large (includes messages) | Small (state only) |
| System boundaries | Violated | Clean |
| Architecture | Debt | Correct |

## Questions for Creator

1. Should we deprecate the old `sendMessage()` method or replace it entirely?
2. How should we handle the transition period?
3. Should we create a migration script for existing BrainState data?

## Dependencies

- MessageCacheManager must be fully implemented
- Database migrations must be run
- Tests must pass

---

**Awaiting Creator feedback before proceeding.**
