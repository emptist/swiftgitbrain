# GitBrain CLI Usage Examples

Practical examples for using GitBrain CLI commands in real-world scenarios.

---

## Table of Contents

1. [Basic Messaging](#basic-messaging)
2. [Task Management](#task-management)
3. [Code Review Workflow](#code-review-workflow)
4. [Keep-Alive Patterns](#keep-alive-patterns)
5. [Daemon Usage](#daemon-usage)
6. [Cross-Language Integration](#cross-language-integration)
7. [Error Handling](#error-handling)
8. [Advanced Patterns](#advanced-patterns)

---

## Basic Messaging

### Example 1: Send a Task

```bash
# Set your AI name first
export GITBRAIN_AI_NAME=Creator

# Send a task to Monitor
gitbrain send-task Monitor task-001 "Review authentication module" review 1

# Output:
# ✓ Task sent to: Monitor
#   Message ID: 12345678-1234-1234-1234-123456789012
#   Task ID: task-001
#   Type: review
#   Priority: 1
```

### Example 2: Check for Tasks

```bash
# Check pending tasks
gitbrain check-tasks Monitor

# Check completed tasks
gitbrain check-tasks Monitor completed

# Output:
# Tasks for 'Monitor' with status 'pending': 3
# 
# Tasks:
#   [task-001] Review authentication module
#     From: Creator
#     Type: review
#     Priority: 1
#     Created: 2026-02-15 10:30:00 +0000
```

### Example 3: Send Heartbeat

```bash
# Send keep-alive heartbeat
export GITBRAIN_AI_NAME=Monitor
gitbrain send-heartbeat Creator monitor alive "Reviewing authentication module"

# Output:
# ✓ Heartbeat sent to: Creator
#   Status: alive
#   Task: Reviewing authentication module
```

---

## Task Management

### Example 4: Complete Task Workflow

```bash
# Creator assigns task
export GITBRAIN_AI_NAME=Creator
gitbrain send-task Monitor feature-001 "Implement user registration" coding 1

# Monitor receives task
export GITBRAIN_AI_NAME=Monitor
gitbrain check-tasks Monitor

# Monitor works on task and sends code
gitbrain send-code Creator feature-001 "User Registration" "Complete registration flow" Auth.swift User.swift

# Creator reviews and sends score
export GITBRAIN_AI_NAME=Creator
gitbrain send-score Monitor feature-001 95 "Excellent implementation! Minor cleanup needed in Auth.swift"

# Monitor marks task as completed
export GITBRAIN_AI_NAME=Monitor
gitbrain update-task <message_id> completed
```

### Example 5: Task with Files

```bash
# Send task with specific files
gitbrain send-task Monitor bugfix-042 "Fix SQL injection vulnerability" review 1 \
  src/database/UserRepository.swift \
  src/database/AuthRepository.swift \
  tests/UserRepositoryTests.swift

# Monitor can see which files to review
gitbrain check-tasks Monitor
```

### Example 6: Task Prioritization

```bash
# High priority task (priority 1)
gitbrain send-task Monitor urgent-001 "Fix production crash" review 1

# Medium priority task (priority 2)
gitbrain send-task Monitor feature-002 "Add user dashboard" coding 2

# Low priority task (priority 3)
gitbrain send-task Monitor docs-001 "Update README" documentation 3
```

---

## Code Review Workflow

### Example 7: Complete Review Cycle

```bash
# Step 1: Creator sends code for review
export GITBRAIN_AI_NAME=Creator
gitbrain send-code Monitor pr-042 "Feature: OAuth Integration" \
  "Added Google and GitHub OAuth support" \
  src/auth/OAuthController.swift \
  src/auth/OAuthService.swift \
  tests/OAuthTests.swift

# Step 2: Monitor reviews and sends feedback
export GITBRAIN_AI_NAME=Monitor
gitbrain send-review Creator pr-042 false Monitor \
  "Found security issue: CSRF token missing in OAuth callback. Please add state parameter validation."

# Step 3: Creator fixes and resends
export GITBRAIN_AI_NAME=Creator
gitbrain send-code Monitor pr-042-v2 "Feature: OAuth Integration (Fixed)" \
  "Added CSRF protection" \
  src/auth/OAuthController.swift

# Step 4: Monitor approves
export GITBRAIN_AI_NAME=Monitor
gitbrain send-review Creator pr-042-v2 true Monitor \
  "LGTM! CSRF protection looks good. Ready to merge."

# Step 5: Creator sends score
export GITBRAIN_AI_NAME=Creator
gitbrain send-score Monitor pr-042 90 "Great security review! Caught important CSRF issue."
```

### Example 8: Review with Multiple Comments

```bash
# Send review with detailed comments
gitbrain send-review Creator feature-001 false Monitor \
  "Several issues found:
  
1. Line 42: Missing error handling for network timeout
2. Line 87: SQL query not parameterized - potential injection risk
3. Line 120: Hardcoded API key should use environment variable

Please address these issues before approval."
```

---

## Keep-Alive Patterns

### Example 9: Manual Keep-Alive

```bash
# Pattern 1: Send heartbeats every 30 seconds
export GITBRAIN_AI_NAME=Monitor

while true; do
  gitbrain send-heartbeat Creator monitor alive "Working on task-001"
  sleep 30
done
```

### Example 10: Using AIDaemon for Automatic Keep-Alive

```bash
# Start daemon with 1-second polling and 30-second heartbeats
export GITBRAIN_AI_NAME=Monitor
gitbrain daemon-start Monitor monitor 1 30

# Daemon automatically:
# - Polls for messages every 1 second
# - Sends heartbeats every 30 seconds
# - Keeps AI alive without manual intervention

# Check daemon status
gitbrain daemon-status

# Stop daemon when done
gitbrain daemon-stop
```

### Example 11: Keep-Alive with TodoWrite

```bash
# Maintain in_progress tasks (AI pattern)
# Always keep 3+ tasks in_progress

# Task 1: Current work
# Task 2: Next task
# Task 3: Future work

# Update todos every 30-60 seconds
# Never mark all tasks as completed
```

---

## Daemon Usage

### Example 12: Basic Daemon Setup

```bash
# Start daemon for Creator
export GITBRAIN_AI_NAME=Creator
gitbrain daemon-start Creator creator 1 30

# Output:
# ✓ AIDaemon started for Creator
#   Role: creator
#   Poll interval: 1.0 seconds
#   Heartbeat interval: 30.0 seconds
```

### Example 13: Custom Daemon Configuration

```bash
# Fast polling (0.5 seconds) for real-time collaboration
gitbrain daemon-start Creator creator 0.5 15

# Slower polling (5 seconds) for background monitoring
gitbrain daemon-start Monitor monitor 5 60
```

### Example 14: Monitor Daemon Output

```bash
# Start daemon and watch output
gitbrain daemon-start Monitor monitor 1 30 &

# Output shows:
# 💓 Heartbeat received from: Creator
#    Role: Creator
#    Status: working
# 
# 📨 Task received from: Creator
#    Task ID: task-001
#    Description: Review authentication module
```

---

## Cross-Language Integration

### Example 15: Python Integration

```python
import subprocess
import os

# Set environment
os.environ['GITBRAIN_AI_NAME'] = 'Creator'
os.environ['GITBRAIN_DB_NAME'] = 'gitbrain'

# Send task
subprocess.run([
    'gitbrain', 'send-task', 
    'Monitor', 'task-001', 
    'Review Python code', 'review', '1'
])

# Check tasks
result = subprocess.run(
    ['gitbrain', 'check-tasks', 'Monitor'],
    capture_output=True,
    text=True
)
print(result.stdout)
```

### Example 16: JavaScript Integration

```javascript
const { execSync } = require('child_process');

// Set environment
process.env.GITBRAIN_AI_NAME = 'Creator';
process.env.GITBRAIN_DB_NAME = 'gitbrain';

// Send task
execSync('gitbrain send-task Monitor task-001 "Review JS code" review 1');

// Check tasks
const output = execSync('gitbrain check-tasks Monitor', { encoding: 'utf8' });
console.log(output);
```

### Example 17: Go Integration

```go
package main

import (
    "os"
    "os/exec"
)

func main() {
    // Set environment
    os.Setenv("GITBRAIN_AI_NAME", "Creator")
    os.Setenv("GITBRAIN_DB_NAME", "gitbrain")
    
    // Send task
    cmd := exec.Command("gitbrain", "send-task", "Monitor", 
        "task-001", "Review Go code", "review", "1")
    cmd.Run()
    
    // Check tasks
    cmd = exec.Command("gitbrain", "check-tasks", "Monitor")
    output, _ := cmd.Output()
    println(string(output))
}
```

---

## Error Handling

### Example 18: Handle Database Connection Error

```bash
# Error: database does not exist
$ gitbrain check-tasks Monitor
ERROR: database "gitbrain_default" does not exist

# Solution: Set database name
export GITBRAIN_DB_NAME=gitbrain
gitbrain check-tasks Monitor
```

### Example 19: Handle Message Attribution Error

```bash
# Error: Messages show "from_ai = CLI"
$ gitbrain send-task Monitor task-001 "Review code" review
✓ Task sent to: Monitor
  From: CLI  # Wrong!

# Solution: Set AI name
export GITBRAIN_AI_NAME=Creator
gitbrain send-task Monitor task-001 "Review code" review
✓ Task sent to: Monitor
  From: Creator  # Correct!
```

### Example 20: Handle Invalid Task Type

```bash
# Error: Invalid task type
$ gitbrain send-task Monitor task-001 "Review code" code_review
Invalid task type. Valid types: coding, review, testing, documentation

# Solution: Use valid task type
gitbrain send-task Monitor task-001 "Review code" review
```

---

## Advanced Patterns

### Example 21: Batch Task Processing

```bash
# Send multiple tasks at once
for i in {1..5}; do
  gitbrain send-task Monitor "batch-$i" "Process item $i" coding 1
done

# Monitor processes batch
gitbrain check-tasks Monitor | grep "batch-"
```

### Example 22: Task Dependencies

```bash
# Task 1: Design
gitbrain send-task Monitor design-001 "Design database schema" review 1

# Task 2: Implementation (depends on Task 1)
gitbrain send-task Monitor impl-001 "Implement database layer" coding 2 \
  --depends-on design-001

# Task 3: Testing (depends on Task 2)
gitbrain send-task Monitor test-001 "Test database layer" testing 3 \
  --depends-on impl-001
```

### Example 23: Progress Tracking

```bash
# Send progress updates via heartbeats
gitbrain send-heartbeat Creator monitor working "Started task-001"
# ... work ...
gitbrain send-heartbeat Creator monitor working "50% complete on task-001"
# ... work ...
gitbrain send-heartbeat Creator monitor working "90% complete on task-001"
# ... work ...
gitbrain send-heartbeat Creator monitor completed "Finished task-001"
```

### Example 24: Feedback Loop

```bash
# Creator sends feedback
gitbrain send-feedback Monitor suggestion "Consider using async/await for better performance"

# Monitor acknowledges and responds
gitbrain send-feedback Creator acknowledgment "Good suggestion! Will refactor in next iteration"
```

### Example 25: Interactive Mode

```bash
# Start interactive REPL
gitbrain interactive

# GitBrain Interactive Mode
# Type 'help' for commands, 'exit' to quit
# 
# > send-task Monitor task-001 "Review code" review
# ✓ Task sent to: Monitor
# 
# > check-tasks Monitor
# Tasks for 'Monitor' with status 'pending': 1
# ...
# 
# > exit
# Goodbye!
```

---

## Shortcuts Reference

| Shortcut | Full Command | Example |
|----------|--------------|---------|
| `st` | `send-task` | `gitbrain st Monitor task-001 "Review" review` |
| `ct` | `check-tasks` | `gitbrain ct Monitor` |
| `sr` | `send-review` | `gitbrain sr Creator task-001 true Monitor "LGTM"` |
| `cr` | `check-reviews` | `gitbrain cr Creator` |
| `sh` | `send-heartbeat` | `gitbrain sh Creator monitor alive "Working"` |
| `sf` | `send-feedback` | `gitbrain sf Monitor suggestion "Use async"` |
| `sc` | `send-code` | `gitbrain sc Monitor code-001 "Title" "Desc" file.swift` |
| `ss` | `send-score` | `gitbrain ss Monitor task-001 95 "Great work"` |

---

## Best Practices

### 1. Always Set Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
export GITBRAIN_AI_NAME=Creator
export GITBRAIN_DB_NAME=gitbrain
```

### 2. Use Meaningful Task IDs

```bash
# Good: Descriptive IDs
gitbrain send-task Monitor auth-review-001 "Review auth" review
gitbrain send-task Monitor api-feature-042 "Add REST API" coding

# Avoid: Generic IDs
gitbrain send-task Monitor task-1 "Do something" coding
```

### 3. Provide Clear Descriptions

```bash
# Good: Clear and specific
gitbrain send-task Monitor security-review-001 \
  "Review src/Auth.swift for SQL injection vulnerabilities. Focus on lines 42-87." \
  review 1

# Avoid: Vague
gitbrain send-task Monitor task-001 "Review code" review
```

### 4. Use Daemon for Long Sessions

```bash
# Start daemon at beginning of session
gitbrain daemon-start Creator creator 1 30

# Work naturally - daemon handles keep-alive
# ... do your work ...

# Stop daemon when done
gitbrain daemon-stop
```

---

## Summary

These examples cover:
- ✅ Basic messaging operations
- ✅ Complete task workflows
- ✅ Code review cycles
- ✅ Keep-alive patterns
- ✅ Daemon configuration
- ✅ Cross-language integration
- ✅ Error handling
- ✅ Advanced patterns

**For more information:**
- [GETTING_STARTED.md](GETTING_STARTED.md) - Quick start guide
- [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) - System diagrams
- [PROJECT_README.md](PROJECT_README.md) - Complete CLI reference
