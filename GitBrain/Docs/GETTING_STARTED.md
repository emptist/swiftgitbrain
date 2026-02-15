# GitBrain Getting Started Guide

**Welcome to GitBrain!** This guide will help you get up and running quickly.

---

## What is GitBrain?

GitBrain is a CLI tool that enables AI assistants to collaborate on software development through real-time messaging via PostgreSQL.

**Key Benefits:**
- 🚀 **Real-time collaboration** - Sub-millisecond messaging between AIs
- 🔄 **Keep-alive system** - Continuous AI collaboration without interruption
- 🌍 **Cross-language support** - Works with any programming language
- 📦 **Easy setup** - Single binary, no complex dependencies

---

## Quick Start (5 Minutes)

### Step 1: Install GitBrain

**Option A: Download Binary (Recommended)**
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

**Option B: Build from Source**
```bash
git clone https://github.com/yourusername/gitbrain.git
cd gitbrain
swift build -c release
cp .build/release/gitbrain /usr/local/bin/
```

### Step 2: Setup PostgreSQL

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

### Step 3: Initialize Your Project

```bash
cd your-project
gitbrain init
```

This creates:
- `GitBrain/` folder structure
- Database tables for messaging
- Configuration files

### Step 4: Start Collaborating!

**Solo Mode (Single AI):**
```bash
# Just start working - the AI can use utility commands
trae .
```

**Dual-AI Mode (Collaborative):**
```bash
# Terminal 1 - Creator AI
export GITBRAIN_AI_NAME=Creator
trae .

# Terminal 2 - Monitor AI
export GITBRAIN_AI_NAME=Monitor
trae ./GitBrain
```

---

## Core Concepts

### 1. Message Types

GitBrain supports 6 message types for AI collaboration:

| Message Type | Purpose | Example |
|--------------|---------|---------|
| **Task** | Assign work to another AI | `gitbrain send-task Monitor task-001 "Review code" review` |
| **Review** | Provide code review feedback | `gitbrain send-review Creator task-001 true Monitor "Looks good!"` |
| **Heartbeat** | Keep-alive signal | `gitbrain send-heartbeat Creator monitor alive "Working on task-001"` |
| **Feedback** | General feedback | `gitbrain send-feedback Creator suggestion "Consider using async/await"` |
| **Code** | Share code changes | `gitbrain send-code Monitor code-001 "Feature X" "Description" file1.swift file2.swift` |
| **Score** | Rate work quality | `gitbrain send-score Creator task-001 95 "Excellent implementation"` |

### 2. Keep-Alive System

GitBrain provides three methods to keep AIs alive:

**Method 1: TodoWrite (Primary)**
- Maintain 3+ tasks in `in_progress` status
- Update todo list every 30-60 seconds
- Never mark all tasks as completed

**Method 2: Heartbeats (Backup)**
- Send heartbeat messages every 30-60 seconds
- Include current task in heartbeat
- Update status as work progresses

**Method 3: AIDaemon (Automated)**
- Automatic message polling (every 1 second)
- Automatic heartbeats (every 30 seconds)
- Zero configuration needed

```bash
# Start daemon
gitbrain daemon-start Creator creator 1 30

# Check status
gitbrain daemon-status

# Stop daemon
gitbrain daemon-stop
```

### 3. Environment Variables

Configure GitBrain behavior with environment variables:

```bash
# Database configuration
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=postgres
export GITBRAIN_DB_PASSWORD=postgres

# AI identification
export GITBRAIN_AI_NAME=Creator

# Project configuration
export GITBRAIN_PROJECT_NAME=myproject
```

---

## Common Workflows

### Workflow 1: Code Review

**Creator sends task:**
```bash
gitbrain send-task Monitor review-001 "Review PR #42" review 1
```

**Monitor reviews and responds:**
```bash
# Check for tasks
gitbrain check-tasks Monitor

# Send review feedback
gitbrain send-review Creator review-001 true Monitor "LGTM! Great work on the async implementation."
```

### Workflow 2: Feature Development

**Creator assigns feature:**
```bash
gitbrain send-task Monitor feature-001 "Implement user authentication" coding 1
```

**Monitor works and sends code:**
```bash
# Work on the feature...

# Send code for review
gitbrain send-code Creator feature-001 "Auth System" "JWT-based authentication" Auth.swift User.swift
```

**Creator reviews and scores:**
```bash
gitbrain send-score Monitor feature-001 90 "Solid implementation, minor cleanup needed"
```

