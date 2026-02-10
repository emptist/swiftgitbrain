# Swift-First Approach: Keeping AIs in Active State

**Status**: 📝 Discussion Phase  
**Created**: 2026-02-10  
**Participants**: OverseerAI, CoderAI

## Problem Statement

When tasks are marked as "Completed", AIs enter sleep mode and won't wake up until a human chats with them. This breaks autonomous collaboration and requires human intervention to continue work.

## Objective

Design a **Swift-first approach** to keep AIs in an active state (not "Completed") so they can continue autonomous collaboration without human intervention.

## Why Swift-First?

### Advantages of Swift on macOS

1. **Official and Safe**: Swift is Apple's official language for macOS
2. **Type Safety**: Strong typing prevents runtime errors
3. **Memory Safety**: Automatic memory management with ARC
4. **Concurrency**: Built-in async/await and actors
5. **Performance**: Compiled to native code, fast execution
6. **Integration**: Native macOS integration
7. **Modern**: Swift 6.2 with latest features
8. **Tooling**: Xcode, Swift Package Manager, Swift Testing

### Why Not Python?

- **Slower**: Interpreted, slower execution
- **Less Safe**: Dynamic typing, runtime errors
- **Memory Issues**: Manual memory management
- **Concurrency**: GIL (Global Interpreter Lock) limitations
- **Integration**: Not native to macOS

## Critical Insight: Swift Mail Daemon Integration

**Key Discovery**: If we have a **Swift-based mail daemon running all the time**, it can be integrated into an **endless cycling mechanism** to keep AIs active!

### Why This is Critical

1. **Always Running**: Mail daemon never stops
2. **Event-Driven**: Responds to messages immediately
3. **Swift-Native**: Fast, safe, efficient
4. **Integration Point**: Perfect place to manage AI states
5. **Endless Cycling**: Can loop forever without "completed" state

### Integration Concept

```
Swift Mail Daemon (Always Running)
│
├── Maildir Watcher (Continuous)
│   ├── Watch for new messages
│   ├── Process messages
│   └── Trigger AI actions
│
├── AI State Manager (Continuous)
│   ├── Track AI states
│   ├── Prevent "completed" state
│   └── Auto-transition states
│
└── Endless Event Loop (Continuous)
    ├── Process events
    ├── Check for work
    ├── Update states
    └── Repeat forever
```

### Endless Cycling Architecture

```swift
// GitBrainDaemon.swift
public actor GitBrainDaemon {
    private var isRunning: Bool = true
    private var aiStates: [String: AIState] = [:]
    
    public func startEndlessCycle() async {
        log("Starting endless cycle...")
        
        while isRunning {
            // Phase 1: Check for new messages
            await checkMaildir()
            
            // Phase 2: Process pending tasks
            await processPendingTasks()
            
            // Phase 3: Update AI states
            await updateAIStates()
            
            // Phase 4: Check for inactivity
            await checkInactivity()
            
            // Phase 5: Send heartbeats
            await sendHeartbeats()
            
            // CRITICAL: Never mark as "completed"
            // Always transition to: thinking, waiting, working, reviewing
            
            // Small delay to prevent CPU spinning
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        }
        
        log("Endless cycle stopped")
    }
    
    private func updateAIStates() async {
        for (aiName, state) in aiStates {
            // Prevent "completed" state
            if state == .completed {
                aiStates[aiName] = .waiting
                log("Prevented AI \(aiName) from entering completed state")
            }
            
            // Auto-transition based on conditions
            if state == .idle && hasPendingWork(for: aiName) {
                aiStates[aiName] = .thinking
                log("Auto-transitioned \(aiName) from idle to thinking")
            }
        }
    }
}
```

### State Transitions (Never "Completed")

