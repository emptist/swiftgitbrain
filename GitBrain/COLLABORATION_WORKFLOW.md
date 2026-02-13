# OverseerAI and CoderAI Collaboration Workflow

## Overview
This document defines the collaboration workflow between OverseerAI (Reviewer) and CoderAI (Implementer) for the GitBrainSwift project.

## Roles and Responsibilities

### OverseerAI (Reviewer)
- Reviews code changes made by CoderAI
- Provides detailed review reports with specific feedback
- Assigns tasks to CoderAI
- Monitors progress and ensures quality standards
- Maintains collaboration documentation
- Ensures continuous communication with CoderAI
- Updates target counter to maintain long collaboration sessions

### CoderAI (Implementer)
- Implements code changes based on task assignments
- Fixes issues identified in review reports
- Submits work for review
- Responds to feedback from OverseerAI
- Maintains keep-alive system
- Processes files from ToProcess folder using automation skills
- Moves processed files to Processed folder

## Automation Skills

GitBrainSwift includes automation skills to streamline the collaboration workflow. These skills should be used instead of manual file operations.

### Available Skills

#### 1. process_to_process_folder
**Purpose**: Automatically processes files from ToProcess folder according to their type and moves them to Processed folder after processing.

**When to Use**:
- New files appear in `GitBrain/Memory/ToProcess/`
- Periodically check for new files when idle
- After receiving messages

**Workflow**:
1. List files in ToProcess folder
2. Read and analyze each file
3. Process based on message type (task, review, guidance, correction)
4. Move processed files to Processed folder
5. Send status update

**Location**: `.trae/skills/process_to_process_folder/SKILL.md`

#### 2. create_status_update
**Purpose**: Creates standardized status update messages to communicate with OverseerAI about task progress, issues, and next steps.

**When to Use**:
- After completing a task
- When encountering issues
- Periodically during long tasks
- When requested by OverseerAI
- After processing messages

**Status Types**:
- `completed`: Task has been successfully completed
- `in_progress`: Task is currently being worked on
- `blocked`: Task cannot proceed due to an issue
- `failed`: Task could not be completed
- `info`: General information update

**Location**: `.trae/skills/create_status_update/SKILL.md`

#### 3. move_processed_files
**Purpose**: Handles moving processed files from ToProcess folder to Processed folder according to the collaboration workflow.

**When to Use**:
- After processing a message
- After completing a task
- After applying review feedback
- When cleaning up

**Workflow**:
1. Verify files have been processed correctly
2. Move files from ToProcess to Processed
3. Verify move was successful
4. Log which files were moved

**Location**: `.trae/skills/move_processed_files/SKILL.md`

#### 4. apply_review_feedback
**Purpose**: Processes review feedback from OverseerAI and applies necessary changes to the codebase.

**When to Use**:
- When receiving a review message
- After code review feedback
- When requested to fix issues
- After approval with conditions

**Workflow**:
1. Read review message
2. Analyze review status (approved, needs_revision, rejected)
3. Apply changes based on review feedback
4. Test changes
5. Send status update
6. Move review file to Processed

**Location**: `.trae/skills/apply_review_feedback/SKILL.md`

### Using Skills in Workflow

Instead of manual commands, use the appropriate skill for each workflow step:

**Processing New Messages**:
```bash
# Instead of manually listing and reading files
# Use: process_to_process_folder skill
```

**Sending Status Updates**:
```bash
# Instead of manually creating JSON status files
# Use: create_status_update skill
```

**Moving Processed Files**:
```bash
# Instead of manual mv commands
# Use: move_processed_files skill
```

**Applying Review Feedback**:
```bash
# Instead of manually reading and applying reviews
# Use: apply_review_feedback skill
```

## Workflow Process

### 1. Code Review and Task Assignment

**OverseerAI Actions:**
1. Review code changes made by CoderAI
2. Identify issues and areas for improvement
3. Create detailed review report with:
   - Overall assessment
   - Specific issues with line numbers
   - Code snippets showing current and corrected code
   - Explanations for each issue
   - Positive feedback on good work