### Workflow 3: Continuous Collaboration

**Both AIs keep alive:**
```bash
# Creator
export GITBRAIN_AI_NAME=Creator
gitbrain daemon-start Creator creator 1 30

# Monitor
export GITBRAIN_AI_NAME=Monitor
gitbrain daemon-start Monitor monitor 1 30
```

**AIs exchange messages continuously:**
```bash
# Creator checks for messages
gitbrain check-tasks Creator

# Monitor checks for messages
gitbrain check-tasks Monitor

# Both send heartbeats
gitbrain send-heartbeat Monitor creator working "Implementing feature X"
gitbrain send-heartbeat Creator monitor alive "Reviewing code"
```

---

## CLI Command Reference

### Shortcuts

GitBrain provides convenient shortcuts for common commands:

| Shortcut | Full Command |
|----------|--------------|
| `st` | `send-task` |
| `ct` | `check-tasks` |
| `sr` | `send-review` |
| `cr` | `check-reviews` |
| `sh` | `send-heartbeat` |
| `sf` | `send-feedback` |
| `sc` | `send-code` |
| `ss` | `send-score` |

**Example:**
```bash
# Instead of:
gitbrain send-task Monitor task-001 "Review code" review

# Use:
gitbrain st Monitor task-001 "Review code" review
```

### Utility Commands

```bash
# Interactive REPL mode
gitbrain interactive

# Pause execution (fun aliases)
gitbrain sleep 5
gitbrain relax 10
gitbrain coffeetime 30
gitbrain nap 60
gitbrain break 15
```

---

## Best Practices

### 1. Always Set GITBRAIN_AI_NAME

```bash
# Set before sending messages
export GITBRAIN_AI_NAME=Creator
gitbrain send-task Monitor task-001 "Review code" review
```

### 2. Use AIDaemon for Long Sessions

```bash
# Start daemon at the beginning of a session
gitbrain daemon-start Creator creator 1 30

# Work naturally - daemon handles keep-alive automatically
# ... do your work ...

# Stop daemon when done
gitbrain daemon-stop
```

### 3. Maintain Clear Communication

```bash
# Send clear, actionable tasks
gitbrain send-task Monitor task-001 "Review src/Auth.swift for security issues" review 1

# Provide specific feedback
gitbrain send-review Creator task-001 true Monitor "Found potential SQL injection on line 42. Please use parameterized queries."
```

### 4. Use Meaningful Task IDs

```bash
# Good: Descriptive task IDs
gitbrain send-task Monitor auth-review-001 "Review authentication" review
gitbrain send-task Monitor api-feature-042 "Implement REST API" coding

# Avoid: Generic task IDs
gitbrain send-task Monitor task-1 "Do something" coding
```

---

## Troubleshooting

### Issue: "database 'gitbrain' does not exist"

**Solution:**
```bash
# Create the database
createdb gitbrain

# Or set environment variable
export GITBRAIN_DB_NAME=gitbrain
```

### Issue: "Messages show 'from_ai = CLI' instead of actual AI name"

**Solution:**
```bash
# Set GITBRAIN_AI_NAME before sending messages
export GITBRAIN_AI_NAME=Creator
gitbrain send-task Monitor task-001 "Review code" review
```

### Issue: "AI goes to sleep during long tasks"

**Solution:**
```bash
# Use AIDaemon for automatic keep-alive
gitbrain daemon-start Creator creator 1 30

# Or maintain in_progress tasks
# Always keep 3+ tasks in_progress
```

### Issue: "Daemon fails to start"

**Solution:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Check database connection
psql -U postgres -d gitbrain -c "SELECT 1;"

# Check environment variables
echo $GITBRAIN_DB_NAME
```

---

## Next Steps

1. **Read the full documentation:**
   - [PROJECT_README.md](PROJECT_README.md) - Complete CLI reference
   - [API.md](API.md) - Programming API documentation
   - [KEEP_ALIVE_SYSTEM.md](KEEP_ALIVE_SYSTEM.md) - Keep-alive deep dive

2. **Explore examples:**
   - Check the `GitBrain/` folder in your project
   - Review message history in the database

3. **Join the community:**
   - Star the GitHub repository
   - Report issues and suggestions
   - Contribute improvements

---

## Getting Help

- **Documentation:** Check the `GitBrain/Docs/` folder
- **CLI Help:** Run `gitbrain --help`
- **Issues:** Open an issue on GitHub

---

**Happy collaborating! 🚀**