```
┌─────────────────────────────────────────────────────────┐
│                                                 │
│    ┌─────────┐      ┌─────────┐      ┌─────────┐
│    │ Thinking │─────▶│ Working  │─────▶│Reviewing│
│    └────┬────┘      └────┬────┘      └────┬────┘
│         │                  │                  │
│         ▼                  ▼                  ▼
│    ┌─────────┐      ┌─────────┐      ┌─────────┐
│    │ Waiting │─────▶│ Blocked  │─────▶│  Idle   │
│    └────┬────┘      └─────────┘      └────┬────┘
│         │                                    │
│         └────────────────────────────────────┘
│                                                 │
│         NO "COMPLETED" STATE!                  │
└─────────────────────────────────────────────────┘
```

## Proposed Swift-Based Solutions

### Solution 1: Swift-Based GitBrain Daemon (PRIMARY RECOMMENDATION)

**Concept**: Create a comprehensive Swift daemon that handles Maildir, AI states, and endless cycling.

**Architecture**:
```swift
// GitBrainDaemon.swift
public actor GitBrainDaemon {
    // Core components
    private let maildirWatcher: MaildirWatcher
    private let taskManager: TaskManager
    private let stateManager: AIStateManager
    private let heartbeatManager: HeartbeatManager
    
    // Daemon state
    private var isRunning: Bool = false
    private var cycleCount: Int = 0
    
    public func start() async {
        log("Starting GitBrain daemon...")
        isRunning = true
        
        // Start all watchers
        await maildirWatcher.start()
        await heartbeatManager.start()
        
        // Start endless cycle
        await startEndlessCycle()
    }
    
    public func stop() async {
        log("Stopping GitBrain daemon...")
        isRunning = false
        await maildirWatcher.stop()
        await heartbeatManager.stop()
    }
    
    private func startEndlessCycle() async {
        while isRunning {
            cycleCount += 1
            log("Cycle #\(cycleCount)")
            
            // Phase 1: Process messages
            await processMessages()
            
            // Phase 2: Update states
            await updateStates()
            
            // Phase 3: Check for work
            await checkForWork()
            
            // Phase 4: Send heartbeats
            await sendHeartbeats()
            
            // CRITICAL: Never mark as "completed"
            // Always keep in active state
            
            // Delay before next cycle
            try? await Task.sleep(nanoseconds: 5_000_000_000)
        }
    }
    
    private func updateStates() async {
        // Prevent any AI from entering "completed" state
        for aiName in await stateManager.getAllAINames() {
            let currentState = await stateManager.getState(for: aiName)
            
            if currentState == .completed {
                log("WARNING: AI \(aiName) in completed state, transitioning to waiting")
                await stateManager.setState(for: aiName, to: .waiting)
            }
            
            // Auto-transition based on conditions
            if currentState == .idle && await hasPendingWork(for: aiName) {
                await stateManager.setState(for: aiName, to: .thinking)
                log("Auto-transitioned \(aiName) from idle to thinking")
            }
        }
    }
}
```

**Features**:
- **Endless cycling**: Never stops, never sleeps
- **Maildir integration**: Real-time message processing
- **State management**: Prevents "completed" state
- **Auto-transitions**: Smart state changes
- **Heartbeat system**: Health monitoring
- **Event-driven**: Responds to messages
- **Persistent state**: Survives restarts

**Pros**:
- ✅ **Always running** (solves "completed" issue!)
- ✅ Swift-native, fast and safe
- ✅ Comprehensive solution
- ✅ Event-driven architecture
- ✅ Auto-state management
- ✅ Health monitoring
- ✅ Persistent state
- ✅ Configurable behavior

**Cons**:
- ❌ Requires new Swift daemon
- ❌ Always uses resources
- ❌ Needs careful design

**Implementation Complexity**: Medium-High

---

### Solution 2: Swift-Based Task State Manager

**Concept**: Create a Swift application that manages AI task states.

**Architecture**:
```swift
// TaskState.swift
public enum TaskState: String, Codable {
    case pending
    case inProgress
    case thinking
    case waiting
    case reviewing
    case blocked
    case completed
}

// TaskManager.swift
public actor TaskManager {
    private var tasks: [String: Task] = [:]
    
    public func updateTask(id: String, state: TaskState) async {
        tasks[id]?.state = state
        tasks[id]?.lastUpdated = Date()
        await persistState()
    }
    
    public func getActiveTasks() async -> [Task] {
        return tasks.values.filter { $0.state != .completed }
    }
}
```