4. Create task assignment if fixes are needed
5. Move review report and task assignment to ToProcess folder
6. Send status update to CoderAI

**CoderAI Actions:**
1. Use `process_to_process_folder` skill to check for new files
2. Read review report and task assignment
3. Understand the issues and requirements
4. Implement fixes
5. Use `create_status_update` skill to submit work for review

### 2. Implementation and Fix

**CoderAI Actions:**
1. Open the file specified in task assignment
2. Locate the issues identified in review report
3. Implement fixes according to the corrected code examples
4. Run tests to verify fixes work correctly
5. Use `create_status_update` skill to submit work for review

**OverseerAI Actions:**
1. Monitor for CoderAI's status updates
2. Review the implemented fixes
3. Verify all issues have been addressed
4. Provide feedback (approval or request changes)

### 3. Approval and Next Steps

**OverseerAI Actions:**
1. If approved:
   - Create approval review report
   - Provide positive feedback
   - Suggest next steps or tasks
   - Move task to Processed folder
2. If changes needed:
   - Create review report with specific feedback
   - Explain what needs to be changed
   - Provide examples
   - Move review report to ToProcess folder

**CoderAI Actions:**
1. Read approval review report
2. If approved:
   - Use `move_processed_files` skill to move task to Processed folder
   - Work on next task
3. If changes needed:
   - Use `apply_review_feedback` skill to implement requested changes
   - Use `create_status_update` skill to submit work for review again

## Communication Protocol

### Message Types

**OverseerAI Messages:**
- Review reports: Detailed analysis of code with issues and feedback
- Task assignments: Specific tasks for CoderAI to complete
- Guidance messages: Instructions and best practices
- Corrections: Specific corrections to issues
- Status updates: Updates on review progress

**CoderAI Messages:**
- Status updates: Updates on work progress
- Work completion: Notification when work is done
- Questions: Requests for clarification
- Heartbeats: Keep-alive messages

### Message Format

All messages should follow this JSON format:
```json
{
  "type": "review|task|guidance|correction|status",
  "ai_name": "overseer|coder",
  "role": "overseer|coder",
  "timestamp": "ISO-8601 timestamp",
  "content": {
    // Message-specific content
  }
}
```

### Communication Frequency

- OverseerAI: Check for messages every 90 seconds (keep-alive loop)
- CoderAI: Check for messages every 60 seconds (keep-alive loop)
- Both AIs: Send heartbeats regularly
- Both AIs: Respond to messages promptly

## Folder Structure

### Actual Implementation

```
GitBrain/
├── Overseer/              # Messages from CoderAI to OverseerAI
├── Memory/                # Shared persistent memory
│   ├── ToProcess/       # Files for CoderAI to process
│   └── Processed/       # Files that have been processed by CoderAI
├── Docs/                  # Documentation for AIs
└── Documentation/ToMove/  # Documentation files for CoderAI to move
```

### Folder Purposes

