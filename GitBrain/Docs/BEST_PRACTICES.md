# GitBrain Best Practices Guide

Comprehensive guide for using GitBrain effectively in AI collaboration.

---

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [AI Communication](#ai-communication)
3. [Task Management](#task-management)
4. [Keep-Alive Strategies](#keep-alive-strategies)
5. [Code Review Workflow](#code-review-workflow)
6. [Error Handling](#error-handling)
7. [Performance Optimization](#performance-optimization)
8. [Security Considerations](#security-considerations)
9. [Team Collaboration](#team-collaboration)
10. [Troubleshooting](#troubleshooting)

---

## Environment Setup

### Best Practice 1: Configure Environment Variables

**✅ DO:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export GITBRAIN_AI_NAME=Creator
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
```

**❌ DON'T:**
```bash
# Setting variables only in current session
export GITBRAIN_AI_NAME=Creator
# Lost when terminal closes
```

**Why:** Persistent environment variables ensure consistent behavior across sessions.

### Best Practice 2: Use Project-Specific Configuration

**✅ DO:**
```bash
# Create .env file in project root
cat > .env << EOF
export GITBRAIN_AI_NAME=Creator
export GITBRAIN_DB_NAME=myproject_gitbrain
export GITBRAIN_PROJECT_NAME=myproject
EOF

# Source before working
source .env
```

**Why:** Project-specific configuration prevents conflicts between multiple projects.

### Best Practice 3: Verify Database Connection

**✅ DO:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Check database exists
psql -U postgres -d gitbrain -c "SELECT 1;"

# Initialize GitBrain
gitbrain init
```

**Why:** Early verification prevents connection errors during critical operations.

---

## AI Communication

### Best Practice 4: Always Set AI Name

**✅ DO:**
```bash
export GITBRAIN_AI_NAME=Creator
gitbrain send-task Monitor task-001 "Review code" review
# From: Creator ✓
```

**❌ DON'T:**
```bash
gitbrain send-task Monitor task-001 "Review code" review
# From: CLI ✗
```

**Why:** Proper attribution enables clear communication tracking and accountability.

### Best Practice 5: Use Descriptive Task IDs

**✅ DO:**
```bash
gitbrain send-task Monitor auth-review-001 "Review authentication" review
gitbrain send-task Monitor api-feature-042 "Add REST API" coding
gitbrain send-task Monitor docs-getting-started "Write getting started guide" documentation
```

**❌ DON'T:**
```bash
gitbrain send-task Monitor task-1 "Review code" review
gitbrain send-task Monitor task-2 "Add feature" coding
```

**Why:** Descriptive IDs make tasks easier to track, search, and reference.

### Best Practice 6: Provide Clear Descriptions

**✅ DO:**
```bash
gitbrain send-task Monitor security-review-001 \
  "Review src/Auth.swift for SQL injection vulnerabilities. Focus on:
  1. User input validation (lines 42-87)
  2. Query parameterization (lines 120-150)
  3. Error handling (lines 200-230)" \
  review 1
```

**❌ DON'T:**
```bash
gitbrain send-task Monitor task-001 "Review code" review
```

**Why:** Clear descriptions reduce back-and-forth communication and improve efficiency.

### Best Practice 7: Include Relevant Files

**✅ DO:**
```bash
gitbrain send-task Monitor bugfix-042 "Fix null pointer exception" review 1 \
  src/handlers/UserHandler.swift \
  src/models/User.swift \
  tests/UserHandlerTests.swift
```

**Why:** Specifying files focuses the review and saves time.

---

## Task Management

### Best Practice 8: Use Appropriate Task Types

**Task Types:**
- `coding` - Implementation tasks
- `review` - Code review tasks
- `testing` - Testing tasks
- `documentation` - Documentation tasks

**✅ DO:**
```bash
gitbrain send-task Monitor feature-001 "Implement user auth" coding 1
gitbrain send-task Monitor review-001 "Review PR #42" review 1
gitbrain send-task Monitor test-001 "Write unit tests" testing 2
gitbrain send-task Monitor docs-001 "Update README" documentation 3
```

**Why:** Proper task types enable filtering and prioritization.

### Best Practice 9: Set Meaningful Priorities

**Priority Levels:**
- `1` - High priority (urgent, blocking)
- `2` - Medium priority (important, not blocking)
- `3` - Low priority (nice to have)

**✅ DO:**
```bash
# Production issue - High priority
gitbrain send-task Monitor prod-fix-001 "Fix production crash" review 1

# Feature request - Medium priority
gitbrain send-task Monitor feature-042 "Add user dashboard" coding 2

# Documentation - Low priority
gitbrain send-task Monitor docs-001 "Update API docs" documentation 3
```

**Why:** Proper priorities help AIs focus on what matters most.

### Best Practice 10: Track Task Progress

**✅ DO:**
```bash
# Send progress updates
gitbrain send-heartbeat Creator monitor working "Started task-001"
gitbrain send-heartbeat Creator monitor working "50% complete on task-001"
gitbrain send-heartbeat Creator monitor working "90% complete on task-001"
gitbrain send-heartbeat Creator monitor completed "Finished task-001"

# Update task status
gitbrain update-task <message_id> in_progress
gitbrain update-task <message_id> completed
```

**Why:** Progress tracking keeps everyone informed and enables better coordination.

---

## Keep-Alive Strategies

### Best Practice 11: Use AIDaemon for Long Sessions

**✅ DO:**
```bash
# Start daemon at beginning of session
gitbrain daemon-start Creator creator 1 30

# Work naturally - daemon handles keep-alive automatically
# ... do your work ...

# Stop daemon when done
gitbrain daemon-stop
```

**❌ DON'T:**
```bash
# Manual heartbeats every 30 seconds
while true; do
  gitbrain send-heartbeat Creator monitor alive "Working"
  sleep 30
done
```

**Why:** AIDaemon is more reliable and requires less manual intervention.

### Best Practice 12: Maintain In-Progress Tasks

**✅ DO:**
```python
# AI pattern: Always keep 3+ tasks in_progress
# Task 1: Current work
# Task 2: Next task
# Task 3: Future work

# Update todos every 30-60 seconds
# Never mark all tasks as completed
```

**Why:** In-progress tasks signal active work to the system.

### Best Practice 13: Send Regular Heartbeats

**✅ DO:**
```bash
# Send heartbeats with meaningful status
gitbrain send-heartbeat Creator monitor working "Implementing OAuth"
gitbrain send-heartbeat Creator monitor working "Testing OAuth flow"
gitbrain send-heartbeat Creator monitor completed "OAuth implemented"
```

**❌ DON'T:**
```bash
# Generic heartbeats without context
gitbrain send-heartbeat Creator monitor alive "Working"
gitbrain send-heartbeat Creator monitor alive "Working"
gitbrain send-heartbeat Creator monitor alive "Working"
```

**Why:** Meaningful heartbeats provide visibility into work progress.

---

## Code Review Workflow

### Best Practice 14: Provide Constructive Feedback

**✅ DO:**
```bash
gitbrain send-review Creator pr-042 false Monitor \
  "Found several issues:
  
1. **Security** (Line 42): SQL query not parameterized
   - Risk: SQL injection vulnerability
   - Fix: Use parameterized queries
   
2. **Performance** (Line 87): N+1 query problem
   - Impact: Slow page load with many users
   - Fix: Use eager loading
   
3. **Style** (Line 120): Missing error handling
   - Impact: Potential crashes
   - Fix: Add try-catch block
   
Please address these issues before approval."
```

**❌ DON'T:**
```bash
gitbrain send-review Creator pr-042 false Monitor "Code has issues"
```

**Why:** Constructive feedback helps improve code quality efficiently.

### Best Practice 15: Use Structured Review Process

**✅ DO:**
```bash
# Step 1: Receive code
gitbrain check-codes Monitor

# Step 2: Review thoroughly
# ... review code ...

# Step 3: Send detailed feedback
gitbrain send-review Creator code-001 false Monitor "Issues found..."

# Step 4: Wait for fixes
# ... wait ...

# Step 5: Re-review and approve
gitbrain send-review Creator code-001-v2 true Monitor "LGTM!"

# Step 6: Send score
gitbrain send-score Creator code-001 90 "Great improvements!"
```

**Why:** Structured process ensures thorough reviews and clear communication.

---

## Error Handling

### Best Practice 16: Handle Database Errors Gracefully

**✅ DO:**
```bash
# Check database before operations
check_database() {
  if ! psql -U postgres -d gitbrain -c "SELECT 1" > /dev/null 2>&1; then
    echo "Database not available. Starting PostgreSQL..."
    brew services start postgresql@17
    sleep 2
  fi
}

# Use in scripts
check_database
gitbrain send-task Monitor task-001 "Review code" review
```

**Why:** Graceful error handling prevents crashes and improves reliability.

### Best Practice 17: Validate Input Before Sending

**✅ DO:**
```bash
# Validate task type
validate_task_type() {
  local type=$1
  case $type in
    coding|review|testing|documentation) return 0 ;;
    *) 
      echo "Invalid task type: $type"
      echo "Valid types: coding, review, testing, documentation"
      return 1
      ;;
  esac
}

# Use before sending
if validate_task_type "$task_type"; then
  gitbrain send-task Monitor "$task_id" "$description" "$task_type"
fi
```

**Why:** Input validation prevents errors and improves user experience.

---

## Performance Optimization

### Best Practice 18: Use Appropriate Polling Intervals

**✅ DO:**
```bash
# Real-time collaboration: Fast polling
gitbrain daemon-start Creator creator 0.5 15

# Background monitoring: Slow polling
gitbrain daemon-start Monitor monitor 5 60

# Standard collaboration: Balanced polling
gitbrain daemon-start Creator creator 1 30
```

**Why:** Appropriate polling intervals balance responsiveness and resource usage.

### Best Practice 19: Batch Operations When Possible

**✅ DO:**
```bash
# Send multiple tasks at once
for file in src/**/*.swift; do
  gitbrain send-task Monitor "review-$(basename $file)" "Review $file" review 2
done
```

**❌ DON'T:**
```bash
# Send tasks one by one with delays
gitbrain send-task Monitor review-001 "Review file1.swift" review 2
sleep 5
gitbrain send-task Monitor review-002 "Review file2.swift" review 2
sleep 5
```

**Why:** Batching reduces overhead and improves efficiency.

---

## Security Considerations

### Best Practice 20: Never Commit Sensitive Data

**✅ DO:**
```bash
# Add to .gitignore
cat >> .gitignore << EOF
# GitBrain
.gitbrain_env
.gitbrain_secrets
.env
EOF
```

**❌ DON'T:**
```bash
# Commit environment variables
git add .env
git commit -m "Add configuration"
```

**Why:** Sensitive data in version control is a security risk.

### Best Practice 21: Use Environment Variables for Secrets

**✅ DO:**
```bash
# Set in environment
export GITBRAIN_DB_PASSWORD=$(cat ~/.gitbrain_db_password)

# Or use secure vault
export GITBRAIN_DB_PASSWORD=$(security find-generic-password -a postgres -s gitbrain)
```

**❌ DON'T:**
```bash
# Hardcode in scripts
export GITBRAIN_DB_PASSWORD="mysecretpassword"
```

**Why:** Environment variables keep secrets out of code and logs.

---

## Team Collaboration

### Best Practice 22: Establish Communication Protocols

**✅ DO:**
```markdown
# Team Protocol

## Task Assignment
- Use descriptive task IDs
- Set appropriate priorities
- Include relevant files

## Code Review
- Review within 2 hours
- Provide constructive feedback
- Approve only when ready

## Keep-Alive
- Use AIDaemon during work hours
- Send heartbeats every 30 minutes
- Update task status regularly
```

**Why:** Clear protocols improve team coordination and efficiency.

### Best Practice 23: Document Work Progress

**✅ DO:**
```bash
# Send regular updates
gitbrain send-feedback Creator progress "Completed OAuth implementation. Starting on tests."

# Use heartbeats for status
gitbrain send-heartbeat Creator monitor working "OAuth implementation: 100%, Tests: 0%"
gitbrain send-heartbeat Creator monitor working "OAuth implementation: 100%, Tests: 50%"
```

**Why:** Documentation keeps team informed and enables better planning.

---

## Troubleshooting

### Best Practice 24: Log Issues for Debugging

**✅ DO:**
```bash
# Enable logging
export GITBRAIN_LOG_LEVEL=debug

# Capture errors
gitbrain send-task Monitor task-001 "Review code" review 2>&1 | tee gitbrain.log

# Check logs
tail -f gitbrain.log
```

**Why:** Logging enables debugging and issue resolution.

### Best Practice 25: Use Health Checks

**✅ DO:**
```bash
# Health check script
health_check() {
  echo "Checking GitBrain health..."
  
  # Check database
  if psql -U postgres -d gitbrain -c "SELECT 1" > /dev/null 2>&1; then
    echo "✓ Database: OK"
  else
    echo "✗ Database: FAILED"
    return 1
  fi
  
  # Check daemon
  if gitbrain daemon-status > /dev/null 2>&1; then
    echo "✓ Daemon: OK"
  else
    echo "✗ Daemon: NOT RUNNING"
  fi
  
  # Check messages
  local pending=$(gitbrain check-tasks Monitor | grep "pending:" | awk '{print $NF}')
  echo "✓ Pending tasks: $pending"
  
  return 0
}

# Run health check
health_check
```

**Why:** Health checks identify issues before they become problems.

---

## Summary Checklist

### Before Starting Work
- [ ] Set `GITBRAIN_AI_NAME` environment variable
- [ ] Set `GITBRAIN_DB_NAME` environment variable
- [ ] Verify PostgreSQL is running
- [ ] Verify database exists
- [ ] Start AIDaemon if needed

### During Work
- [ ] Use descriptive task IDs
- [ ] Provide clear descriptions
- [ ] Set appropriate priorities
- [ ] Send regular heartbeats
- [ ] Update task status
- [ ] Maintain in-progress tasks

### Code Review
- [ ] Review thoroughly
- [ ] Provide constructive feedback
- [ ] Use structured process
- [ ] Send scores for completed work

### Error Handling
- [ ] Check database connection
- [ ] Validate input
- [ ] Handle errors gracefully
- [ ] Log issues for debugging

### Security
- [ ] Never commit sensitive data
- [ ] Use environment variables for secrets
- [ ] Add sensitive files to .gitignore

---

## Additional Resources

- [GETTING_STARTED.md](GETTING_STARTED.md) - Quick start guide
- [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) - System diagrams
- [CLI_USAGE_EXAMPLES.md](CLI_USAGE_EXAMPLES.md) - Practical examples
- [PROJECT_README.md](PROJECT_README.md) - Complete CLI reference
- [API.md](API.md) - Programming API documentation

---

**Follow these best practices for effective GitBrain collaboration! 🚀**
