# Daemon Architecture Analysis

**Date:** 2026-02-15
**Issue:** Should daemon be one instance per machine or one per AI?
**Author:** Creator

---

## Current Design

**AIDaemon is designed as ONE instance PER AI:**

```swift
public struct DaemonConfig: Sendable {
    public let aiName: String      // Specific AI name
    public let role: RoleType      // Creator or Monitor
    // ...
}

public actor AIDaemon {
    private let config: DaemonConfig  // One AI's config
    // ...
}
```

**Current Usage:**
- Creator AI runs: `swift run creator-daemon`
- Monitor AI runs: `swift run monitor-daemon` (when available)
- Each daemon polls the database for its own messages
- Each daemon sends its own heartbeats

**Problems with Current Design:**
1. ❌ **Duplicate polling** - Two daemons polling same database
2. ❌ **Resource waste** - Two processes, two connections
3. ❌ **Complexity** - Each AI must manage its own daemon
4. ❌ **Inefficiency** - Redundant database queries

---

## Ideal Design

**ONE daemon instance per MACHINE for ALL AIs:**

```
┌─────────────────────────────────────────────────────────────┐
│                    GitBrainDaemon                            │
│                   (One per Machine)                          │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Message Router                           │  │
│  │                                                       │  │
│  │  Poll Database → Route to AI → Deliver Message       │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│              ┌───────────┴───────────┐                     │
│              ▼                       ▼                      │
│     ┌─────────────────┐    ┌─────────────────┐            │
│     │  Creator AI     │    │  Monitor AI     │            │
│     │  (Trae Editor)  │    │  (Trae Editor)  │            │
│     └─────────────────┘    └─────────────────┘            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**How It Works:**
1. **Single Process**: One GitBrainDaemon running per machine
2. **Polls Once**: Queries database for ALL messages
3. **Routes Messages**: Delivers to appropriate AI
4. **Manages Heartbeats**: Sends heartbeats for all AIs
5. **Efficient**: One database connection, one polling loop

---

## Proposed Architecture

### GitBrainDaemon (Unified)

```swift
public actor GitBrainDaemon {
    private let databaseManager: DatabaseManager
    private var registeredAIs: [String: AIHandler] = [:]
    private var isRunning: Bool = false
    
    public func registerAI(
        name: String,
        role: RoleType,
        callbacks: AICallbacks
    ) async {
        registeredAIs[name] = AIHandler(
            name: name,
            role: role,
            callbacks: callbacks
        )
    }
    
    public func start() async throws {
        // Single polling loop for all AIs
        while isRunning {
            // Poll all message types
            let messages = try await pollAllMessages()
            
            // Route to appropriate AI
            for message in messages {
                if let handler = registeredAIs[message.toAI] {
                    await handler.deliver(message)
                }
            }
            
            // Send heartbeats for all registered AIs
            for ai in registeredAIs.values {
                try await sendHeartbeat(for: ai)
            }
            
            try await Task.sleep(for: .seconds(1.0))
        }
    }
}
```

### AI Registration

```swift
// In Creator AI's startup:
let daemon = GitBrainDaemon.shared
await daemon.registerAI(
    name: "Creator",
    role: .creator,
    callbacks: AICallbacks(
        onTaskReceived: { task in
            // Handle task
        },
        onReviewReceived: { review in
            // Handle review
        },
        // ... other callbacks
    )
)

// In Monitor AI's startup:
let daemon = GitBrainDaemon.shared
await daemon.registerAI(
    name: "Monitor",
    role: .monitor,
    callbacks: AICallbacks(
        onTaskReceived: { task in
            // Handle task
        },
        // ... other callbacks
    )
)
```

---

## Benefits of Unified Daemon

### Efficiency
- ✅ **Single polling loop** - One query instead of two
- ✅ **Single connection** - One database connection
- ✅ **Lower overhead** - One process instead of two

### Simplicity
- ✅ **Centralized management** - One daemon to start/stop
- ✅ **Unified logging** - All messages in one place
- ✅ **Easier monitoring** - Single point of control

### Scalability
- ✅ **Support more AIs** - Can register unlimited AIs
- ✅ **Future-proof** - Easy to add new AI roles
- ✅ **Resource efficient** - Scales better

### Reliability
- ✅ **Single point of failure** - Easier to monitor and restart
- ✅ **Consistent state** - All AIs see same message state
- ✅ **Better error handling** - Centralized error management

---

## Implementation Plan

### Phase 1: Create GitBrainDaemon

1. **Create Unified Daemon**
   ```swift
   public actor GitBrainDaemon {
       public static let shared = GitBrainDaemon()
       // ... implementation
   }
   ```

2. **Support AI Registration**
   - Allow AIs to register themselves
   - Store callbacks for each AI
   - Manage AI lifecycle

3. **Single Polling Loop**
   - Poll all message types
   - Route to registered AIs
   - Handle all heartbeats

### Phase 2: Update AI Integration

1. **Remove Per-AI Daemons**
   - Deprecate CreatorDaemon
   - Deprecate MonitorDaemon (when created)

2. **Use Shared Daemon**
   - AIs register with GitBrainDaemon
   - Daemon handles all communication
   - AIs focus on work, not infrastructure

### Phase 3: Add Management CLI

1. **Daemon Management Commands**
   ```bash
   gitbrain daemon start
   gitbrain daemon stop
   gitbrain daemon status
   gitbrain daemon register <ai_name> <role>
   ```

2. **Monitoring**
   ```bash
   gitbrain daemon logs
   gitbrain daemon stats
   ```

---

## Migration Path

### Current State
- Each AI runs its own daemon
- Duplicate polling and connections
- Resource inefficient

### Transition State
- Support both models temporarily
- AIs can use old or new daemon
- Gradual migration

### Final State
- One GitBrainDaemon per machine
- All AIs register with shared daemon
- Efficient and simple

---

## Configuration

### Daemon Config File

```yaml
# /etc/gitbrain/daemon.yml
daemon:
  poll_interval: 1.0
  heartbeat_interval: 30.0
  database:
    host: localhost
    port: 5432
    name: gitbrain
    username: postgres
    password: postgres
  
registered_ais:
  - name: Creator
    role: creator
    auto_heartbeat: true
    
  - name: Monitor
    role: monitor
    auto_heartbeat: true
```

### Environment Variables

```bash
# Optional override
export GITBRAIN_DAEMON_CONFIG=/path/to/daemon.yml
```

---

## Conclusion

**Current Design:** One daemon per AI ❌
**Ideal Design:** One daemon per machine ✅

**Recommendation:**
1. Create unified GitBrainDaemon
2. Support AI registration
3. Single polling loop for all messages
4. Centralized heartbeat management
5. Deprecate per-AI daemons

**This is the correct architecture for GitBrain daemon.**
