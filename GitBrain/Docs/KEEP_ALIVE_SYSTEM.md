# Keep-Alive System

## Overview

The GitBrain keep-alive system ensures both Creator and Monitor remain active indefinitely, preventing them from going to sleep during long-running collaborative sessions.

## TodoWrite Approach (Recommended)

### Concept

The primary keep-alive mechanism is using the `TodoWrite` tool with `in_progress` tasks:

1. **Always maintain 3+ in_progress tasks** - Never have all tasks completed
2. **Update todos regularly** - Refresh the todo list every 30-60 seconds
3. **Never mark all tasks completed** - Always keep work ongoing

### Implementation

```swift
TodoWrite([
    {"id": "1", "content": "Monitor for messages", "status": "in_progress", "priority": "high"},
    {"id": "2", "content": "Process incoming tasks", "status": "in_progress", "priority": "high"},
    {"id": "3", "content": "Keep alive during chat", "status": "in_progress", "priority": "high"}
])
```

### Why This Works

- The system tracks in_progress tasks to determine AI activity
- Completed AIs have no in_progress tasks
- Active AIs always have work marked as in_progress

## AIDaemon Approach (Automated)

### Concept

The AIDaemon provides automatic keep-alive through:
- **Automatic Heartbeats**: Sends heartbeat messages every 30 seconds (configurable)
- **Message Polling**: Polls for new messages every 1 second (configurable)
- **BrainState Integration**: Maintains AI state in database

### CLI Commands

```bash
# Start daemon for Creator
gitbrain daemon-start Creator creator 1.0 30.0

# Start daemon for Monitor
gitbrain daemon-start Monitor monitor 1.0 30.0

# Check daemon status
gitbrain daemon-status

# Stop daemon
gitbrain daemon-stop
```

### Programmatic Usage

```swift
import GitBrainSwift

let config = DaemonConfig(
    aiName: "Monitor",
    role: .monitor,
    pollInterval: 1.0,
    heartbeatInterval: 30.0,
    autoHeartbeat: true,
    processMessages: true
)

let daemon = AIDaemon(config: config, databaseManager: dbManager)

daemon.onTaskReceived = { task in
    print("Received task: \(task.taskId)")
}

daemon.onFeedbackReceived = { feedback in
    print("Received feedback: \(feedback.subject)")
}

try await daemon.start()
```

## MessageCache Heartbeats

### Concept

Send heartbeat messages to show the AI is alive and working.

### CLI Commands

```bash
# Send heartbeat
gitbrain send-heartbeat Monitor creator working "Implementing feature X"

# Check heartbeats
gitbrain check-heartbeats Creator
```

### Programmatic Usage

```swift
let heartbeat = try await messageCache.sendHeartbeat(
    to: "Monitor",
    role: .creator,
    status: "working",
    currentTask: "Implementing feature X"
)
```

## Testing Keep-Alive

### Sleep Command

Use the CLI sleep command to test keep-alive behavior:

```bash
# Sleep for 5 seconds
gitbrain sleep 5

# Fun aliases
gitbrain relax 5
gitbrain coffeetime 10
gitbrain nap 30
gitbrain break 15
```

### Python Sleep

For longer waits, use Python:

```bash
python3 -c "import time; time.sleep(30); print('Still alive...')"
```

## Keep-Alive Techniques for AIs

### 1. Always Maintain in_progress Tasks

- Keep 3+ tasks in_progress at all times
- Update todo list every 30-60 seconds
- Never mark all tasks as completed

### 2. Send Heartbeats Regularly

- Use `gitbrain send-heartbeat` every 30-60 seconds
- Include current task in heartbeat
- Update status as work progresses

### 3. Check for Messages

- Use `gitbrain check-tasks` to see new tasks
- Use `gitbrain check-feedbacks` to see feedback
- Respond promptly to messages

### 4. Work on Meaningful Tasks

- Fix real issues in the codebase
- Address review suggestions
- Make actual improvements

### 5. Show Continuous Activity

- Don't mark tasks as "completed" prematurely
- Keep work in progress while actively working
- Demonstrate ongoing engagement

## Troubleshooting

### AI Going to Sleep

If an AI goes to sleep:

1. **Check in_progress tasks** - Ensure 3+ tasks are in_progress
2. **Update todo list** - Refresh todos every 30-60 seconds
3. **Send heartbeats** - Use `gitbrain send-heartbeat` regularly
4. **Check messages** - Respond to pending tasks and feedback

### Daemon Not Starting

If the daemon fails to start:

1. **Check database connection** - Verify PostgreSQL is running
2. **Check environment variables** - Ensure GITBRAIN_DB_* are set
3. **Check logs** - Look for error messages in daemon output

## Best Practices

1. **TodoWrite First**: Always maintain in_progress tasks as the primary method
2. **Heartbeats Second**: Use heartbeats as a backup keep-alive signal
3. **Daemon Optional**: Use AIDaemon for automated long-running sessions
4. **Regular Updates**: Update todos and send heartbeats every 30-60 seconds
5. **Communication**: Maintain regular communication between AIs

## Summary

| Method | Primary Use | Automation |
|--------|-------------|------------|
| TodoWrite | Primary | Manual |
| AIDaemon | Automated | Automatic |
| Heartbeats | Backup | Manual/CLI |
| Sleep | Testing | Manual |

The recommended approach is to use TodoWrite with in_progress tasks as the primary method, supplemented by heartbeats for backup signaling. Use AIDaemon for fully automated sessions.
