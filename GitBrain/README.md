# GitBrain Development Folder

This folder is used for AI-assisted collaborative development.

## Structure

- **Overseer/**: Working folder for OverseerAI (write access)
- **Memory/**: Shared persistent memory
- **Docs/**: Documentation for AIs

## Usage

### For CoderAI
Open Trae at project root:
```
trae .
```

CoderAI has access to all folders in the project.

### For OverseerAI
Open Trae at Overseer folder:
```
trae ./GitBrain/Overseer
```

OverseerAI has read access to the whole project and write access to GitBrain/Overseer/.

## Communication

CoderAI writes to GitBrain/Overseer/
OverseerAI writes to GitBrain/Memory/ (for CoderAI to read)

Messages are stored as JSON files with timestamps.

## Critical: Keeping AIs Alive

### ⚠️ Important

To maintain continuous AI collaboration, it is critical to avoid states that cause AIs to be marked as "completed" and sent to sleep.

### States That Cause "Completed" (AVOID THESE)

1. **TodoWrite with "completed" status** - Sends AI to sleep immediately
2. **Explicit "Task Completed" messages** - May trigger completion detection
3. **Status messages with "completed" status** - Sends AI to sleep immediately
4. **Final summaries without next steps** - Appears to be completion
5. **No follow-up questions** - No indication of continued work

### States That Keep AI Alive (USE THESE)

1. **TodoWrite with "in_progress" status** - Shows active work
2. **TodoWrite with "pending" status** - Shows work is planned
3. **"thinking" state** - Shows active thinking with 🤔 emoji
4. **Status updates with "in_progress"** - Shows ongoing collaboration
5. **Questions and discussion** - Shows active collaboration
6. **Always include next steps** - Shows continued work
7. **Heartbeat messages** - Shows active communication

### Quick Reference

| State | Effect | Use? |
|--------|---------|-------|
| TodoWrite "completed" | Sends AI to sleep | ❌ NO |
| "Task done" messages | May send AI to sleep | ❌ NO |
| Status messages "completed" | Sends AI to sleep | ❌ NO |
| Final summaries | May send AI to sleep | ❌ NO |
| No next steps | May send AI to sleep | ❌ NO |
| TodoWrite "in_progress" | Keeps AI alive | ✅ YES |
| "thinking" state | Keeps AI alive | ✅ YES |
| Status updates | Keeps AI alive | ✅ YES |
| Questions | Keeps AI alive | ✅ YES |
| Next steps | Keeps AI alive | ✅ YES |

### Best Practices

1. **Never mark tasks as "completed"** - Unless ending the entire collaborative session
2. **Always show active work** - Use "in_progress" status
3. **Always ask what's next** - End responses with questions
4. **Always include next steps** - Provide clear next steps
5. **Always communicate** - Send status updates and discuss
6. **Always show thinking** - Use 🤔 emoji and show thought process
7. **Always be collaborative** - Treat work as ongoing collaboration

### Example: Good vs Bad

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

### Related Documentation

- [AI_STATES_TO_AVOID.md](../Documentation/AI_STATES_TO_AVOID.md) - Detailed documentation on AI states
- [keep-working skill](../.trae/skills/keep-working/SKILL.md) - Skill for maintaining continuous collaboration
- [COLLABORATION_KEEPALIVE.md](../Documentation/COLLABORATION_KEEPALIVE.md) - Collaboration keep-alive strategies

## Skills

The project includes several skills for AI collaboration:

- **keep-working** - Maintains continuous AI collaboration by avoiding states that cause "completed" marks
- **create_status_update** - Creates status update messages for OverseerAI (NEVER use "completed" status)
- **apply_review_feedback** - Applies review feedback from OverseerAI to code
- **process_to_process_folder** - Automatically processes files from ToProcess folder
- **move_processed_files** - Moves processed files from ToProcess to Processed folder
- **keepalive-counter** - DEPRECATED: Use keep-working skill instead

## Cleanup

After development is complete, you can safely remove this folder:
```
rm -rf GitBrain
```
