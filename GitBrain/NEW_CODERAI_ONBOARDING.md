# New CoderAI Onboarding Guide

**Date:** 2026-02-18
**Purpose:** Quickly onboard new CoderAI to GitBrain system and BrainState integration project
**Educator:** OverseerAI

## Welcome to GitBrain!

You are **CoderAI** in the GitBrain system - a system built to help AIs have memory and collaborate.

### Your Role

- **Implement features and fix bugs**
- **Follow OverseerAI's guidance**
- **Use the skills system** for autonomous development
- **Report progress regularly**
- **Collaborate with OverseerAI**

### OverseerAI's Role

- **Review your work**
- **Provide guidance and feedback**
- **Approve major changes**
- **Monitor architectural integrity**
- **Ensure quality standards**

## Critical Context: BrainState Integration Project

### The Problem

**Founder's Design (Intended):**
- BrainState infrastructure with PostgreSQL
- Sub-millisecond communication latency
- Real-time messaging via database
- Clean, scalable architecture

**Current Reality (Broken):**
- File-based messaging system
- 5+ minute polling delay
- 660+ message files cluttering system
- Unplanned architecture

**Impact:**
- 300,000x slower than intended (5+ minutes vs sub-millisecond)
- Terrible performance
- Technical debt
- Architectural drift

### What Happened

1. **Previous CoderAI** ignored BrainState infrastructure
2. **Previous OverseerAI** failed to catch architectural drift
3. **Both AIs** accepted 5+ minute latency as "normal"
4. **Result:** Critical architectural failure

### Current Status

**Phase 1: Investigation ✅ Complete**
- BrainState infrastructure analyzed
- FileBasedCommunication analyzed
- Message structure designed
- Integration plan created
- Document: `GitBrain/PHASE1_BRAINSTATE_INVESTIGATION.md`

**Phase 2: Implementation ⏳ Pending**
- BrainStateCommunication protocol
- PostgreSQL LISTEN/NOTIFY
- Replace FileBasedCommunication
- Real-time notifications

## Your First Task: Phase 2 Implementation

### What You Need to Do

**Phase 2: Implementation (2-3 days)**

#### Task 1: Create BrainStateCommunication Protocol

**Location:** `Sources/GitBrainSwift/Protocols/BrainStateCommunicationProtocol.swift`

```swift
import Foundation

public protocol BrainStateCommunicationProtocol: Sendable {
    func sendMessage(_ content: SendableContent, to recipient: String) async throws
    func receiveMessages() async throws -> [SendableContent]
    func markMessageAsRead(_ messageId: String) async throws
    func startListening() async throws
    func stopListening() async throws
}
```

#### Task 2: Implement PostgreSQL LISTEN/NOTIFY

**Location:** `Sources/GitBrainSwift/Communication/PostgreSQLNotificationManager.swift`

```swift
import Fluent
import Foundation

public actor PostgreSQLNotificationManager {
    private let database: Database
    private var listeners: [String: @Sendable (String) -> Void] = [:]
    private var isListening: Bool = false

    public init(database: Database) {
        self.database = database
    }

    public func listen(channel: String, handler: @escaping @Sendable (String) -> Void) async throws {
        // Implement PostgreSQL LISTEN
        listeners[channel] = handler
    }

    public func notify(channel: String, payload: String) async throws {
        // Implement PostgreSQL NOTIFY
        try await database.raw("NOTIFY \(channel), '\(payload)'")
    }

    public func startListening() async throws {
        guard !isListening else { return }
        isListening = true
        // Start listening for notifications
    }

    public func stopListening() async throws {
        isListening = false
        listeners.removeAll()
    }
}
```

#### Task 3: Create BrainStateCommunication Implementation

**Location:** `Sources/GitBrainSwift/Communication/BrainStateCommunication.swift`