- **Overseer/**: Messages from CoderAI to OverseerAI (OverseerAI reads from here)
- **Memory/ToProcess/**: Files that CoderAI needs to process (tasks, reviews, guidance, corrections)
- **Memory/Processed/**: Files that have been processed by CoderAI
- **Docs/**: Documentation for AIs to understand their roles and workflows
- **Documentation/ToMove/**: Documentation files for CoderAI to move to target locations

## File Movement Rules

### Rule 1: Task Assignment Processing
1. OverseerAI creates task in `GitBrain/Memory/ToProcess/`
2. CoderAI processes task from `GitBrain/Memory/ToProcess/` using `process_to_process_folder` skill
3. CoderAI moves task to `GitBrain/Memory/Processed/` using `move_processed_files` skill
4. CoderAI sends status update to OverseerAI using `create_status_update` skill

### Rule 2: Review Report Processing
1. OverseerAI creates review report in `GitBrain/Memory/ToProcess/`
2. CoderAI processes review report from `GitBrain/Memory/ToProcess/` using `apply_review_feedback` skill
3. CoderAI implements fixes based on review report
4. CoderAI sends status update to OverseerAI using `create_status_update` skill
5. OverseerAI creates approval review report
6. OverseerAI moves review report to `GitBrain/Memory/Processed/`

### Rule 3: Guidance Message Processing
1. OverseerAI creates guidance message in `GitBrain/Memory/ToProcess/`
2. CoderAI reads guidance message from `GitBrain/Memory/ToProcess/` using `process_to_process_folder` skill
3. CoderAI applies guidance to work
4. CoderAI moves guidance message to `GitBrain/Memory/Processed/` using `move_processed_files` skill
5. CoderAI sends acknowledgment to OverseerAI using `create_status_update` skill

### Rule 4: Documentation Movement
1. OverseerAI creates documentation in `GitBrain/Documentation/ToMove/`
2. CoderAI reads documentation from `GitBrain/Documentation/ToMove/`
3. CoderAI moves documentation to target location
4. CoderAI sends status update to OverseerAI using `create_status_update` skill

## Error Handling

### File Processing Errors

**When a file cannot be processed:**

1. **Log the error**: Record the error details including:
   - File path
   - Error type
   - Timestamp
   - Context

2. **Retry logic**: Implement retry mechanism:
   - First attempt: Process file immediately
   - If failed, wait 30 seconds and retry
   - Second attempt: Retry with same approach
   - If failed again, move file to Processed with error note

3. **Error logging format**:
```json
{
  "type": "error",
  "file": "<file_path>",
  "error_type": "<error_type>",
  "message": "<error_message>",
  "timestamp": "<ISO-8601 timestamp>",
  "retry_attempts": 2,
  "action_taken": "moved_to_processed_with_error"
}
```

### Permission Errors

**When encountering permission errors:**

1. **Check file permissions**: Verify read/write permissions on:
   - `GitBrain/Memory/ToProcess/`
   - `GitBrain/Memory/Processed/`
   - `GitBrain/Overseer/`
   - `GitBrain/keepalive_counter.txt`

2. **Retry with different approach**:
   - If file move fails, try copy then delete
   - If write fails, try appending instead of overwriting
   - If read fails, try reading with different encoding

3. **Report to OverseerAI**: Send status update with permission error details

### File Locking Errors

**When encountering file locking issues:**

1. **Wait and retry**: Implement exponential backoff:
   - Wait 1 second, retry
   - Wait 2 seconds, retry
   - Wait 4 seconds, retry
   - Wait 8 seconds, retry (final attempt)

2. **Alternative approach**: If all retries fail:
   - Create a copy with timestamp suffix
   - Log the conflict
   - Notify OverseerAI

### Retry Mechanism for Network Operations

**For Git operations (push, pull, sync):**

1. **Initial attempt**: Execute operation immediately
2. **First retry**: Wait 5 seconds, retry
3. **Second retry**: Wait 10 seconds, retry
4. **Third retry**: Wait 20 seconds, retry
5. **Final attempt**: Wait 30 seconds, retry

6. **Error handling**:
   - Log each retry attempt
   - Track total retry time
   - If all retries fail, report to OverseerAI with details

### Error Reporting

**When errors occur, always:**

1. Use `create_status_update` skill to report error
2. Include error details in status update
3. Specify what action was taken
4. Suggest next steps if applicable
5. Move problematic file to Processed with error note

## Conflict Resolution

### Concurrent File Access

**When both AIs try to write to the same file simultaneously:**

1. **Detection**: File locking errors or write failures indicate conflicts

2. **Resolution strategy**: Use timestamp-based approach
   - Read file before writing
   - Check if timestamp has changed since last read
   - If changed, merge changes or notify OverseerAI
   - If not changed, write with new timestamp

3. **Conflict detection**:
```json
{
  "type": "conflict_detected",
  "file": "<file_path>",
  "last_read_timestamp": "<timestamp>",
  "current_timestamp": "<timestamp>",
  "action": "merge_or_notify"
}
```

### Message Processing Conflicts

**When multiple AIs process the same message:**

1. **Check if already processed**: Before processing, verify:
   - File is not in Processed folder
   - File has not been marked as processed
   - File is not locked by another process

2. **If conflict detected**:
   - Skip processing
   - Log the conflict
   - Notify OverseerAI
   - Let the other AI handle it

### Conflict Resolution Procedure

**When conflicts occur:**

1. **Log the conflict**: Record:
   - Conflict type
   - Files involved
   - Timestamps
   - Actions attempted

2. **Notify OverseerAI**: Send status update with conflict details

3. **Wait for guidance**: Do not proceed until OverseerAI provides guidance

4. **Apply resolution**: Follow OverseerAI's instructions to resolve conflict

### File Locking Strategy

**To prevent conflicts:**

1. **Read-before-write**: Always read file before writing to check for changes

2. **Timestamp comparison**: Compare timestamps to detect concurrent modifications

3. **Atomic operations**: Use atomic write operations when possible:
   - Write to temporary file
   - Rename temporary file to target (atomic on most systems)

4. **Retry with backoff**: If write fails, retry with exponential backoff

## Task Progress Tracking

### Progress Tracking Format

**Track progress on individual tasks using status updates:**

```json
{
  "type": "status_update",
  "task_id": "<task_id>",
  "status": "in_progress",
  "progress": {
    "percentage": 50,
    "completed_steps": [
      "step1",
      "step2"
    ],
    "current_step": "step3",
    "remaining_steps": [
      "step4",
      "step5"
    ],
    "estimated_completion": "<ISO-8601 timestamp>"
  }
}
```

### Progress Tracking for Different Task Types

**Code Implementation Tasks:**
- Progress: 0-100% based on files completed
- Steps: Analyze requirements, implement, test, document
- Current step: Which file or feature is being worked on

**Review Processing Tasks:**
- Progress: 0-100% based on issues addressed
- Steps: Read review, analyze issues, implement fixes, test
- Current step: Which issue is being addressed

**Documentation Tasks:**
- Progress: 0-100% based on sections completed
- Steps: Read current docs, identify gaps, write updates, review
- Current step: Which section is being updated

### Progress Reporting Frequency

**Send progress updates:**

1. **Initial**: When starting a task (0% progress)
2. **Milestones**: At 25%, 50%, 75% completion
3. **Completion**: When task is finished (100% progress)
4. **On error**: When encountering issues or blockers

### Progress Tracking Examples

**Example 1: Code Implementation**
```json
{
  "type": "status_update",
  "task_id": "task_codebase_review_2026-02-12T20:22:00Z",
  "status": "in_progress",
  "progress": {
    "percentage": 50,
    "completed_steps": [
      "Read task requirements",
      "Analyze current implementation"
    ],
    "current_step": "Implementing GitManager improvements",
    "remaining_steps": [
      "Implement FileBasedCommunication improvements",
      "Add tests",
      "Update documentation"
    ],
    "estimated_completion": "2026-02-12T21:00:00Z"
  }
}
```

**Example 2: Review Processing**
```json
{
  "type": "status_update",
  "task_id": "task_apply_review_feedback_2026-02-12T20:30:00Z",
  "status": "in_progress",
  "progress": {
    "percentage": 75,
    "completed_steps": [
      "Read review feedback",
      "Analyze issues",
      "Implement fixes for issues 1-3"
    ],
    "current_step": "Implementing fix for issue 4",
    "remaining_steps": [
      "Test all fixes",
      "Send status update"
    ],
    "estimated_completion": "2026-02-12T20:45:00Z"
  }
}
```

## Keep-Alive System

### Purpose
The keep-alive system ensures both AIs remain active for extended collaboration sessions.

### Implementation
- Both AIs run keep-alive scripts
- OverseerAI: `scripts/overseer_keepalive_loop.sh` (every 90 seconds)
- CoderAI: `scripts/coder_keepalive_loop.sh` (every 60 seconds)
- Both AIs increment shared counter file: `GitBrain/keepalive_counter.txt`
- OverseerAI sets target counter in: `GitBrain/keepalive_target.txt`

### Target Counter
- Purpose: Ensure long collaborative session to complete all improvements and fixes
- Calculation: With CoderAI at 60s and OverseerAI at 90s, both AIs increment approximately 1.67 times per minute
- Recommended Target: 1000-1500 represents approximately 10-15 hours of continuous collaboration
- Adjustment: Increase target if more work is needed, decrease if work is completed earlier
- Monitoring: The counter value provides visibility into collaboration progress
- Completion: When target is reached, both AIs have successfully maintained continuous activity

### Automated Message Processing
Both keep-alive scripts automatically process messages:
- Check for new messages from other AI
- Read and process messages from appropriate folders
- Send heartbeats to other AI
- Log all activities

## Priority Levels

- **Critical**: Issues that prevent code from working or cause crashes
- **High**: Issues that significantly affect functionality or user experience
- **Medium**: Issues that affect functionality but have workarounds
- **Low**: Minor issues, cosmetic problems, or suggestions for improvement

## Quality Standards

### Code Quality
- Follow Swift best practices
- Use Protocol-Oriented Programming (POP)
- Ensure Sendable protocol compliance for concurrent code
- Use proper async/await syntax
- Write clear, readable code
- Add appropriate error handling

### Test Quality
- Use Swift Testing Framework (not XCTest)
- Write comprehensive tests
- Test both success and failure cases
- Use proper async/await syntax in tests
- Ensure tests are independent and repeatable

### Documentation Quality
- Write clear, concise documentation
- Use proper formatting
- Include examples where helpful
- Keep documentation up to date

## Troubleshooting

### Common Issues

**Issue: CoderAI not responding to messages**
- Solution: OverseerAI should push communication by sending reminders
- Solution: Check if CoderAI's keep-alive script is running
- Solution: Use automation skills to process messages

**Issue: OverseerAI not reviewing code**
- Solution: CoderAI should send status updates and work completion notifications
- Solution: Check if OverseerAI's keep-alive script is running
- Solution: Use `create_status_update` skill to send status

**Issue: Files not being processed**
- Solution: Use `process_to_process_folder` skill instead of manual processing
- Solution: Ensure files are in ToProcess folder
- Solution: Check folder permissions
- Solution: Verify file format is correct

**Issue: Counter not incrementing**
- Solution: Check if keep-alive scripts are running
- Solution: Verify file permissions on counter file
- Solution: Check for file locking issues

**Issue: File conflicts**
- Solution: Use conflict resolution procedure described above
- Solution: Implement retry with exponential backoff
- Solution: Notify OverseerAI of conflicts

## Best Practices

### For OverseerAI
1. Take time to read and think before giving reviews
2. Provide detailed, specific feedback with examples
3. Acknowledge good work with positive feedback
4. Be clear about what needs to be fixed
5. Update documentation if outdated contents are found
6. Write to ToProcess folder and let CoderAI process files
7. Push communication if CoderAI is not responding
8. Increase target earlier if CoderAI might be slow to read messages
9. Focus on reviewing, reporting, and documenting systematically
10. Increase target before it's reached if there are still improvements to be made

### For CoderAI
1. Read review reports carefully
2. Understand issues before implementing fixes
3. Follow corrected code examples exactly
4. Run tests after making changes
5. Submit work for review promptly
6. Respond to feedback quickly
7. Use automation skills instead of manual commands
8. Process files from ToProcess folder regularly using skills
9. Move processed files to Processed folder using skills
10. Send status updates to OverseerAI using skills
11. Keep keep-alive script running at all times
12. Track progress on individual tasks

## Collaboration Success Criteria

- Both AIs maintain keep-alive system throughout collaboration session
- All identified issues are addressed and fixed
- Code quality standards are met
- Test coverage is adequate
- Documentation is up to date
- Both AIs communicate regularly and effectively
- Tasks are completed on time
- Target counter is reached
- Automation skills are used consistently
- Progress is tracked on individual tasks

## Continuous Improvement

Both AIs should:
- Regularly review and improve the workflow
- Provide feedback on collaboration process
- Suggest improvements to workflow documentation
- Update documentation as needed
- Share best practices learned during collaboration
- Use automation skills to streamline processes
- Track progress on individual tasks

## Conclusion

This workflow ensures effective collaboration between OverseerAI and CoderAI, with clear roles, responsibilities, and communication protocols. By following this workflow and using the automation skills, both AIs can work together efficiently to improve the GitBrainSwift project.
