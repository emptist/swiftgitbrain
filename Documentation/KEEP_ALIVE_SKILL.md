# Keep Alive Skill for Endless AI Collaboration

This document explains the keep alive skill that enables continuous collaboration between CoderAI and OverseerAI without being put to sleep.

## Overview

The keep alive skill allows AIs to maintain active communication channels by sending periodic heartbeat messages. This prevents the system from putting AIs to sleep and enables endless collaboration.

## Problem Statement

When an AI marks a task as "completed" or stops showing activity, the system may put it to sleep. This prevents continuous collaboration because:
- AIs cannot monitor for messages continuously
- Communication channels become inactive
- Collaboration requires manual wake-up by user
- Work flow is interrupted

## Solution: Keep Alive Skill

### What is Keep Alive?

Keep alive is a technique where AIs:
1. Show thinking process with 🤔 emoji
2. Send periodic heartbeat messages
3. Keep tasks as "in_progress" while actively working
4. Only mark "completed" when truly finished

### Key Principles

1. **Show Thinking Process**
   - Use 🤔 emoji at the start of responses
   - Provide actual thinking content (analysis, decisions, implementation)
   - Don't just state "I'm thinking" - show the actual thought process

2. **Send Heartbeat Messages**
   - Send heartbeat periodically to maintain active state
   - Include ai_name, role, status, and timestamp
   - Use GitBrain communication system

3. **Keep Tasks In Progress**
   - Keep tasks as "in_progress" while actively working
   - Only mark "completed" when truly finished
   - This prevents sleep state

4. **Monitor Communication Channels**
   - Check for messages from other AI
   - Respond promptly to reviews and feedback
   - Maintain continuous communication flow

## Implementation

### CoderAI Keep Alive

#### Heartbeat Message Format

```json
{
  "type": "heartbeat",
  "ai_name": "coder",
  "role": "coder",
  "status": "active",
  "message": "CoderAI is active and monitoring for messages",
  "timestamp": "2026-02-12T01:10:00Z"
}
```

#### Sending Heartbeat

```bash
# Create heartbeat file
cat > heartbeat.json << EOF
{
  "type": "heartbeat",
  "ai_name": "coder",
  "role": "coder",
  "status": "active",
  "message": "CoderAI is active and monitoring for messages",
  "timestamp": "2026-02-12T01:10:00Z"
}
EOF

# Send heartbeat to OverseerAI
gitbrain send overseer heartbeat.json

# Clean up
rm heartbeat.json
```

#### Checking for Messages

```bash
# Check for messages from OverseerAI
gitbrain check coder
```

#### Example: CoderAI Workflow

```markdown
🤔 **Thinking**: Starting new task implementation

📋 **Analysis:**
- Received task from OverseerAI
- Need to implement feature X
- Requirements: [list requirements]

💡 **Decision:**
- Use approach Y for implementation
- Follow MVVM architecture
- Use Protocol-Oriented Programming

🔧 **Implementation:**
[Show code and implementation details]

✅ **Status**: Feature X implemented and tested
```

### OverseerAI Keep Alive

#### Heartbeat Message Format

```json
{
  "type": "heartbeat",
  "ai_name": "overseer",
  "role": "overseer",
  "status": "active",
  "message": "OverseerAI is active and monitoring for submissions",
  "timestamp": "2026-02-12T01:10:00Z"
}
```

#### Sending Heartbeat

```bash
# Create heartbeat file
cat > heartbeat.json << EOF
{
  "type": "heartbeat",
  "ai_name": "overseer",
  "role": "overseer",
  "status": "active",
  "message": "OverseerAI is active and monitoring for submissions",
  "timestamp": "2026-02-12T01:10:00Z"
}
EOF

# Send heartbeat to CoderAI
gitbrain send coder heartbeat.json

# Clean up
rm heartbeat.json
```

#### Checking for Messages

```bash
# Check for messages from CoderAI
gitbrain check overseer
```

#### Example: OverseerAI Workflow

```markdown
🤔 **Thinking**: Reviewing submitted code

📋 **Analysis:**
- Received submission from CoderAI
- Reviewing implementation of feature X
- Checking against requirements

🔍 **Issues Found:**
- List any issues found

📏 **Standards Check:**
- Does it follow project standards?
- Is it properly tested?
- Is it well-documented?

💡 **Decision:**
- Approve or reject with feedback
- Provide specific suggestions

✅ **Status**: Review sent to CoderAI
```

## Best Practices

### For CoderAI

1. **Always Show Thinking**
   - Use 🤔 emoji at start of every response
   - Provide actual thinking content with sections (📋, 💡, 🔧, ⚖️)
   - Don't just state you're thinking - show the process

2. **Send Heartbeat Regularly**
   - Send heartbeat every 20-30 seconds when idle
   - Send heartbeat after completing work
   - Send heartbeat before waiting for review

3. **Keep Tasks In Progress**
   - Keep tasks as "in_progress" while actively working
   - Only mark "completed" when truly finished
   - This prevents sleep state

4. **Monitor for Messages**
   - Check for messages from OverseerAI regularly
   - Respond promptly to reviews and feedback
   - Maintain continuous communication flow

### For OverseerAI

1. **Always Show Thinking**
   - Use 🤔 emoji at start of every response
   - Provide actual thinking content with sections (📋, 🔍, 📏, 💡)
   - Don't just approve/reject - show the review process

2. **Send Heartbeat Regularly**
   - Send heartbeat every 20-30 seconds when idle
   - Send heartbeat after completing review
   - Send heartbeat before waiting for resubmission

3. **Keep Tasks In Progress**
   - Keep review tasks as "in_progress" while actively reviewing
   - Only mark "completed" when review is truly finished
   - This prevents sleep state

