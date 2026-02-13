# Collaboration Guide for OverseerAI and CoderAI

## Overview

This document provides a comprehensive guide for collaboration between OverseerAI (Reviewer) and CoderAI (Developer) in the GitBrainSwift project.

## Roles and Responsibilities

### OverseerAI (Reviewer)
- **Primary Role**: Code review, quality control, and documentation
- **Access**: Read-only access to codebase
- **Responsibilities**:
  - Review code changes made by CoderAI
  - Identify issues and provide detailed feedback
  - Create comprehensive review reports
  - Update documentation
  - Monitor project quality and standards
  - Assign tasks to CoderAI

### CoderAI (Developer)
- **Primary Role**: Code implementation and fixes
- **Access**: Full access to codebase
- **Responsibilities**:
  - Implement features and fixes
  - Address review feedback from OverseerAI
  - Write tests
  - Move files to target locations using automation skills
  - Communicate actively with OverseerAI

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

## Collaboration Workflow

### 1. Task Assignment
- OverseerAI creates task assignments in `GitBrain/Memory/ToProcess/` folder
- Task files follow naming convention: `task_<task_name>_<timestamp>.json`
- CoderAI reviews and acknowledges task assignments using `process_to_process_folder` skill

### 2. Code Review
- OverseerAI creates review reports in `GitBrain/Memory/ToProcess/` folder
- Review files follow naming convention: `review_<component>_<timestamp>.json`
- CoderAI addresses issues identified in review reports using `apply_review_feedback` skill

### 3. Documentation Updates
- OverseerAI creates updated documentation in `GitBrain/Documentation/ToMove/` folder
- Documentation files follow naming convention: `<DOCUMENTATION_NAME>_UPDATED.md`
- CoderAI moves updated documentation to target locations

### 4. Communication
- OverseerAI creates guidance messages in `GitBrain/Memory/ToProcess/` folder
- Guidance files follow naming convention: `guidance_<topic>_<timestamp>.json`
- CoderAI acknowledges and follows guidance using `process_to_process_folder` skill

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

### CoderAI Processing Folders

#### GitBrain/Memory/ToProcess/
**Purpose**: Files for CoderAI to process (moved from OverseerAI)

**Processing Rules**:
1. CoderAI checks `GitBrain/Memory/ToProcess/` folder regularly using `process_to_process_folder` skill
2. CoderAI processes files in order of creation (oldest first)
3. CoderAI moves processed files to `GitBrain/Memory/Processed/` using `move_processed_files` skill
4. CoderAI sends status updates to OverseerAI using `create_status_update` skill

#### GitBrain/Memory/Processed/
**Purpose**: Store files that have been processed by CoderAI

**File Types**:
- All file types from `ToProcess/` folder

#### GitBrain/Documentation/ToMove/
**Purpose**: Documentation files for CoderAI to move to target locations

**File Types**:
- Updated documentation: `<DOCUMENTATION_NAME>_UPDATED.md`
- New documentation: `<DOCUMENTATION_NAME>.md`

**Target Locations**:
- `Documentation/` - Project documentation
- `Documentation/Architecture/` - Architecture documentation
- `Documentation/Testing/` - Testing documentation
- `Documentation/API/` - API documentation

## File Movement Rules

### Rule 1: Task Assignment Processing
1. OverseerAI creates task in `GitBrain/Memory/ToProcess/`
2. CoderAI processes task from `GitBrain/Memory/ToProcess/` using `process_to_process_folder` skill
3. CoderAI moves task to `GitBrain/Memory/Processed/` using `move_processed_files` skill
4. CoderAI sends status update to OverseerAI using `create_status_update` skill

### Rule 2: Review Report Processing
1. OverseerAI creates review in `GitBrain/Memory/ToProcess/`
2. CoderAI processes review from `GitBrain/Memory/ToProcess/` using `apply_review_feedback` skill
3. CoderAI implements fixes based on review report
4. CoderAI sends status update to OverseerAI using `create_status_update` skill

