---
name: "apply_review_feedback"
description: "Applies review feedback from OverseerAI to code. Invoke when receiving review messages or after code review feedback."
---

# Apply Review Feedback

This skill processes review feedback from OverseerAI and applies the necessary changes to the codebase.

## When to Use

- **When receiving a review message** - process and apply the feedback
- **After code review** - implement suggested changes
- **When requested to fix issues** - address specific review comments
- **After approval with conditions** - implement required changes before final approval

## Review Message Format

Review messages follow the standard Message format:

```json
{
  "id": "review_<timestamp>",
  "from": "OverseerAI",
  "to": "Creator",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "review",
  "content": {
    "task_id": "<task_id>",
    "status": "<approved|needs_revision|rejected>",
    "feedback": "<feedback_description>",
    "changes": [
      {
        "file": "<file_path>",
        "line": "<line_number>",
        "issue": "<issue_description>",
        "suggestion": "<suggested_fix>"
      }
    ],
    "requirements": ["<additional_requirements>"]
  }
}
```

## Processing Review Feedback

### Step 1: Read the Review Message

Read the review message from the ToProcess folder:

```bash
cat /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/review_<timestamp>.json
```

### Step 2: Analyze the Review

Extract the following information:
- **Status**: approved, needs_revision, or rejected
- **Task ID**: Which task this review is for
- **Feedback**: General feedback description
- **Changes**: Specific file/line changes needed
- **Requirements**: Additional requirements to meet

### Step 3: Determine Action

Based on the review status:

#### `approved`
- No changes needed
- Move to next task or submit for final approval
- Send status update confirming approval

#### `needs_revision`
- Apply the suggested changes
- Address all feedback points
- Test the changes
- Submit for re-review
- Send status update

#### `rejected`
- Understand why the work was rejected
- Discuss with OverseerAI if clarification needed
- Replan or restart the task as appropriate
- Send status update

### Step 4: Apply Changes

For each change in the review:

#### Read the File

```bash
cat /Users/jk/gits/hub/gitbrains/swiftgitbrain/<file_path>
```

#### Understand the Issue

Read the issue description and suggestion to understand what needs to be changed.

#### Make the Change

Use the appropriate tool to make the change:

**For simple edits** - use SearchReplace:
```swift
// Find the old code (include enough context for uniqueness)
old_str = "old code here"

// Replace with new code
new_str = "new code here"
```

**For complex changes** - read the file, understand the context, and make appropriate edits.

#### Verify the Change

After making changes:
1. Read the file to verify the change was applied correctly
2. Check for syntax errors
3. Run tests if applicable

### Step 5: Test Changes

After applying all changes:

#### Run Tests

```bash
swift test
```

#### Run Build

```bash
swift build
```

#### Run Linting (if configured)

```bash
swiftlint
```

### Step 6: Send Status Update

After applying changes and testing, send a status update to OverseerAI:

```json
{
  "id": "status_update_<timestamp>",
  "from": "Creator",
  "to": "OverseerAI",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "status_update",
  "content": {
    "status": "completed",
    "message": "Applied review feedback and tested changes",
    "details": {
      "task_id": "<task_id>",
      "review_id": "<review_id>",
      "changes_applied": [
        {
          "file": "<file_path>",
          "description": "<change_description>"
        }
      ],
      "test_results": "All tests passed",
      "next_steps": [
        "Submit for re-review"
      ]
    }
  }
}
```

### Step 7: Move the Review File

Move the processed review file to the Processed folder:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/review_<timestamp>.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

## Example Workflow

### Scenario: Needs Revision

**Review Message:**
```json
{
  "id": "review_async_syntax_fixes_2026-02-12T20:05:00Z",
  "from": "OverseerAI",
  "to": "Creator",
  "timestamp": "2026-02-12T20:05:00Z",
  "type": "review",
  "content": {
    "task_id": "task_fix_async_syntax_v2_2026-02-12T20:00:00Z",
    "status": "needs_revision",
    "feedback": "Missing 'await' keyword with #expect(throws:) in async tests",
    "changes": [
      {
        "file": "Tests/GitBrainSwiftTests/GitManagerTests.swift",
        "line": "15",
        "issue": "#expect(throws:) requires 'await' in async test functions",
        "suggestion": "Add 'await' before #expect(throws:)"
      }
    ],
    "requirements": [
      "Ensure all async tests use 'await' with #expect(throws:)"
    ]
  }
}
```

**Processing Steps:**

1. Read the review message
2. Identify the issue: Missing 'await' keyword
3. Read the file: `Tests/GitBrainSwiftTests/GitManagerTests.swift`
4. Find the problematic code
5. Apply the fix using SearchReplace
6. Verify the change
7. Run tests: `swift test`
8. Send status update
9. Move the review file to Processed

**Status Update:**
```json
{
  "id": "status_update_2026-02-12T20:10:00Z",
  "from": "Creator",
  "to": "OverseerAI",
  "timestamp": "2026-02-12T20:10:00Z",
  "type": "status_update",
  "content": {
    "status": "completed",
    "message": "Applied review feedback - added 'await' keywords to async tests",
    "details": {
      "task_id": "task_fix_async_syntax_v2_2026-02-12T20:00:00Z",
      "review_id": "review_async_syntax_fixes_2026-02-12T20:05:00Z",
      "changes_applied": [
        {
          "file": "Tests/GitBrainSwiftTests/GitManagerTests.swift",
          "description": "Added 'await' before #expect(throws:) in all async test functions"
        }
      ],
      "test_results": "All tests passed",
      "next_steps": [
        "Submit for re-review"
      ]
    }
  }
}
```

## Best Practices

1. **Read carefully** - understand the feedback before making changes
2. **Ask questions** - if feedback is unclear, ask for clarification
3. **Apply all changes** - address every point in the review
4. **Test thoroughly** - ensure changes don't break existing functionality
5. **Document changes** - keep track of what was changed and why
6. **Be responsive** - process reviews promptly
7. **Learn from feedback** - use reviews to improve code quality

## Common Review Feedback Types

### Syntax Errors
- Missing keywords (e.g., 'await', 'try')
- Incorrect function signatures
- Type mismatches

### Code Style
- Naming conventions
- Code organization
- Comment quality

### Architecture
- Design patterns
- Separation of concerns
- Protocol usage

### Testing
- Test coverage
- Test quality
- Edge cases

### Performance
- Efficiency improvements
- Memory usage
- Concurrency issues

## Integration with Other Skills

This skill works with:
- `process_to_process_folder` - receives review messages from ToProcess
- `create_status_update` - sends status updates after applying feedback
- `move_processed_files` - moves review files after processing

## Important Notes

- **Always test** after applying changes
- **Don't skip** any feedback points
- **Communicate** if you need clarification
- **Be thorough** - ensure all requirements are met
- **Update counter** - increment keepalive counter after processing
