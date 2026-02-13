---
name: "move_processed_files"
description: "Moves processed files from ToProcess to Processed folder. Invoke after processing messages or when cleaning up completed tasks."
---

# Move Processed Files

This skill handles moving processed files from the ToProcess folder to the Processed folder according to the collaboration workflow.

## When to Use

- **After processing a message** - move the file once processing is complete
- **After completing a task** - move the task file to Processed
- **After applying review feedback** - move the review file to Processed
- **When cleaning up** - move any completed files to maintain organization

## Folder Structure

```
GitBrain/Memory/
├── ToProcess/        # Incoming messages and tasks
└── Processed/        # Completed messages and tasks
```

## Moving Files

### Single File

To move a single file:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/<filename> /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

Example:
```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/task_example_2026-02-12T20:00:00Z.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

### Multiple Files

To move multiple files in one command:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/file1.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/ && mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/file2.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

### All Files

To move all files from ToProcess to Processed:

```bash
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/* /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

**Warning**: Only use this if you're certain all files have been processed.

## Verification

After moving files, verify the move was successful:

### Check ToProcess is empty (or has expected files)

```bash
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/
```

### Check Processed has the moved files

```bash
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/
```

### Count files in each folder

```bash
echo "ToProcess: $(ls -1 /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/ | wc -l)"
echo "Processed: $(ls -1 /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/ | wc -l)"
```

## Best Practices

1. **Move immediately after processing** - don't leave files in ToProcess once processed
2. **Verify before moving** - ensure the file was actually processed correctly
3. **Handle errors gracefully** - if a file can't be processed, move it anyway with a note
4. **Keep track of moved files** - log which files were moved for reference
5. **Batch moves when possible** - move multiple files in one command for efficiency
6. **Check for duplicates** - ensure files aren't already in Processed before moving

## Error Handling

### File Already Exists in Processed

If a file with the same name already exists in Processed:

```bash
# Add a suffix to avoid overwriting
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/<filename> /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/<filename>_duplicate
```

### File Cannot Be Moved

If a file cannot be moved (e.g., permission issues):

1. Log the error
2. Note the file path
3. Report the issue in a status update
4. Attempt to resolve or request help

## Integration with Other Skills

This skill works with:
- `process_to_process_folder` - moves files after processing
- `create_status_update` - can report which files were moved
- `apply_review_feedback` - moves review files after applying feedback

## Example Workflow

```bash
# 1. Process a task file
cat /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/task_example_2026-02-12T20:00:00Z.json

# 2. Implement the task (create todos, write code, etc.)

# 3. Move the processed file
mv /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/ToProcess/task_example_2026-02-12T20:00:00Z.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/

# 4. Verify the move
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/GitBrain/Memory/Processed/

# 5. Send status update (optional)
```

## Important Notes

- **Always verify** the move was successful
- **Don't move unprocessed files** - only move files that have been fully processed
- **Maintain order** - process files by timestamp (oldest first)
- **Update counter** - increment keepalive counter after moving files
- **Keep records** - track which files were moved and when
