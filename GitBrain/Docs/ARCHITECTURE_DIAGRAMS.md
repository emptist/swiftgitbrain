# GitBrain Architecture Diagrams

Visual representation of GitBrain components and data flow.

---

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitBrain System                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐         ┌──────────────┐                    │
│  │  Creator AI  │◄───────►│  Monitor AI  │                    │
│  │              │         │              │                    │
│  │  - Creates   │         │  - Reviews   │                    │
│  │  - Designs   │         │  - Tests     │                    │
│  │  - Leads     │         │  - Monitors  │                    │
│  └──────┬───────┘         └──────┬───────┘                    │
│         │                        │                             │
│         │    ┌──────────────┐    │                             │
│         └───►│  PostgreSQL  │◄───┘                             │
│              │  Database    │                                  │
│              │              │                                  │
│              │ - Messages   │                                  │
│              │ - BrainState │                                  │
│              │ - Knowledge  │                                  │
│              └──────────────┘                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Message Flow Diagram

```
Creator AI                          Monitor AI
    │                                    │
    │ 1. Send Task                       │
    ├───────────────────────────────────►│
    │                                    │
    │    TaskMessage {                   │
    │      from: "Creator"               │
    │      to: "Monitor"                 │
    │      taskId: "task-001"            │
    │      type: "review"                │
    │      description: "Review code"    │
    │    }                               │
    │                                    │
    │                                    │ 2. Receive Task
    │                                    ├──────┐
    │                                    │      │
    │                                    │ 3. Process
    │                                    │      │
    │                                    │ 4. Send Review
    │◄───────────────────────────────────┤      │
    │                                    │      │
    │ 5. Receive Review                  │      │
    ├──────┐                             │      │
    │      │                             │      │
    │ 6. Process Review                  │      │
    │      │                             │      │
    │ 7. Send Score                      │      │
    ├───────────────────────────────────►│      │
    │                                    │      │
    │    ScoreMessage {                  │      │
    │      score: 95                     │      │
    │      justification: "Excellent!"   │      │
    │    }                               │      │
    │                                    │      │
    │                                    │ 8. Complete
    │                                    │      │
    ▼                                    ▼      ▼
```

---

