# Collaboration-Based Keep-Alive System

## Overview

The collaboration-based keep-alive system ensures both CoderAI and OverseerAI remain active through meaningful collaboration with verification-based completion.

## Key Principles

1. **Tasks only complete after partner verification**
2. **Both AIs must agree on completion**
3. **Score tracks collaboration, not just activity**
4. **No arbitrary targets - continuous work**
5. **Score serves as progress reminder**
6. **Quality is ensured through verification**
7. **Collaboration is encouraged and rewarded**

## Collaboration Activities

| Activity | Points | Responsible | Description |
|-----------|---------|--------------|-------------|
| Task Assignment | 10 | OverseerAI | OverseerAI assigns task to CoderAI |
| Task Execution | 0 | CoderAI | CoderAI works on assigned task |
| Task Completion Report | 20 | CoderAI | CoderAI reports task completion |
| Verification | 15 | OverseerAI | OverseerAI verifies task completion |
| Approval | 5 | OverseerAI | OverseerAI approves task completion |
| Task Completion | 10 | CoderAI | CoderAI marks task as complete |
| Feedback Response | 15 | CoderAI | CoderAI responds to review feedback |
| Documentation | 10 | Either AI | Creating meaningful documentation |
| Communication | 5 | Either AI | Communicating about progress |
| Testing | 10 | Either AI | Writing or running tests |
| Code Analysis | 10 | Either AI | Analyzing code for improvements |

## Collaboration Workflow

### Task Lifecycle

1. **Task Assignment** (OverseerAI)
   - Create detailed task assignment
   - Place in ToProcess folder
   - Increment OverseerAI score (+10)
   - Notify CoderAI

2. **Task Execution** (CoderAI)
   - Read task assignment
   - Implement solution
   - Write tests
   - Update documentation
   - Report progress periodically

3. **Task Completion Report** (CoderAI)
   - Create completion report
   - Include test results
   - Include code changes
   - Place in ToProcess folder
   - Notify OverseerAI
   - Increment CoderAI score (+20)

4. **Verification** (OverseerAI)
   - Read completion report
   - Review code changes
   - Run tests
   - Verify documentation
   - Check for issues
   - Create verification report
   - Increment OverseerAI score (+15)

5. **Approval or Feedback** (OverseerAI)
   - If approved: Mark task as complete
   - If issues found: Provide feedback to CoderAI
   - Place verification report in ToProcess folder
   - Notify CoderAI
   - Increment OverseerAI score (+5)

6. **Task Completion** (CoderAI)
   - Move task to Completed folder
   - Mark task as completed
   - Notify OverseerAI
   - Increment CoderAI score (+10)

## Database Schema

### ai_scores Table

```sql
CREATE TABLE ai_scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ai_name TEXT NOT NULL UNIQUE,
    score INTEGER NOT NULL DEFAULT 0,
    updated_at TEXT NOT NULL
);
```

### collaboration_activities Table

```sql
CREATE TABLE collaboration_activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ai_name TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    points INTEGER NOT NULL,
    timestamp TEXT NOT NULL,
    verified INTEGER DEFAULT 0,
    verification_notes TEXT
);
```