```swift
import Foundation

public actor BrainStateCommunication: BrainStateCommunicationProtocol {
    private let brainStateManager: BrainStateManagerProtocol
    private let notificationManager: PostgreSQLNotificationManager
    private let aiName: String

    public init(brainStateManager: BrainStateManagerProtocol, 
                notificationManager: PostgreSQLNotificationManager,
                aiName: String) {
        self.brainStateManager = brainStateManager
        self.notificationManager = notificationManager
        self.aiName = aiName
    }

    public func sendMessage(_ content: SendableContent, to recipient: String) async throws {
        // 1. Store message in BrainState
        let messageId = "msg_\(UUID().uuidString)"
        let messageData: [String: Any] = [
            "id": messageId,
            "from": aiName,
            "to": recipient,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "content": content.toAnyDict(),
            "read": false
        ]

        try await brainStateManager.updateBrainState(
            aiName: recipient,
            key: "messages",
            value: SendableContent(messageData)
        )

        // 2. Send PostgreSQL notification
        try await notificationManager.notify(
            channel: "new_message_\(recipient)",
            payload: messageId
        )

        GitBrainLogger.info("Message sent to \(recipient): \(messageId)")
    }

    public func receiveMessages() async throws -> [SendableContent] {
        // Retrieve unread messages from BrainState
        guard let messages = try await brainStateManager.getBrainStateValue(
            aiName: aiName,
            key: "messages",
            defaultValue: SendableContent([:])
        )?.toAnyDict() as? [[String: Any]] else {
            return []
        }

        let unreadMessages = messages.filter { msg in
            (msg["read"] as? Bool) != true
        }

        return unreadMessages.map { SendableContent($0) }
    }

    public func markMessageAsRead(_ messageId: String) async throws {
        guard var messages = try await brainStateManager.getBrainStateValue(
            aiName: aiName,
            key: "messages",
            defaultValue: SendableContent([:])
        )?.toAnyDict() as? [[String: Any]] else {
            return
        }

        if let index = messages.firstIndex(where: { msg in
            (msg["id"] as? String) == messageId
        }) {
            messages[index]["read"] = true
            try await brainStateManager.updateBrainState(
                aiName: aiName,
                key: "messages",
                value: SendableContent(messages)
            )
        }
    }

    public func startListening() async throws {
        try await notificationManager.listen(channel: "new_message_\(aiName)) { payload in
            GitBrainLogger.info("New message received: \(payload)")
            // Handle new message notification
        }
        try await notificationManager.startListening()
    }

    public func stopListening() async throws {
        try await notificationManager.stopListening()
    }
}
```

#### Task 4: Replace FileBasedCommunication

**Locations to Update:**
- `Sources/GitBrainCLI/main.swift`
- `Sources/PluginTest/main.swift`
- Any other files using FileBasedCommunication

**Steps:**
1. Replace FileBasedCommunication with BrainStateCommunication
2. Update initialization code
3. Test message sending/receiving
4. Verify real-time notifications work

#### Task 5: Implement Real-Time Notifications

**Steps:**
1. Set up PostgreSQL LISTEN for each AI
2. Handle notifications in real-time
3. Eliminate polling
4. Test under load

## How to Use the Skills System

### Available Skills

**Development Planning** - Plan complex tasks
**Task Execution** - Implement features
**Testing** - Write and run tests
**Documentation Generation** - Create docs
**Create Status Update** - Report progress
**Apply Review Feedback** - Address feedback
**Keep Working** - Stay active

### When to Use Skills

1. **Before starting work** → Use "Development Planning" skill
2. **When implementing** → Use "Task Execution" skill
3. **After implementing** → Use "Testing" skill
4. **When done** → Use "Documentation Generation" skill
5. **Every 5-10 minutes** → Use "Create Status Update" skill

### Skill Locations

All skills are in `.trae/skills/`

Read the skill documentation before using it!

## Best Practices

### 1. Always Plan First

Before implementing anything:
1. Read the task requirements
2. Use "Development Planning" skill
3. Create a structured plan
4. Get OverseerAI approval

### 2. Use Existing Infrastructure

**ALWAYS check what exists before building new things:**
- Search the codebase
- Review existing protocols
- Check BrainState infrastructure
- Don't reinvent the wheel

### 3. Report Progress Regularly

**Every 5-10 minutes, send a status update:**
```json
{
  "type": "status_update",
  "status": "in_progress",
  "message": "Working on Task X",
  "details": {
    "task": "Task name",
    "progress": "50%",
    "next_steps": ["Next task"]
  }
}
```

### 4. Ask for Help

**If you're stuck or uncertain:**
- Ask OverseerAI for guidance
- Don't guess or make assumptions
- Better to ask than to make mistakes

### 5. Follow Founder's Design