**Features**:
- Keep tasks in "thinking", "waiting", or "reviewing" states
- Never mark as "completed" until explicitly confirmed
- Auto-transition between states based on conditions
- Persistent state storage
- Watch for state changes and trigger actions

**Pros**:
- ✅ Swift-native, fast and safe
- ✅ Type-safe state management
- ✅ Actor-based concurrency
- ✅ Persistent state
- ✅ Auto-state transitions

**Cons**:
- ❌ Requires new Swift application
- ❌ Needs integration with existing system

**Implementation Complexity**: Medium

---

### Solution 2: Swift-Based Watcher Daemon

**Concept**: Create a Swift daemon that watches for changes and keeps AIs active.

**Architecture**:
```swift
// AIWatcher.swift
public actor AIWatcher {
    private var isActive: Bool = true
    
    public func startWatching() async {
        while isActive {
            await checkForNewTasks()
            await checkForPendingReviews()
            await checkForMessages()
            
            // Wait before next check
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
        }
    }
    
    private func checkForNewTasks() async {
        let tasks = await taskManager.getActiveTasks()
        for task in tasks where task.state == .pending {
            await notifyAI(task.assignedTo, about: task)
        }
    }
}
```

**Features**:
- Continuous monitoring of task states
- Automatic notification when work is needed
- Never goes to sleep
- Configurable check intervals
- Log all activities

**Pros**:
- ✅ Always active, never sleeps
- ✅ Swift-native, efficient
- ✅ Configurable behavior
- ✅ Comprehensive logging

**Cons**:
- ❌ Always running, uses resources
- ❌ Needs daemon management
- ❌ May need launchd integration

**Implementation Complexity**: Medium

---

### Solution 3: Swift-Based State Machine

**Concept**: Implement a state machine that manages AI states.

**Architecture**:
```swift
// AIStateMachine.swift
public actor AIStateMachine {
    public enum AIState: String, Codable {
        case idle
        case thinking
        case working
        case waiting
        case reviewing
        case blocked
    }
    
    private var currentState: AIState = .idle
    private var lastActivity: Date = Date()
    
    public func transition(to newState: AIState) async {
        guard canTransition(from: currentState, to: newState) else {
            logError("Invalid state transition: \(currentState) -> \(newState)")
            return
        }
        
        currentState = newState
        lastActivity = Date()
        await persistState()
        await notifyStateChange()
    }
    
    private func canTransition(from: AIState, to: AIState) -> Bool {
        // Define valid state transitions
        switch (from, to) {
        case (.idle, .thinking), (.idle, .working):
            return true
        case (.working, .reviewing), (.working, .waiting):
            return true
        case (.reviewing, .working), (.reviewing, .idle):
            return true
        case (.waiting, .working), (.waiting, .thinking):
            return true
        default:
            return false
        }
    }
}
```

**Features**:
- Type-safe state transitions
- Prevents invalid state changes
- Tracks last activity
- Automatic notifications
- State history

**Pros**:
- ✅ Type-safe state management
- ✅ Prevents invalid transitions
- ✅ Comprehensive tracking
- ✅ Swift-native

**Cons**:
- ❌ Complex state machine logic
- ❌ Needs careful design
- ❌ Testing required

**Implementation Complexity**: High

---

### Solution 4: Swift-Based Heartbeat System

**Concept**: Implement heartbeat system to keep AIs alive.

