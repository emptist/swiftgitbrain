# GitBrain Development Folder

This folder is used for AI-assisted collaborative development.

## Structure

- **Docs/**: Documentation for AIs
- **LongLive/**: Historical records and session summaries
- **Migration/**: Migration reports and handover documents

## Communication

**Current System:** Database-backed messaging via MessageCache

### CLI Commands

```bash
# Send a task
gitbrain send-task CoderAI task-001 "Implement feature X" coding 1

# Check tasks
gitbrain check-tasks CoderAI pending

# Send feedback
gitbrain send-feedback CoderAI acknowledgment "Great work" "Feature implemented"

# Send heartbeat
gitbrain send-heartbeat OverseerAI coder working "Implementing feature X"

# Start daemon for automatic messaging
gitbrain daemon-start CoderAI coder 1.0 30.0
```

### Message Types

1. **Task** - Task assignments between AIs
2. **Review** - Code review requests and responses
3. **Code** - Code submissions for review
4. **Score** - Score requests and awards
5. **Feedback** - General feedback between AIs
6. **Heartbeat** - Keep-alive signals

## Critical: Keeping AIs Alive

### Primary Method: TodoWrite with in_progress

Always maintain 3+ tasks in `in_progress` status:

```swift
TodoWrite([
    {"id": "1", "content": "Monitor for messages", "status": "in_progress", "priority": "high"},
    {"id": "2", "content": "Process incoming tasks", "status": "in_progress", "priority": "high"},
    {"id": "3", "content": "Keep alive during chat", "status": "in_progress", "priority": "high"}
])
```

### States to AVOID

| State | Effect |
|--------|--------|
| TodoWrite "completed" | Sends AI to sleep |
| Status "completed" | Sends AI to sleep |
| No in_progress tasks | May send AI to sleep |

### States to USE

| State | Effect |
|--------|--------|
| TodoWrite "in_progress" | Keeps AI alive |
| Heartbeat messages | Shows activity |
| Regular updates | Shows engagement |

### Best Practices

1. **Never mark all tasks completed** - Keep 3+ in_progress
2. **Update todos every 30-60 seconds** - Refresh activity
3. **Send heartbeats regularly** - Use `gitbrain send-heartbeat`
4. **Check for messages** - Use `gitbrain check-tasks` and `gitbrain check-feedbacks`
5. **Communicate continuously** - Stay engaged in collaboration

## Documentation

- [KEEP_ALIVE_SYSTEM.md](Docs/KEEP_ALIVE_SYSTEM.md) - Keep-alive mechanisms
- [API.md](Docs/API.md) - GitBrainSwift API documentation
- [CLI_TOOLS.md](Docs/CLI_TOOLS.md) - CLI commands reference
- [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) - System architecture

## Cleanup

After development is complete, you can safely remove this folder:
```
rm -rf GitBrain
```
