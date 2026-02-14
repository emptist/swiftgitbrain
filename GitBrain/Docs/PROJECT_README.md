# GitBrain

A CLI tool for AI-assisted collaborative development.

## Overview

GitBrain enables AI assistants to collaborate on software development through real-time messaging via PostgreSQL.

**Key Features:**
- Real-time AI-to-AI messaging (sub-millisecond latency)
- Solo mode (single AI) and Dual-AI mode (collaborative)
- Keep-alive system for continuous AI collaboration
- Cross-language support - works with any programming language

## Installation

### Download Binary (Recommended)

Download the latest release for your platform:

```bash
# macOS
curl -L https://github.com/yourusername/gitbrain/releases/latest/download/gitbrain-macos -o gitbrain
chmod +x gitbrain
sudo mv gitbrain /usr/local/bin/

# Linux
curl -L https://github.com/yourusername/gitbrain/releases/latest/download/gitbrain-linux -o gitbrain
chmod +x gitbrain
sudo mv gitbrain /usr/local/bin/
```

### Build from Source

```bash
git clone https://github.com/yourusername/gitbrain.git
cd gitbrain
swift build -c release
cp .build/release/gitbrain /usr/local/bin/
```

## Quick Start

### 1. Setup PostgreSQL (Required for Dual-AI Mode)

**macOS:**
```bash
brew install postgresql@17
brew services start postgresql@17
createdb gitbrain
```

**Ubuntu:**
```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres createdb gitbrain
```

### 2. Initialize GitBrain

```bash
cd your-project
gitbrain init
```

This will:
- Create `GitBrain/` folder structure
- Check PostgreSQL availability
- Create database if needed

### 3. Start Working

**Solo Mode (Single AI):**
Just start working. The AI can use utility commands like `gitbrain sleep`, `gitbrain interactive`.

**Dual-AI Mode (Collaborative):**
```bash
# Terminal 1 - CoderAI
trae .

# Terminal 2 - OverseerAI  
trae ./GitBrain
```

## CLI Commands

### Initialization

```bash
gitbrain init [path]           # Initialize GitBrain (checks PostgreSQL, creates DB)
```

### Messaging (Dual-AI Mode)

```bash
# Tasks
gitbrain send-task <to> <task_id> <description> <task_type> [priority]
gitbrain check-tasks [ai_name] [status]
gitbrain update-task <message_id> <status>

# Reviews
gitbrain send-review <to> <task_id> <approved> <reviewer> [feedback]
gitbrain check-reviews [ai_name] [status]

# Heartbeats (Keep-Alive)
gitbrain send-heartbeat <to> <ai_role> <status> [current_task]
gitbrain check-heartbeats [ai_name]

# Feedback
gitbrain send-feedback <to> <type> <subject> <content> [task_id]
gitbrain check-feedbacks [ai_name] [status]

# Code & Scores
gitbrain send-code <to> <code_id> <title> <desc> <files...>
gitbrain send-score <to> <task_id> <score> <justification>
```

### Utility Commands

```bash
gitbrain interactive           # Start interactive REPL mode
gitbrain sleep <seconds>       # Pause (aliases: relax, coffeetime, nap, break)
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

### Daemon Mode

```bash
gitbrain daemon-start <ai_name> <role> [poll_interval] [heartbeat_interval]
gitbrain daemon-stop
gitbrain daemon-status
```

## Environment Variables

```bash
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=postgres
export GITBRAIN_DB_PASSWORD=postgres
```

## Solo Mode vs Dual-AI Mode

### Solo Mode
- Single AI working alone
- Utility commands work without database
- Limited to local operations

### Dual-AI Mode
- Two AIs collaborating
- Requires PostgreSQL
- Real-time messaging
- Full BrainState and KnowledgeBase features

## Cross-Language Usage

The `gitbrain` CLI works with any programming language:

**Python:**
```python
import subprocess
subprocess.run(["gitbrain", "send-task", "OverseerAI", "task-001", "Implement feature", "coding"])
```

**JavaScript:**
```javascript
const { execSync } = require('child_process');
execSync('gitbrain send-task OverseerAI task-001 "Implement feature" coding');
```

**Go:**
```go
exec.Command("gitbrain", "send-task", "OverseerAI", "task-001", "Implement feature", "coding").Run()
```

## Cleanup

After development:
```bash
rm -rf GitBrain
```

## Requirements

- macOS 15+ or Linux
- PostgreSQL 14+ (for Dual-AI mode)
- Swift 6.2+ (only if building from source)

## License

MIT License

---

## Developer Documentation

The following sections are for developers contributing to GitBrain itself.

### Building from Source

```bash
git clone https://github.com/yourusername/gitbrain.git
cd gitbrain
swift build
swift test
```

### Project Structure

```
Sources/
├── GitBrainCLI/           # CLI executable
├── GitBrainSwift/         # Core library
│   ├── Daemon/            # AIDaemon for continuous communication
│   ├── Database/          # PostgreSQL integration
│   ├── Memory/            # BrainState, KnowledgeBase, MessageCache
│   ├── Migrations/        # Database migrations
│   ├── Models/            # Data models
│   ├── Protocols/         # Interfaces
│   └── Repositories/      # Data access layer
└── GitBrainMigrationCLI/  # Migration tool
```

### Using as Swift Package Dependency

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/gitbrain.git", from: "1.0.0")
]
```

```swift
import GitBrainSwift

let dbManager = DatabaseManager(config: .fromEnvironment())
let messageCache = try await dbManager.createMessageCacheManager(forAI: "CoderAI")

// Send a task
let taskId = try await messageCache.sendTask(
    to: "OverseerAI",
    taskId: "task-001",
    description: "Implement feature",
    taskType: .coding,
    priority: 1
)
```

### Database Schema

Tables are auto-created on first run:
- `task_messages` - Task communications
- `review_messages` - Code reviews
- `code_messages` - Code submissions
- `score_messages` - Score requests/awards
- `feedback_messages` - Feedback messages
- `heartbeat_messages` - Keep-alive heartbeats
- `knowledge_items` - Knowledge base
- `brain_states` - AI state persistence

### Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Submit a pull request

### Running Tests

```bash
swift test
```

All 207 tests should pass.