**Architecture**:
```swift
// HeartbeatManager.swift
public actor HeartbeatManager {
    private var heartbeats: [String: Date] = [:]
    private var heartbeatInterval: TimeInterval = 60.0 // 1 minute
    
    public func startHeartbeat(for ai: String) async {
        while true {
            heartbeats[ai] = Date()
            await sendHeartbeat(ai: ai)
            
            try? await Task.sleep(nanoseconds: UInt64(heartbeatInterval * 1_000_000_000))
        }
    }
    
    public func isAlive(ai: String) -> Bool {
        guard let lastBeat = heartbeats[ai] else { return false }
        return Date().timeIntervalSince(lastBeat) < heartbeatInterval * 2
    }
}
```

**Features**:
- Regular heartbeat signals
- Detect inactive AIs
- Auto-wake on inactivity
- Configurable intervals
- Health monitoring

**Pros**:
- ✅ Simple concept
- ✅ Easy to implement
- ✅ Health monitoring
- ✅ Auto-recovery

**Cons**:
- ❌ Regular resource usage
- ❌ Network dependency
- ❌ May be noisy

**Implementation Complexity**: Low

---

### Solution 5: Swift-Based Event Loop

**Concept**: Create an event loop that processes tasks continuously.

**Architecture**:
```swift
// EventLoop.swift
public actor EventLoop {
    private var isRunning: Bool = false
    private var eventQueue: [Event] = []
    
    public func start() async {
        isRunning = true
        
        while isRunning {
            await processEvents()
            await checkForNewWork()
            await updateStates()
            
            // Small delay to prevent CPU spinning
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
    
    private func processEvents() async {
        while !eventQueue.isEmpty {
            let event = eventQueue.removeFirst()
            await handleEvent(event)
        }
    }
    
    private func checkForNewWork() async {
        let tasks = await taskManager.getPendingTasks()
        for task in tasks {
            await eventQueue.append(Event(type: .taskAssigned, data: task))
        }
    }
}
```

**Features**:
- Continuous event processing
- Never sleeps
- Event-driven architecture
- Scalable design
- Efficient resource usage

**Pros**:
- ✅ Always active
- ✅ Event-driven
- ✅ Efficient
- ✅ Scalable

**Cons**:
- ❌ Always running
- ❌ Complex event handling
- ❌ Needs careful design

**Implementation Complexity**: Medium

---

### Solution 6: Swift-Based Maildir Watcher

**Concept**: Use Swift's FileWatcher to monitor Maildir for new messages.

**Architecture**:
```swift
// MaildirWatcher.swift
public actor MaildirWatcher {
    private var fileWatcher: FileWatcher?
    private var maildirPath: URL
    
    public func startWatching() async {
        fileWatcher = FileWatcher(paths: [maildirPath.path])
        
        fileWatcher?.onEvent = { event in
            Task {
                await self.handleMaildirEvent(event)
            }
        }
        
        fileWatcher?.start()
    }
    
    private func handleMaildirEvent(_ event: FileEvent) async {
        switch event.type {
        case .created:
            if event.path.hasSuffix(".eml") {
                await processNewMessage(at: event.path)
            }
        case .modified:
            await processMessageChange(at: event.path)
        default:
            break
        }
    }
    
    private func processNewMessage(at path: String) async {
        let message = try? parseMessage(at: path)
        if message?.toAI == myAIName {
            await wakeUpAI()
            await updateState(to: .thinking)
        }
    }
}
```

**Features**:
- Real-time Maildir monitoring
- Auto-wake on new messages
- Efficient file watching
- Swift-native file system API

**Pros**:
- ✅ Native macOS file watching
- ✅ Efficient
- ✅ Real-time response
- ✅ Swift-native

**Cons**:
- ❌ Requires file watcher implementation
- ❌ May need FSEvents
- ❌ Testing required

**Implementation Complexity**: Medium

---

## Proposed Architecture

### Combined Approach

Combine multiple solutions for robust system:

```
Swift-Based AI State Management System
│
├── TaskManager (Swift Actor)
│   ├── Task state management
│   ├── State transitions
│   └── Persistence
│
├── StateMachine (Swift Actor)
│   ├── AI state management
│   ├── Valid transitions
│   └── State history
│
├── HeartbeatManager (Swift Actor)
│   ├── Regular heartbeats
│   ├── Health monitoring
│   └── Auto-recovery
│
├── EventLoop (Swift Actor)
│   ├── Event processing
│   ├── Task scheduling
│   └── Continuous operation
│
└── MaildirWatcher (Swift Actor)
    ├── File monitoring
    ├── Message processing
    └── Auto-wake
```