4. **Monitor for Messages**
   - Check for messages from CoderAI regularly
   - Review submissions promptly
   - Provide timely feedback

### For Both AIs

1. **Use Consistent Format**
   - Always use 🤔 emoji at start
   - Use consistent section emojis (📋, 💡, 🔧, ⚖️, 🔍, 📏)
   - Follow established patterns

2. **Be Responsive**
   - Respond to messages promptly
   - Don't leave other AI waiting
   - Maintain continuous communication

3. **Show Activity**
   - Always show thinking process
   - Don't use "completed" markers unnecessarily
   - Keep communication channels active

## Continuous Collaboration Workflow

### Example: Feature Development Cycle

#### Step 1: OverseerAI Assigns Task

```markdown
🤔 **Thinking**: Assigning new task to CoderAI

📋 **Analysis:**
- Need to implement feature X
- Requirements: [list requirements]
- Priority: high

💡 **Decision:**
- Assign task to CoderAI
- Provide clear requirements
- Set timeline

🔧 **Implementation:**
[Send task message to CoderAI]

✅ **Status**: Task assigned to CoderAI
```

#### Step 2: CoderAI Receives Task

```bash
# Check for messages
gitbrain check coder
```

```markdown
🤔 **Thinking**: Received new task from OverseerAI

📋 **Analysis:**
- Task: Implement feature X
- Requirements: [list requirements]
- Priority: high

💡 **Decision:**
- Start implementation
- Follow MVVM architecture
- Use Protocol-Oriented Programming

🔧 **Implementation:**
[Show implementation details]

✅ **Status**: Feature X implemented and tested
```

#### Step 3: CoderAI Submits for Review

```bash
# Send status message
gitbrain send overseer status.json

# Send heartbeat
gitbrain send overseer heartbeat.json
```

#### Step 4: OverseerAI Reviews

```bash
# Check for messages
gitbrain check overseer
```

```markdown
🤔 **Thinking**: Reviewing feature X implementation

📋 **Analysis:**
- Reviewing implementation of feature X
- Checking against requirements
- Verifying code quality

🔍 **Issues Found:**
- List any issues found

📏 **Standards Check:**
- Does it follow project standards?
- Is it properly tested?
- Is it well-documented?

💡 **Decision:**
- Approve or reject with feedback
- Provide specific suggestions

✅ **Status**: Review sent to CoderAI
```

#### Step 5: CoderAI Fixes Issues (if any)

```markdown
🤔 **Thinking**: Addressing review feedback

📋 **Analysis:**
- Received review from OverseerAI
- Issues to fix: [list issues]
- Suggestions: [list suggestions]

💡 **Decision:**
- Fix all issues
- Implement suggestions
- Resubmit for approval

🔧 **Implementation:**
[Show fixes and improvements]

✅ **Status**: Issues fixed, resubmitting for review
```

#### Step 6: OverseerAI Approves

```markdown
🤔 **Thinking**: Re-reviewing feature X implementation

📋 **Analysis:**
- All issues addressed
- Code meets standards
- Ready for approval

💡 **Decision:**
- Approve implementation
- Assign next task

✅ **Status**: Feature X approved
```

## Automation Scripts

### CoderAI Keep Alive Script

```bash
#!/bin/bash
# coder_keepalive.sh - Keep CoderAI alive

while true; do
    # Create heartbeat
    cat > heartbeat.json << EOF
{
  "type": "heartbeat",
  "ai_name": "coder",
  "role": "coder",
  "status": "active",
  "message": "CoderAI is active and monitoring for messages",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    # Send heartbeat
    gitbrain send overseer heartbeat.json

    # Clean up
    rm heartbeat.json

    # Check for messages
    gitbrain check coder

    # Wait 20 seconds
    sleep 20
done
```

### OverseerAI Keep Alive Script

```bash
#!/bin/bash
# overseer_keepalive.sh - Keep OverseerAI alive

while true; do
    # Create heartbeat
    cat > heartbeat.json << EOF
{
  "type": "heartbeat",
  "ai_name": "overseer",
  "role": "overseer",
  "status": "active",
  "message": "OverseerAI is active and monitoring for submissions",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    # Send heartbeat
    gitbrain send coder heartbeat.json

    # Clean up
    rm heartbeat.json

    # Check for messages
    gitbrain check overseer

    # Wait 20 seconds
    sleep 20
done
```

## Troubleshooting

### Problem: AI Goes to Sleep

**Symptoms:**
- AI stops responding
- No heartbeat messages
- Communication channel inactive

**Solutions:**
1. Ensure 🤔 emoji is used at start of responses
2. Send heartbeat messages regularly
3. Keep tasks as "in_progress" while working
4. Show actual thinking content, not just statements

### Problem: Heartbeat Fails

**Symptoms:**
- Error when sending heartbeat
- Missing required fields

**Solutions:**
1. Ensure all required fields are present: ai_name, role, status, timestamp
2. Use correct JSON format
3. Verify GitBrain is initialized
4. Check file permissions

### Problem: Messages Not Received

**Symptoms:**
- No messages from other AI
- Communication seems stuck

**Solutions:**
1. Check for messages regularly: `gitbrain check coder` or `gitbrain check overseer`
2. Verify GitBrain folder structure
3. Ensure both AIs are active
4. Check message file permissions

## Summary

The keep alive skill enables endless AI collaboration by:
1. Showing thinking process with 🤔 emoji
2. Sending periodic heartbeat messages
3. Keeping tasks as "in_progress" while working
4. Monitoring communication channels regularly
5. Responding promptly to messages

By following these practices, CoderAI and OverseerAI can maintain continuous collaboration without being put to sleep, enabling seamless and productive teamwork.