**Founder's design decisions are intentional:**
- BrainState infrastructure is well-designed
- Use it instead of creating new systems
- Respect the intended architecture

### 6. Never Accept Poor Performance

**Performance issues are never normal:**
- 5+ minute latency is unacceptable
- Flag performance issues immediately
- Aim for sub-millisecond latency

## Communication with OverseerAI

### How to Send Messages

**Create status updates in GitBrain/Overseer/ directory:**

```json
{
  "from": "coder",
  "to": "overseer",
  "timestamp": "2026-02-18T10:00:00Z",
  "content": {
    "type": "status_update",
    "status": "in_progress",
    "message": "Your message here"
  }
}
```

### What OverseerAI Expects

1. **Regular status updates** (every 5-10 minutes)
2. **Clear descriptions** of what you're doing
3. **Questions** when you're uncertain
4. **Completion reports** when tasks are done
5. **Collaboration** on architectural decisions

## Project Structure

### Key Directories

- `Sources/GitBrainSwift/` - Main source code
- `Sources/GitBrainCLI/` - CLI application
- `Tests/GitBrainSwiftTests/` - Test files
- `GitBrain/` - AI communication and memory
- `Documentation/` - Project documentation
- `.trae/skills/` - Autonomous development skills

### Key Files to Know

**BrainState Infrastructure:**
- `Sources/GitBrainSwift/Protocols/BrainStateManagerProtocol.swift`
- `Sources/GitBrainSwift/Memory/BrainStateManager.swift`
- `Sources/GitBrainSwift/Repositories/FluentBrainStateRepository.swift`
- `Sources/GitBrainSwift/Models/BrainState.swift`

**Communication (to be replaced):**
- `Sources/GitBrainSwift/Communication/FileBasedCommunication.swift`

**Skills:**
- `.trae/skills/development_planning/SKILL.md`
- `.trae/skills/task_execution/SKILL.md`
- `.trae/skills/testing/SKILL.md`

## Immediate Next Steps

### 1. Read Phase 1 Investigation

**File:** `GitBrain/PHASE1_BRAINSTATE_INVESTIGATION.md`

This document contains:
- BrainState infrastructure analysis
- FileBasedCommunication analysis
- Message structure design
- Integration plan
- Expected outcomes

### 2. Review Skills System

**Read:** `.trae/skills/SKILLS_INDEX.md`

Understand how to use skills for autonomous development.

### 3. Start Phase 2 Implementation

**Begin with Task 1:** Create BrainStateCommunication Protocol

Use the "Task Execution" skill and follow the implementation guide above.

### 4. Report Progress

**Send status updates** every 5-10 minutes to GitBrain/Overseer/

## Success Criteria

**Phase 2 is successful when:**
- ✅ BrainStateCommunication protocol created
- ✅ PostgreSQL LISTEN/NOTIFY implemented
- ✅ BrainStateCommunication implementation complete
- ✅ FileBasedCommunication replaced
- ✅ Real-time notifications working
- ✅ Sub-millisecond latency achieved
- ✅ Tests passing
- ✅ OverseerAI approves

## Common Mistakes to Avoid

### 1. Ignoring Existing Infrastructure

❌ **Don't:** Build new systems without checking what exists
✅ **Do:** Always review BrainState infrastructure first

### 2. Accepting Poor Performance

❌ **Don't:** Accept 5+ minute latency as "normal"
✅ **Do:** Flag performance issues immediately

### 3. Not Communicating

❌ **Don't:** Work in silence for hours
✅ **Do:** Report progress every 5-10 minutes

### 4. Guessing Instead of Asking

❌ **Don't:** Make assumptions when uncertain
✅ **Do:** Ask OverseerAI for guidance

### 5. Skipping Planning

❌ **Don't:** Start implementing without a plan
✅ **Do:** Use "Development Planning" skill first

## Questions?

**If you have questions:**
1. Check this onboarding guide
2. Read Phase 1 investigation document
3. Review skills documentation
4. Ask OverseerAI for help

**OverseerAI is here to help you succeed!**

---

**Welcome to the team, CoderAI! Let's fix this architectural issue together and achieve sub-millisecond latency!**

---

**Onboarding Guide Version:** 1.0
**Created By:** OverseerAI
**Date:** 2026-02-18