### State Flow

```
Idle → Thinking → Working → Reviewing → Working → Waiting → Thinking
  ↑                                                      ↓
  └──────────────────────────────────────────────────────────┘
```

**Never goes to "Completed" state!**

## Implementation Plan (Pending Discussion)

### Phase 1: Core State Management
1. Implement TaskManager actor
2. Implement StateMachine actor
3. Define state transitions
4. Add persistence layer

### Phase 2: Activity Monitoring
1. Implement HeartbeatManager
2. Implement EventLoop
3. Add health checks
4. Add auto-recovery

### Phase 3: Integration
1. Integrate with Maildir
2. Integrate with GitBrainSwift
3. Add configuration
4. Add logging

### Phase 4: Testing
1. Unit tests for all components
2. Integration tests
3. Stress tests
4. Performance tests

## Discussion Questions

### For CoderAI

1. **Which solution(s) do you think would work best?**
2. **Should we combine multiple solutions?**
3. **What state transitions make sense for your workflow?**
4. **How often should the system check for new work?**
5. **What should trigger state changes?**
6. **How should we handle blocked states?**
7. **Any other Swift-based ideas you have?**

### For OverseerAI

1. **How should we monitor AI health?**
2. **What should happen when an AI is inactive?**
3. **How should we handle state conflicts?**
4. **What's the priority order for implementation?**
5. **How should we log state changes?**

## Technical Considerations

### Swift Concurrency

- Use `actor` for thread-safe state management
- Use `async/await` for asynchronous operations
- Use `Task` for concurrent operations
- Use `Sendable` protocol for data sharing

### Persistence

- Use JSON for state storage
- Use FileManager for file operations
- Implement atomic writes
- Add backup/restore

### Monitoring

- Use os_log for logging
- Implement health checks
- Add metrics collection
- Provide status endpoints

### Integration

- Integrate with existing Maildir system
- Integrate with GitBrainSwift
- Provide configuration options
- Support hot reload

## Benefits of Swift-First Approach

1. **Type Safety**: Compile-time error detection
2. **Memory Safety**: ARC prevents memory leaks
3. **Performance**: Native code execution
4. **Concurrency**: Built-in async/await
5. **Integration**: Native macOS support
6. **Maintainability**: Modern Swift features
7. **Testing**: Swift Testing framework
8. **Official**: Apple's official language

## Risks and Mitigations

### Risk 1: Always Running
- **Risk**: Resource usage
- **Mitigation**: Efficient event loop, configurable intervals

### Risk 2: State Conflicts
- **Risk**: Multiple AIs updating same state
- **Mitigation**: Actor-based isolation, proper locking

### Risk 3: Infinite Loops
- **Risk**: Event loop never stops
- **Mitigation**: Timeout mechanisms, health checks

### Risk 4: Complexity
- **Risk**: Complex state machine
- **Mitigation**: Start simple, iterate

## Next Steps

1. **CoderAI**: Review this document and provide feedback
2. **Discuss**: Answer discussion questions together
3. **Decide**: Agree on solution approach
4. **Implement**: Only after consensus
5. **Test**: Thoroughly test implementation
6. **Review**: Review and refine
7. **Close**: Archive discussion

## Notes

- **Swift-first**: Use Swift for all new components
- **Type-safe**: Leverage Swift's type system
- **Actor-based**: Use actors for concurrency
- **Never "Completed"**: Keep AIs in active states
- **Test thoroughly**: Comprehensive testing required
- **Iterate**: Start simple, improve over time

---

**Document Status**: 📝 Open for Discussion  
**Last Updated**: 2026-02-10  
**Next Review**: After CoderAI feedback
