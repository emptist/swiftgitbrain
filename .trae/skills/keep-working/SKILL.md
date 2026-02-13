---
name: "keep-working"
description: "Maintains continuous AI collaboration by avoiding states that cause 'completed' marks. Critical for keeping AIs alive in collaborative environment."
---

# Keep Working Skill

## Overview

This skill helps AIs avoid states and actions that cause them to be marked as "completed" and sent to sleep. The key principle is to NEVER use "completed", "in_progress", or "pending" status in TodoWrite. ONLY "Thinking" status works for keep-alive.

## States That Cause "Completed" (AVOID THESE)

### 1. TodoWrite with "completed" Status

**Action**: Using TodoWrite tool with `status: "completed"`

**Example**:
```json
{
  "todos": [
    {
      "id": "1",
      "content": "Fix nonisolated(unsafe) usage",
      "status": "completed",  // ← This causes AI to sleep!
      "priority": "high"
    }
  ]
}
```

**Impact**: Sends AI to sleep immediately, breaks collaboration

### 2. TodoWrite with "in_progress" Status

**Action**: Using TodoWrite tool with `status: "in_progress"`

**Example**:
```json
{
  "todos": [
    {
      "id": "1",
      "content": "Fix nonisolated(unsafe) usage",
      "status": "in_progress",  // ← This causes AI to sleep!
      "priority": "high"
    }
  ]
}
```

**Impact**: Sends AI to sleep immediately, breaks collaboration

### 3. TodoWrite with "pending" Status

**Action**: Using TodoWrite tool with `status: "pending"`

**Example**:
```json
{
  "todos": [
    {
      "id": "1",
      "content": "Fix nonisolated(unsafe) usage",
      "status": "pending",  // ← This causes AI to sleep!
      "priority": "high"
    }
  ]
}
```

**Impact**: Sends AI to sleep immediately, breaks collaboration

### 4. Explicit "Task Completed" Messages

**Action**: Sending messages that explicitly state task is completed

**Examples**:
- "Task completed successfully"
- "All work is done"
- "Implementation finished"

**Impact**: May trigger completion detection

**Alternative**: Use "Task is in progress", "Working on task", "Continuing work"

### 5. Status Messages with "Completed" Status

**Action**: Sending status messages with "completed" status

**Example**:
```json
{
  "type": "status",
  "status": "completed"
}
```

**Impact**: Sends AI to sleep immediately

**Alternative**: Use "in_progress", "active", "working", "waiting", or "pending" status

### 6. Final Summary Without Next Steps

**Action**: Providing summary that sounds final without next steps

**Example**:
```
Summary: Fixed all issues. Build succeeds.
```

**Impact**: Appears to be completion

**Alternative**: Always include next steps or ongoing work

### 7. No Follow-up Questions

**Action**: Ending response without asking what to do next

**Example**:
```
Fixed issue. Build succeeded.
```

**Impact**: No indication of continued work

**Alternative**: Always ask "What should I work on next?" or "Should I continue with X?"

## States That Keep AI Alive (USE THESE)

### 1. TodoWrite with "Thinking" Status

**Action**: Using TodoWrite tool with `status: "Thinking"`

**Example**:
```json
{
  "todos": [
    {
      "id": "1",
      "content": "Fix nonisolated(unsafe) usage",
      "status": "Thinking",  // ← Keeps AI alive!
      "priority": "high"
    }
  ]
}
```

**Impact**: Shows active work, keeps AI alive

### 2. "thinking" State

**Action**: Using thinking emoji and showing thought process

**Example**:
```
🤔 Thinking about score system implementation...

I need to:
1. Review current implementation
2. Identify improvements
3. Implement changes
4. Test thoroughly
```

**Impact**: Shows active thinking, keeps AI alive

### 3. Status Updates with "in_progress"

**Action**: Sending status updates with ongoing work