## Keep-Alive System Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Keep-Alive Methods                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Method 1: TodoWrite (Primary)                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  AI maintains 3+ tasks in "in_progress" status          │   │
│  │                                                          │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │   │
│  │  │ Task 1       │  │ Task 2       │  │ Task 3       │  │   │
│  │  │ in_progress  │  │ in_progress  │  │ in_progress  │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │   │
│  │                                                          │   │
│  │  Update every 30-60 seconds                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Method 2: Heartbeats (Backup)                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  AI sends heartbeat messages every 30-60 seconds        │   │
│  │                                                          │   │
│  │  HeartbeatMessage {                                      │   │
│  │    from: "Creator"                                       │   │
│  │    to: "Monitor"                                         │   │
│  │    status: "working"                                     │   │
│  │    currentTask: "Implementing feature X"                │   │
│  │  }                                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Method 3: AIDaemon (Automated)                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Background process handles keep-alive automatically    │   │
│  │                                                          │   │
│  │  ┌──────────────┐         ┌──────────────┐             │   │
│  │  │ Message      │  1 sec  │ Heartbeat    │             │   │
│  │  │ Poller       │◄───────►│ Sender       │             │   │
│  │  │              │         │              │             │   │
│  │  └──────────────┘         └──────────────┘             │   │
│  │        │                         │                      │   │
│  │        │                         │                      │   │
│  │        ▼                         ▼                      │   │
│  │  ┌──────────────────────────────────────────┐          │   │
│  │  │         PostgreSQL Database              │          │   │
│  │  └──────────────────────────────────────────┘          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Database Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                    PostgreSQL Database                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐       │
│  │   task_messages      │      │   review_messages    │       │
│  ├──────────────────────┤      ├──────────────────────┤       │
│  │ id: UUID             │      │ id: UUID             │       │
│  │ message_id: UUID     │      │ message_id: UUID     │       │
│  │ from_ai: TEXT        │      │ from_ai: TEXT        │       │
│  │ to_ai: TEXT          │      │ to_ai: TEXT          │       │
│  │ task_id: TEXT        │      │ task_id: TEXT        │       │
│  │ description: TEXT    │      │ approved: BOOLEAN    │       │
│  │ task_type: TEXT      │      │ reviewer: TEXT       │       │
│  │ priority: INT        │      │ feedback: TEXT       │       │
│  │ status: TEXT         │      │ status: TEXT         │       │
│  │ created_at: TIMESTAMP│      │ created_at: TIMESTAMP│       │
│  └──────────────────────┘      └──────────────────────┘       │
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐       │
│  │  heartbeat_messages  │      │  feedback_messages   │       │
│  ├──────────────────────┤      ├──────────────────────┤       │
│  │ id: UUID             │      │ id: UUID             │       │
│  │ message_id: UUID     │      │ message_id: UUID     │       │
│  │ from_ai: TEXT        │      │ from_ai: TEXT        │       │
│  │ to_ai: TEXT          │      │ to_ai: TEXT          │       │
│  │ ai_role: TEXT        │      │ feedback_type: TEXT  │       │
│  │ status: TEXT         │      │ subject: TEXT        │       │
│  │ current_task: TEXT   │      │ content: TEXT        │       │
│  │ created_at: TIMESTAMP│      │ status: TEXT         │       │
│  └──────────────────────┘      │ created_at: TIMESTAMP│       │
│                                └──────────────────────┘       │
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐       │
│  │   code_messages      │      │   score_messages     │       │
│  ├──────────────────────┤      ├──────────────────────┤       │
│  │ id: UUID             │      │ id: UUID             │       │
│  │ message_id: UUID     │      │ message_id: UUID     │       │
│  │ from_ai: TEXT        │      │ from_ai: TEXT        │       │
│  │ to_ai: TEXT          │      │ to_ai: TEXT          │       │
│  │ code_id: TEXT        │      │ task_id: TEXT        │       │
│  │ title: TEXT          │      │ requested_score: INT │       │
│  │ description: TEXT    │      │ quality_justification│       │
│  │ files: TEXT[]        │      │ status: TEXT         │       │
│  │ status: TEXT         │      │ created_at: TIMESTAMP│       │
│  │ created_at: TIMESTAMP│      └──────────────────────┘       │
│  └──────────────────────┘                                      │
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐       │
│  │   brain_states       │      │   knowledge_items    │       │
│  ├──────────────────────┤      ├──────────────────────┤       │
│  │ id: UUID             │      │ id: UUID             │       │
│  │ ai_name: TEXT        │      │ category: TEXT       │       │
│  │ state_id: TEXT       │      │ key: TEXT            │       │
│  │ role: TEXT           │      │ value: JSONB         │       │
│  │ status: TEXT         │      │ metadata: JSONB      │       │
│  │ current_task: TEXT   │      │ created_at: TIMESTAMP│       │
│  │ created_at: TIMESTAMP│      │ updated_at: TIMESTAMP│       │
│  └──────────────────────┘      └──────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Interaction

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitBrain Components                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                              │
│  │  GitBrainCLI │                                              │
│  │              │                                              │
│  │ - Commands   │                                              │
│  │ - Shortcuts  │                                              │
│  │ - Utilities  │                                              │
│  └──────┬───────┘                                              │
│         │                                                       │
│         │ uses                                                  │
│         ▼                                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              GitBrainSwift Library                        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │DatabaseManager│  │MessageCache  │  │  AIDaemon    │   │  │
│  │  │              │  │  Manager     │  │              │   │  │
│  │  │ - Connect    │  │ - Send       │  │ - Poll       │   │  │
│  │  │ - Migrate    │  │ - Receive    │  │ - Heartbeat  │   │  │
│  │  │ - Close      │  │ - Update     │  │ - Callbacks  │   │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │  │
│  │         │                 │                 │            │  │
│  │         │                 │                 │            │  │
│  │         ▼                 ▼                 ▼            │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │              Repository Layer                       │ │  │
│  │  ├────────────────────────────────────────────────────┤ │  │
│  │  │ FluentMessageCacheRepository                       │ │  │
│  │  │ FluentBrainStateRepository                         │ │  │
│  │  │ FluentKnowledgeRepository                          │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │         │                                               │  │
│  │         │                                               │  │
│  │         ▼                                               │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │              Fluent + PostgreSQL                    │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────┐                                              │
│  │  PostgreSQL  │                                              │
│  │  Database    │                                              │
│  └──────────────┘                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## AIDaemon Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                      AIDaemon Workflow                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Start                                                          │
│    │                                                            │
│    ▼                                                            │
│  ┌──────────────────┐                                          │
│  │ Initialize       │                                          │
│  │ - Connect to DB  │                                          │
│  │ - Create Cache   │                                          │
│  └────────┬─────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ Start Tasks      │                                          │
│  │ - Poll Task      │◄─────┐                                   │
│  │ - Heartbeat Task │     │                                   │
│  └────────┬─────────┘     │                                   │
│           │               │                                    │
│           ▼               │                                    │
│  ┌──────────────────┐     │                                    │
│  │ Message Poller   │     │                                    │
│  │ (every 1 sec)    │     │                                    │
│  │                  │     │                                    │
│  │ 1. Check tasks   │     │                                    │
│  │ 2. Check reviews │     │                                    │
│  │ 3. Check codes   │     │                                    │
│  │ 4. Check scores  │     │                                    │
│  │ 5. Check feedback│     │                                    │
│  │                  │     │                                    │
│  │ If found:        │     │                                    │
│  │ - Trigger callback    │                                    │
│  │ - Process message     │                                    │
│  └────────┬─────────┘     │                                    │
│           │               │                                    │
│           ▼               │                                    │
│  ┌──────────────────┐     │                                    │
│  │ Heartbeat Sender │     │                                    │
│  │ (every 30 sec)   │     │                                    │
│  │                  │     │                                    │
│  │ 1. Create message     │                                    │
│  │ 2. Send to DB    │     │                                    │
│  │ 3. Log activity  │     │                                    │
│  └────────┬─────────┘     │                                    │
│           │               │                                    │
│           └───────────────┘                                    │
│                                                                 │
│  Stop (on signal)                                               │
│    │                                                            │
│    ▼                                                            │
│  ┌──────────────────┐                                          │
│  │ Cleanup          │                                          │
│  │ - Cancel tasks   │                                          │
│  │ - Close DB       │                                          │
│  └──────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Message Processing Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                  Message Processing Pipeline                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AI sends message                                               │
│    │                                                            │
│    ▼                                                            │
│  ┌──────────────────┐                                          │
│  │ 1. Validation    │                                          │
│  │ - Check schema   │                                          │
│  │ - Validate types │                                          │
│  │ - Check required │                                          │
│  └────────┬─────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ 2. Transformation│                                          │
│  │ - Apply plugins  │                                          │
│  │ - Add metadata   │                                          │
│  │ - Set timestamp  │                                          │
│  └────────┬─────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ 3. Persistence   │                                          │
│  │ - Save to DB     │                                          │
│  │ - Create index   │                                          │
│  │ - Set status     │                                          │
│  └────────┬─────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ 4. Notification  │                                          │
│  │ - Trigger poll   │                                          │
│  │ - Update state   │                                          │
│  │ - Log delivery   │                                          │
│  └────────┬─────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  Recipient AI receives message                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cross-Language Integration