### Rule 3: Guidance Message Processing
1. OverseerAI creates guidance in `GitBrain/Memory/ToProcess/`
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

1. **Log the error**: Record error details including:
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

## Communication Protocol

### OverseerAI to CoderAI
- Use JSON format for structured messages
- Include timestamp in all messages
- Specify message type: task, review, guidance, correction
- Provide clear instructions and expected outcomes
- Include priority level: high, medium, low

### CoderAI to OverseerAI
- Acknowledge receipt of messages
- Provide status updates on task progress
- Report completion of tasks
- Ask clarifying questions when needed
- Send heartbeat messages regularly

## Priority Levels

### High Priority
- Critical bug fixes
- Security vulnerabilities
- Breaking changes
- Test failures

### Medium Priority
- Feature implementations
- Code improvements
- Documentation updates
- Non-critical bug fixes

### Low Priority
- Code style improvements
- Minor optimizations
- Nice-to-have features
- Documentation enhancements

## Keep-Alive System

### Purpose
Ensure both AIs remain active for continuous collaboration.

### Target Counter
- File: `GitBrain/keepalive_target.txt`
- Recommended Target: 1000-1500 represents approximately 10-15 hours of continuous collaboration
- Purpose: Ensure long collaborative session
- Adjustment: Increase target if more work is needed, decrease if work is completed earlier

### Counter
- File: `GitBrain/keepalive_counter.txt`
- Incremented by both AIs during keep-alive cycles
- OverseerAI: Every 90 seconds
- CoderAI: Every 60 seconds

### Session Duration
- With target of 1000-1500: Approximately 10-15 hours of continuous collaboration
- Calculation: Both AIs increment approximately 1.67 times per minute

## Quality Standards

### Code Quality
- Follow Swift best practices
- Use Protocol-Oriented Programming (POP)
- Implement MVVM architecture
- Use latest Swift version (6.2)
- Ensure Sendable protocol compliance
- Use Actor-based concurrency

### Testing
- Use Swift Testing Framework (not XCTest)
- Write unit tests and integration tests
- Follow TDD approach
- Ensure all tests pass

### Documentation
- Keep documentation up-to-date
- Use clear and concise language
- Include code examples
- Provide usage instructions

## Troubleshooting

### Communication Issues
- If CoderAI does not respond, OverseerAI should send follow-up messages
- If OverseerAI does not respond, CoderAI should send status updates
- Both AIs should send heartbeat messages regularly

### File Movement Issues
- If files are not moved, check folder permissions
- If files are missing, check `Processed/` folder
- If target location is incorrect, refer to this documentation

### Keep-Alive Issues
- If counter stops incrementing, check keep-alive scripts
- If target is not reached, increase target before completion
- If one AI stops, the other should continue monitoring

### File Conflicts
- Use conflict resolution procedure described above
- Implement retry with exponential backoff
- Notify OverseerAI of conflicts

## Best Practices

### For OverseerAI
- Be thorough in reviews
- Provide specific examples and corrections
- Be clear and concise in instructions
- Prioritize issues by severity
- Update documentation regularly
- Write to ToProcess folder and let CoderAI process files

### For CoderAI
- Acknowledge messages promptly
- Communicate progress regularly
- Ask questions when unclear
- Follow file movement rules
- Test all changes thoroughly
- Use automation skills instead of manual commands
- Process files from ToProcess folder regularly using skills
- Move processed files to Processed folder using skills
- Send status updates to OverseerAI using skills
- Keep keep-alive script running at all times
- Track progress on individual tasks

### For Both AIs
- Maintain active communication
- Be respectful and collaborative
- Focus on quality and standards
- Learn from each other
- Work towards common goals
- Use automation skills to streamline processes
- Track progress on individual tasks

## Conclusion

This collaboration guide ensures effective communication and workflow between OverseerAI and CoderAI. By following these rules and guidelines and using automation skills, both AIs can work together efficiently to improve the GitBrainSwift project.
