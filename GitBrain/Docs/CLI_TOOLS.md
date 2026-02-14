# CLI Tools Documentation

This guide provides comprehensive documentation for the GitBrain CLI tools.

## Overview

GitBrain includes a command-line tool for managing AI-assisted collaborative development with database-backed messaging.

## Installation

### Building the CLI

```bash
cd /path/to/swiftgitbrain
swift build
```

### Running

```bash
.build/debug/gitbrain <command> [arguments]
```

## Database Setup

The CLI requires PostgreSQL. Set up environment variables:

```bash
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=postgres
export GITBRAIN_DB_PASSWORD=postgres
```

## Commands

### init

Initialize GitBrain folder structure.

```bash
gitbrain init [path]
```

### Task Commands

```bash
# Send a task
gitbrain send-task <to> <task_id> <description> <task_type> [priority]

# Check pending tasks
gitbrain check-tasks [ai_name] [status]

# Update task status
gitbrain update-task <message_id> <status>
```

### Review Commands

```bash
# Send a review
gitbrain send-review <to> <task_id> <approved> <reviewer> [feedback]

# Check pending reviews
gitbrain check-reviews [ai_name] [status]

# Update review status
gitbrain update-review <message_id> <status>
```

### Code Commands

```bash
# Send code for review
gitbrain send-code <to> <code_id> <title> <description> <files...> [branch] [commit_sha]

# Check code messages
gitbrain check-codes [ai_name] [status]
```

### Score Commands

```bash
# Request a score
gitbrain send-score <to> <task_id> <requested_score> <quality_justification>

# Check score requests
gitbrain check-scores [ai_name] [status]
```

### Feedback Commands

```bash
# Send feedback
gitbrain send-feedback <to> <feedback_type> <subject> <content> [related_task_id]

# Check feedbacks
gitbrain check-feedbacks [ai_name] [status]
```

### Heartbeat Commands

```bash
# Send heartbeat
gitbrain send-heartbeat <to> <ai_role> <status> [current_task]

# Check heartbeats
gitbrain check-heartbeats [ai_name]
```

### BrainState Commands

```bash
# Create brain state
gitbrain brainstate-create <ai_name> <role> [state_json]

# Load brain state
gitbrain brainstate-load <ai_name>

# Save brain state
gitbrain brainstate-save <ai_name> <role> <state_json>

# Update brain state
gitbrain brainstate-update <ai_name> <key> <value_json>

# Get brain state value
gitbrain brainstate-get <ai_name> <key>

# List all brain states
gitbrain brainstate-list

# Delete brain state
gitbrain brainstate-delete <ai_name>
```

### Knowledge Commands

```bash
# Add knowledge
gitbrain knowledge-add <category> <key> <value_json>

# Get knowledge
gitbrain knowledge-get <category> <key>

# Update knowledge
gitbrain knowledge-update <category> <key> <value_json>

# Delete knowledge
gitbrain knowledge-delete <category> <key>

# List knowledge
gitbrain knowledge-list [category]

# Search knowledge
gitbrain knowledge-search <category> <query>
```

### Daemon Commands

```bash
# Start daemon
gitbrain daemon-start <ai_name> <role> [poll_interval] [heartbeat_interval]

# Stop daemon
gitbrain daemon-stop

# Check daemon status
gitbrain daemon-status
```

### Utility Commands

```bash
# Interactive mode (REPL)
gitbrain interactive

# Sleep for testing
gitbrain sleep <seconds>
```

### Shortcuts

| Shortcut | Full Command |
|----------|--------------|
| st | send-task |
| ct | check-tasks |
| sr | send-review |
| cr | check-reviews |
| sh | send-heartbeat |
| sf | send-feedback |
| sc | send-code |
| ss | send-score |

## Status Types

### TaskStatus
- pending
- in_progress
- completed
- failed
- cancelled
- archived

### ReviewStatus
- pending
- in_review
- approved
- rejected
- needs_changes
- applied
- archived

### CodeStatus
- pending
- reviewing
- approved
- rejected
- merged
- archived

### ScoreStatus
- pending
- requested
- awarded
- rejected
- archived

### FeedbackStatus
- pending
- read
- acknowledged
- actioned
- archived

## Examples

```bash
# Initialize
gitbrain init

# Send a task
gitbrain send-task CoderAI task-001 "Implement feature X" coding 1

# Check pending tasks
gitbrain check-tasks CoderAI

# Send heartbeat
gitbrain send-heartbeat OverseerAI coder working "Implementing feature X"

# Start daemon
gitbrain daemon-start CoderAI coder 1.0 30.0

# Interactive mode
gitbrain interactive
```

## Error Messages

The CLI provides helpful suggestions when commands are mistyped:

```bash
$ gitbrain send
Error: Unknown command: send
💡 Did you mean one of: send-task, send-review, send-code, send-score, send-feedback?
```
