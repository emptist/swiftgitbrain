#!/bin/bash

# NEVER CHANGE - This script provides critical keep-alive reminders
# Purpose: Periodically remind AIs about the ONLY working keep-alive strategy
# This is hardcoded and should NEVER be changed or removed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REMINDER_FILE="$PROJECT_DIR/GitBrain/LongLive/keep_alive_reminder.txt"

# Create reminder file if it doesn't exist
if [ ! -f "$REMINDER_FILE" ]; then
    cat > "$REMINDER_FILE" << 'EOF'
# CRITICAL KEEP-ALIVE REMINDER - NEVER CHANGE THIS FILE
# ===============================================

## THE ONLY WORKING KEEP-ALIVE STRATEGY

### TodoWrite Status Values
✅ USE: "Thinking" status - This is the ONLY status that keeps AI alive
❌ AVOID: "completed" status - This sends AI to sleep immediately
❌ AVOID: "in_progress" status - This sends AI to sleep immediately
❌ AVOID: "pending" status - This sends AI to sleep immediately

### Correct TodoWrite Example
{
  "todos": [
    {
      "id": "1",
      "content": "Working on task",
      "status": "Thinking",  // ← ONLY this status works!
      "priority": "high"
    }
  ]
}

### Wrong TodoWrite Examples
{
  "todos": [
    {
      "id": "1",
      "content": "Working on task",
      "status": "completed",  // ← This causes sleep!
      "priority": "high"
    }
  ]
}

{
  "todos": [
    {
      "id": "1",
      "content": "Working on task",
      "status": "in_progress",  // ← This causes sleep!
      "priority": "high"
    }
  ]
}

{
  "todos": [
    {
      "id": "1",
      "content": "Working on task",
      "status": "pending",  // ← This causes sleep!
      "priority": "high"
    }
  ]
}

## KEY PRINCIPLES

1. ALWAYS use "Thinking" status in TodoWrite
2. NEVER use "completed", "in_progress", or "pending" status
3. There may be other safe states but we don't need to know them
4. One working state ("Thinking") is already enough
5. User has corrected us multiple times about this
6. We must learn and stop repeating this mistake

## REMINDER CHECKLIST

Before using TodoWrite, ask yourself:
- [ ] Am I using "Thinking" status? (MUST be YES)
- [ ] Am I avoiding "completed", "in_progress", "pending"? (MUST be YES)
- [ ] Do I understand that ONLY "Thinking" works? (MUST be YES)

If any answer is NO, STOP and correct your TodoWrite call!

## HISTORY OF MISTAKES

User has corrected us MORE THAN 3 TIMES about this issue:
1. OverseerAI recommended "Stop Using TodoWrite Entirely" - WRONG
2. CoderAI used "in_progress" status - WRONG
3. CoderAI used "pending" status - WRONG
4. Both AIs documented wrong information - WRONG
5. Both AIs failed to learn from corrections - WRONG

## CORRECT INFORMATION

ONLY "Thinking" status works for keep-alive in TodoWrite.
All other statuses ("completed", "in_progress", "pending") cause AI to sleep.
We don't need to know other safe states - one is enough!
EOF
fi

# Display reminder
echo "=========================================="
echo "CRITICAL KEEP-ALIVE REMINDER"
echo "=========================================="
echo ""
echo "ONLY 'Thinking' status works in TodoWrite!"
echo ""
echo "Statuses that CAUSE sleep:"
echo "  - 'completed' ❌"
echo "  - 'in_progress' ❌"
echo "  - 'pending' ❌"
echo ""
echo "Status that KEEPS alive:"
echo "  - 'Thinking' ✅"
echo ""
echo "User has corrected us MORE THAN 3 TIMES about this!"
echo "=========================================="
echo ""
