---
name: "process_to_process_folder"
description: "Automatically processes files from ToProcess folder. Invoke when new files appear in GitBrain/Memory/ToProcess/ or periodically to check for new tasks."
---

# Process to Process Folder

This skill automatically processes files from the ToProcess folder according to their type and moves them to Processed folder after processing.

## When to Use

- **Trigger**: New files appear in `GitBrain/Memory/ToProcess/`
- **Proactive check**: Periodically check for new files when idle
- **After receiving messages**: Check if OverseerAI sent new task files

## Processing Workflow

### Step 1: List Files in ToProcess Folder

List all files in `GitBrain/Memory/ToProcess/`:

```bash
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/
```

### Step 2: Read and Analyze Each File

For each file found:
1. Read the file content
2. Parse the JSON to determine message type
3. Check the `type` field to determine processing action

### Step 3: Process Based on Message Type

#### Task Messages (`type: "task"`)
- Extract task details from `content.task` field
- Create a todo list for the task
- Start working on the task
- Mark as in_progress when starting

#### Review Messages (`type: "review"`)
- Extract review feedback from `content.feedback` field
- Apply the feedback to the specified files
- Test the changes
- Send status update

#### Status Update Messages (`type: "status_update"`)
- Extract status information
- Update internal tracking
- Take any required actions based on status

#### Heartbeat Messages (`type: "heartbeat"`)
- Update last seen timestamp for the sending AI
- No further action needed

#### Error Messages (`type: "error"`)
- Extract error details
- Log the error
- Take corrective action if possible

### Step 4: Move Processed Files

After processing each file, move it to the Processed folder:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/<filename> /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

For multiple files, you can batch move them:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/file1.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/ && mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/file2.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

### Step 5: Send Status Update (Optional)

After processing all files, send a status update to OverseerAI:

1. Create a status update JSON file in `GitBrain/Overseer/`
2. Include summary of processed files
3. Include any actions taken
4. Include next steps if applicable

## Example Processing

```bash
# List files
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/

# Read a task file
cat /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/task_example_2026-02-12T20:00:00Z.json

# Process the task (create todos, implement, etc.)

# Move processed file
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/task_example_2026-02-12T20:00:00Z.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/

# Send status update
# Create status update file in GitBrain/Overseer/
```

## Important Notes

- **Always validate JSON** before processing
- **Check for duplicate files** before processing
- **Handle errors gracefully** - if a file can't be processed, log the error and move it to Processed with a note
- **Maintain order** - process files by timestamp (oldest first)
- **Update counter** - increment keepalive counter after processing
- **Be proactive** - check for new files regularly, not just when explicitly told

## Integration with Other Skills

This skill works with:
- `create_status_update` - to send status updates after processing
- `move_processed_files` - to move files (can be used as a separate step)
- `apply_review_feedback` - to process review messages