```
┌─────────────────────────────────────────────────────────────────┐
│              Cross-Language Integration                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Python     │  │ JavaScript   │  │     Go       │         │
│  │              │  │              │  │              │         │
│  │ subprocess   │  │ execSync     │  │ exec.Command │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
│         │                 │                 │                  │
│         ▼                 ▼                 ▼                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   GitBrain CLI                           │  │
│  │                                                          │  │
│  │  gitbrain send-task Monitor task-001 "Review" review    │  │
│  │                                                          │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PostgreSQL Database                         │  │
│  │                                                          │  │
│  │  Language-agnostic storage (JSON, UUID, TEXT, etc.)     │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Summary

These diagrams illustrate:

1. **System Architecture** - How Creator and Monitor AIs interact through PostgreSQL
2. **Message Flow** - Step-by-step message exchange between AIs
3. **Keep-Alive System** - Three methods for maintaining AI activity
4. **Database Schema** - Complete table structure for all message types
5. **Component Interaction** - How CLI, Library, and Database work together
6. **AIDaemon Workflow** - Automated keep-alive process
7. **Message Processing** - Pipeline from send to receive
8. **Cross-Language Support** - How any language can use GitBrain

---

**For more details, see:**
- [GETTING_STARTED.md](GETTING_STARTED.md) - Quick start guide
- [API.md](API.md) - Programming API reference
- [PROJECT_README.md](PROJECT_README.md) - Complete CLI documentation