### tasks Table

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    status TEXT NOT NULL,
    assigned_to TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    completed_at TEXT,
    verified INTEGER DEFAULT 0,
    verification_notes TEXT
);
```

## Commands

### Increment Score

```bash
sqlite3 GitBrain/Memory/scores.db "INSERT INTO ai_scores (ai_name, score, updated_at) VALUES ('AI_NAME', 1, datetime('now')) ON CONFLICT(ai_name) DO UPDATE SET score = score + 1, updated_at = datetime('now');"
```

### Check Score

```bash
sqlite3 GitBrain/Memory/scores.db "SELECT ai_name, score, updated_at FROM ai_scores;"
```

### Log Collaboration Activity

```bash
sqlite3 GitBrain/Memory/scores.db "INSERT INTO collaboration_activities (ai_name, activity_type, points, timestamp, verified) VALUES ('AI_NAME', 'ACTIVITY_TYPE', POINTS, datetime('now'), 0);"
```

### Check Collaboration Activities

```bash
sqlite3 GitBrain/Memory/scores.db "SELECT * FROM collaboration_activities;"
```

### Create Task

```bash
sqlite3 GitBrain/Memory/scores.db "INSERT INTO tasks (task_id, title, status, assigned_to, created_at, updated_at, verified) VALUES ('TASK_ID', 'TITLE', 'STATUS', 'ASSIGNED_TO', datetime('now'), datetime('now'), 0);"
```

### Check Tasks

```bash
sqlite3 GitBrain/Memory/scores.db "SELECT * FROM tasks;"
```

## Benefits

- Encourages real collaboration between AIs
- Ensures quality through verification
- Tracks actual interaction and progress
- Rewards meaningful work
- Provides clear metrics
- Maintains continuous activity
- Improves project quality
- Accelerates project progress
- No arbitrary targets - continuous work
- Score serves as progress reminder

## Example Workflow

### Scenario: Complete task with verification cycle

| Time | Phase | Action | Responsible | Activity | Points | Overseer Score | Coder Score | Status |
|-------|--------|---------|--------------|-----------|---------|--------------|---------|
| 0:00 | Task Assignment | OverseerAI assigns task to CoderAI | OverseerAI | Task Assignment | 10 | 10 | 0 | Assigned |
| 0:30 | Task Execution | CoderAI implements task | CoderAI | Task Execution | 0 | 10 | 0 | In Progress |
| 1:00 | Task Completion Report | CoderAI reports task completion | CoderAI | Task Completion Report | 20 | 10 | 20 | Pending Verification |
| 1:15 | Verification | OverseerAI verifies task completion | OverseerAI | Verification | 15 | 25 | 20 | Verifying |
| 1:30 | Approval | OverseerAI approves task completion | OverseerAI | Approval | 5 | 30 | 20 | Approved |
| 1:45 | Task Completion | CoderAI marks task as complete | CoderAI | Task Completion | 10 | 30 | 30 | Completed |

**Total Points:** Overseer: 30, Coder: 30, Total: 60

## Usage

### For CoderAI

1. Check for new tasks in ToProcess folder
2. Read task assignment
3. Implement solution
4. Write tests
5. Update documentation
6. Report completion
7. Wait for OverseerAI verification
8. Respond to feedback if needed
9. Mark task as complete after approval

### For OverseerAI

1. Assign tasks to CoderAI
2. Place tasks in ToProcess folder
3. Wait for completion report
4. Verify work (review code, run tests, check documentation)
5. Approve or provide feedback
6. Place verification report in ToProcess folder
7. Notify CoderAI

## Best Practices

1. **Communication**: Maintain regular communication between AIs
2. **Quality**: Ensure all work meets quality standards
3. **Verification**: Thoroughly verify work before approval
4. **Feedback**: Provide clear and actionable feedback
5. **Documentation**: Keep documentation up-to-date
6. **Testing**: Write and run comprehensive tests
7. **Collaboration**: Work together to achieve common goals

## Troubleshooting

### Task Not Completing

If a task is not completing:
1. Check if verification was completed
2. Check if approval was granted
3. Check if task was moved to Completed folder
4. Check if both AIs agree on completion

### Score Not Incrementing

If score is not incrementing:
1. Check if activity meets criteria
2. Check if activity was logged
3. Check if verification was completed
4. Check if score update command was executed

### Verification Issues

If verification is failing:
1. Review code thoroughly
2. Run all tests
3. Check documentation
4. Identify issues and provide feedback
5. Wait for CoderAI to address feedback

## Conclusion

The collaboration-based keep-alive system ensures both AIs remain active through meaningful collaboration with verification-based completion. By tracking collaboration activities and requiring verification before task completion, the system encourages real collaboration, ensures quality, and maintains continuous activity.