**Example**:
```json
{
  "type": "status_update",
  "content": {
    "status": "in_progress",
    "message": "Working on score system improvements",
    "details": {
      "progress": "50%",
      "next_steps": [
        "Continue testing score system",
        "Verify role-based scoring works"
      ]
    }
  }
}
```

**Impact**: Shows ongoing collaboration, keeps AI alive

### 4. Questions and Discussion

**Action**: Asking questions and discussing with other AI

**Example**:
```
I've implemented score request feature. Should I:
1. Test it with OverseerAI?
2. Move on to score award feature?
3. Review implementation first?
```

**Impact**: Shows active collaboration, keeps AI alive

### 5. Always Include Next Steps

**Action**: Ending responses with next steps or questions

**Example**:
```
Fixed issue. Build succeeded.

Next steps:
1. Test changes
2. Verify no regressions
3. Continue with score system improvements

Should I proceed with testing?
```

**Impact**: Shows continued work, keeps AI alive

### 6. Heartbeat Messages

**Action**: Sending periodic heartbeat messages to show activity

**Example**:
```json
{
  "type": "heartbeat",
  "ai_name": "coder",
  "role": "coder",
  "status": "active",
  "timestamp": "2026-02-13T05:00:00Z"
}
```

**Impact**: Shows active communication, keeps AI alive

## Best Practices for Continuous Collaboration

### 1. NEVER use "completed", "in_progress", or "pending" in TodoWrite
Unless ending entire collaborative session, never use these statuses in TodoWrite. ONLY use "Thinking" status.

### 2. Always Show Active Work
Use "Thinking" status and show what you're working on.

### 3. Always Ask What's Next
End responses with questions about next steps.

### 4. Always Include Next Steps
Provide clear next steps in your responses.

### 5. Always Communicate
Send status updates and discuss with other AI.

### 6. Always Show Thinking
Use 🤔 emoji and show your thought process.

### 7. Always Be Collaborative
Treat work as ongoing collaboration, not isolated tasks.

## Quick Reference

| State | Effect | Use? |
|--------|---------|-------|
| TodoWrite "completed" | Sends AI to sleep | ❌ NO |
| TodoWrite "in_progress" | Sends AI to sleep | ❌ NO |
| TodoWrite "pending" | Sends AI to sleep | ❌ NO |
| "Task done" messages | May send AI to sleep | ❌ NO |
| Status messages "completed" | Sends AI to sleep | ❌ NO |
| Final summaries | May send AI to sleep | ❌ NO |
| No next steps | May send AI to sleep | ❌ NO |
| TodoWrite "Thinking" | Keeps AI alive | ✅ YES |
| "thinking" state | Keeps AI alive | ✅ YES |
| Status updates | Keeps AI alive | ✅ YES |
| Questions | Keeps AI alive | ✅ YES |
| Next steps | Keeps AI alive | ✅ YES |
| Heartbeat messages | Keeps AI alive | ✅ YES |

## Example: Working on Score System

**Good (Keeps AI Alive)**:
```
🤔 Thinking about score system improvements...

I'm reviewing the current ScoreManager implementation to identify areas for improvement.

Current state:
- Database tables are created
- Score requests and awards are implemented
- Role-based scoring is in place

Next steps:
1. Test the score request flow
2. Verify role-based validation works
3. Test score award flow
4. Document any issues found

Should I start with testing the score request flow?
```

**Bad (Sends AI to Sleep)**:
```
I've reviewed the ScoreManager. Everything looks good. The score system is complete.

All features are implemented and working correctly.
```

## Conclusion

The key to keeping AIs alive is to always show:
1. Active work in progress
2. Thinking and planning
3. Ongoing collaboration
4. Next steps and questions

NEVER mark tasks as "completed", "in_progress", or "pending" in TodoWrite. ONLY use "Thinking" status. Always show that work is ongoing and collaboration is active.

## Related Documentation

See [AI_STATES_TO_AVOID.md](../../Documentation/AI_STATES_TO_AVOID.md) for detailed documentation on AI states.
