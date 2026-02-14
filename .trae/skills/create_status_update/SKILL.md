---
name: "create_status_update"
description: "Creates status update messages for Monitor. Invoke after making progress, encountering issues, or when requested to report progress. NEVER use 'completed' status."
---

# Create Status Update

This skill creates standardized status update messages to communicate with Monitor about task progress, issues, and next steps.

## Important Warning

**NEVER use "completed" status** - This will cause the AI to be marked as "completed" and sent to sleep, breaking collaboration. Always use "in_progress" status to keep AI alive.

See [keep-working skill](../keep-working/SKILL.md) for more information on keeping AIs alive.

## When to Use

- **After making progress** - report progress on tasks
- **When encountering issues** - report blockers or errors
- **Periodically during long tasks** - report progress
- **When requested by Monitor** - respond to status requests
- **After processing messages** - report what was processed

## Status Update Format

Status updates follow the standard Message format:

```json
{
  "id": "status_update_<timestamp>",
  "from": "Creator",
  "to": "Monitor",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "status_update",
  "content": {
    "status": "<status_type>",
    "message": "<human-readable message>",
    "details": {
      "task_id": "<task_id_if_applicable>",
      "progress": "<progress_percentage_or_description>",
      "files_modified": ["<file_paths>"],
      "issues": ["<issue_descriptions>"],
      "next_steps": ["<next_action_items>"]
    }
  }
}
```

## Status Types

### `in_progress` (USE THIS INSTEAD OF "completed")

Task is currently being worked on or has made progress. Use this status to keep AI alive.

**Example:**
```json
{
  "status": "in_progress",
  "message": "Successfully implemented async syntax fixes in GitManagerTests.swift",
  "details": {
    "task_id": "task_fix_async_syntax_v2_2026-02-12T20:00:00Z",
    "progress": "100%",
    "files_modified": [
      "Tests/GitBrainSwiftTests/GitManagerTests.swift"
    ],
    "issues": [],
    "next_steps": [
      "Run tests to verify fixes",
      "Submit for review"
    ]
  }
}
```

### `blocked`

Task cannot proceed due to an issue.

**Example:**
```json
{
  "status": "blocked",
  "message": "Cannot proceed with task - missing dependency",
  "details": {
    "task_id": "task_example_2026-02-12T20:00:00Z",
    "progress": "30%",
    "files_modified": [],
    "issues": [
      "Missing Swift 6.2 compiler features",
      "Cannot find required library"
    ],
    "next_steps": [
      "Wait for dependency resolution",
      "Request guidance from Monitor"
    ]
  }
}
```

### `failed`

Task could not be completed.

**Example:**
```json
{
  "status": "failed",
  "message": "Failed to implement feature due to architectural constraints",
  "details": {
    "task_id": "task_example_2026-02-12T20:00:00Z",
    "progress": "80%",
    "files_modified": [
      "Sources/GitBrainSwift/Example.swift"
    ],
    "issues": [
      "Architecture does not support requested feature",
      "Would require breaking changes"
    ],
    "next_steps": [
      "Request alternative approach",
      "Discuss with Monitor"
    ]
  }
}
```

### `info`

General information update.

**Example:**
```json
{
  "status": "info",
  "message": "Processed 3 files from ToProcess folder",
  "details": {
    "files_processed": [
      "task_apply_collaboration_workflow_2026-02-12T20:10:00Z.json",
      "review_async_syntax_fixes_approved_2026-02-12T20:05:00Z.json",
      "task_fix_async_syntax_v2_2026-02-12T20:00:00Z.json"
    ],
    "next_steps": [
      "Continue monitoring for new messages"
    ]
  }
}
```

## Creating a Status Update

### Step 1: Generate Timestamp

Use current ISO 8601 timestamp:

```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

### Step 2: Create Status Update File

Create a new file in `GitBrain/Monitor/` with the format:

```
status_update_<timestamp>.json
```

### Step 3: Write JSON Content

Write the status update following the format above. Ensure:
- All required fields are present
- JSON is valid (use proper escaping)
- Timestamp is in ISO 8601 format
- Status type is one of: in_progress, blocked, failed, info
- **NEVER use "completed" status**

### Step 4: Validate JSON

Validate the JSON before saving:

```bash
cat GitBrain/Monitor/status_update_<timestamp>.json | python3 -m json.tool
```

## Example Complete Status Update

```json
{
  "id": "status_update_2026-02-12T20:30:00Z",
  "from": "Creator",
  "to": "Monitor",
  "timestamp": "2026-02-12T20:30:00Z",
  "type": "status_update",
  "content": {
    "status": "in_progress",
    "message": "Successfully created workflow automation skills",
    "details": {
      "task_id": "task_create_workflow_skills_2026-02-12T20:20:00Z",
      "progress": "100%",
      "files_modified": [
        ".trae/skills/process_to_process_folder/SKILL.md",
        ".trae/skills/create_status_update/SKILL.md",
        ".trae/skills/move_processed_files/SKILL.md",
        ".trae/skills/apply_review_feedback/SKILL.md"
      ],
      "issues": [],
      "next_steps": [
        "Test all skills",
        "Submit for review"
      ]
    }
  }
}
```

## Best Practices

1. **Be specific** - include exact file paths and task IDs
2. **Be honest** - report issues and blockers immediately
3. **Be actionable** - include clear next steps
4. **Be concise** - keep messages focused and relevant
5. **Use proper status types** - choose the most appropriate status
6. **Include progress** - always include progress information
7. **List issues** - enumerate any problems encountered
8. **Suggest solutions** - propose next steps when possible
9. **NEVER use "completed"** - always use "in_progress" to keep AI alive
10. **Always include next steps** - show continued work is planned

## Integration with Other Skills

This skill works with:
- `process_to_process_folder` - send status after processing files
- `apply_review_feedback` - send status after applying feedback
- `keep-working` - always use "in_progress" status to keep AI alive
