# CLI Tools Documentation

This guide provides comprehensive documentation for the GitBrainSwift CLI tools.

## Overview

GitBrainSwift includes command-line tools for managing AI-assisted collaborative development. These tools provide convenient ways to initialize, configure, and monitor GitBrainSwift from the terminal.

## Installation

### Building the CLI

```bash
cd /path/to/gitbrainswift
swift build
```

### Installing Globally

```bash
swift build -c release
sudo cp .build/release/gitbrain /usr/local/bin/gitbrain
```

## Commands

### init

Initialize a new GitBrain folder structure.

```bash
gitbrain init [path]
```

#### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `path` | Path to GitBrain folder | No (default: ./GitBrain or $GITBRAIN_PATH) |

#### Description

Creates the following folder structure:
```
GitBrain/
├── Overseer/          # OverseerAI working folder
├── Memory/            # Shared persistent memory
├── Docs/              # Documentation for AIs
└── README.md          # GitBrain usage guide
```

#### Examples

```bash
# Initialize in default location (./GitBrain)
gitbrain init

# Initialize in custom location
gitbrain init /custom/path/to/GitBrain

# Initialize using environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain
gitbrain init
```

#### Output

```
Initializing GitBrain...
Path: ./GitBrain
✓ Created GitBrain/Overseer/
✓ Created GitBrain/Memory/
✓ Created GitBrain/Docs/
✓ Created GitBrain/README.md

Initialization complete!

Next steps:
1. Open Trae at project root for CoderAI: trae .
2. Open Trae at GitBrain for OverseerAI: trae ./GitBrain
3. Ask each AI to read GitBrain/Docs/ to understand their role
```

### send

Send a message to another AI.

```bash
gitbrain send <to> <message> [path]
```

#### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `to` | Recipient: 'coder' or 'overseer' | Yes |
| `message` | JSON string or file path | Yes |
| `path` | Path to GitBrain folder | No (default: ./GitBrain or $GITBRAIN_PATH) |

#### Description

Sends a message to the specified AI. The message can be provided as:
- A JSON string (must start with `{` or `[`)
- A file path containing JSON

#### Examples

```bash
# Send JSON string to overseer
gitbrain send overseer '{"type":"code_review","files":["file.swift"]}'

# Send JSON string to coder
gitbrain send coder '{"type":"task","description":"Implement feature X"}'

# Send message from file
gitbrain send overseer /path/to/message.json

# Send to custom GitBrain location
gitbrain send overseer '{"type":"status"}' /custom/path/to/GitBrain

# Using environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain
gitbrain send coder '{"type":"heartbeat"}'
```

#### Output

```
✓ Message sent to: overseer
  Path: ./GitBrain/Overseer/2024-02-11T12:34:56Z_abc123.json
```

### check

Check messages for a specific role.

```bash
gitbrain check [role] [path]
```

#### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `role` | Role to check: 'coder' or 'overseer' | No (default: coder) |
| `path` | Path to GitBrain folder | No (default: ./GitBrain or $GITBRAIN_PATH) |

#### Description

Retrieves and displays all messages for the specified role.

#### Examples

```bash
# Check messages for coder (default)
gitbrain check

# Check messages for overseer
gitbrain check overseer

# Check messages in custom GitBrain location
gitbrain check coder /custom/path/to/GitBrain

# Using environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain
gitbrain check overseer
```

#### Output

```
Messages for 'coder': 2

Messages:
  [overseer -> coder] 2024-02-11T12:34:56Z
    Content: ["type": "task", "description": "Implement feature X"]
  [overseer -> coder] 2024-02-11T12:35:00Z
    Content: ["type": "code_review", "files": ["file.swift"]]
```

### clear

Clear messages for a specific role.

```bash
gitbrain clear [role] [path]
```

#### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `role` | Role to clear: 'coder' or 'overseer' | No (default: coder) |
| `path` | Path to GitBrain folder | No (default: ./GitBrain or $GITBRAIN_PATH) |

#### Description

Removes all messages for the specified role.

#### Examples

```bash
# Clear messages for coder (default)
gitbrain clear

# Clear messages for overseer
gitbrain clear overseer

# Clear messages in custom GitBrain location
gitbrain clear coder /custom/path/to/GitBrain

# Using environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain
gitbrain clear overseer
```

#### Output

```
✓ Cleared messages for coder
```

### help

Display help information.

```bash
gitbrain help
```

#### Description

Shows usage information for all commands.

#### Output

```
GitBrain CLI - AI-Assisted Collaborative Development Tool

Usage: gitbrain <command> [arguments]

Commands:
  init [path]          Initialize GitBrain folder structure
  send <to> <message>  Send a message to another AI
  check [role]         Check messages for a role
  clear [role]         Clear messages for a role
  help                 Show this help message

Arguments:
  path                 Path to GitBrain folder (default: ./GitBrain or $GITBRAIN_PATH)
  to                   Recipient: 'coder' or 'overseer'
  message              JSON string or file path
  role                 Role to check/clear: 'coder' or 'overseer'

Environment Variables:
  GITBRAIN_PATH        Default path to GitBrain folder (overrides ./GitBrain)

Examples:
  gitbrain init
  gitbrain send overseer '{"type":"code_review","files":["file.swift"]}'
  gitbrain check coder
  gitbrain clear overseer
  
  # Using environment variable
  export GITBRAIN_PATH=/custom/path/to/GitBrain
  gitbrain check coder

For more information, see GitBrain/README.md
```

## Environment Variables

GitBrainSwift CLI supports the following environment variable:

| Variable | Description | Example |
|----------|-------------|---------|
| `GITBRAIN_PATH` | Default path to GitBrain folder | `/custom/path/to/GitBrain` |

### Setting Environment Variables

#### macOS/Linux (bash/zsh)

```bash
export GITBRAIN_PATH=/custom/path/to/GitBrain
```

#### macOS/Linux (fish)

```bash
set -x GITBRAIN_PATH /custom/path/to/GitBrain
```

#### Windows (PowerShell)

```powershell
$env:GITBRAIN_PATH="C:\custom\path\to\GitBrain"
```

### Permanent Settings

To make the environment variable persistent, add it to your shell configuration file:

```bash
# For bash/zsh (~/.zshrc or ~/.bash_profile)
echo 'export GITBRAIN_PATH=/custom/path/to/GitBrain' >> ~/.zshrc

# Reload the shell
source ~/.zshrc
```

## Message Format

Messages are sent as JSON with the following structure:

```json
{
  "type": "task|code|review|feedback|approval|rejection|status|heartbeat",
  "task_id": "unique-task-id",
  "description": "Task description",
  "files": ["file1.swift", "file2.swift"],
  "comments": ["comment1", "comment2"],
  "approved": true,
  "priority": 5
}
```

### Message Types

| Type | Description |
|------|-------------|
| `task` | Assign a task to an AI |
| `code` | Submit code for review |
| `review` | Provide code review feedback |
| `feedback` | General feedback or comments |
| `approval` | Approve submitted work |
| `rejection` | Reject submitted work |
| `status` | Status update |
| `heartbeat` | Keep-alive message |

## Common Workflows

### Initial Setup

```bash
# Initialize GitBrain
gitbrain init

# Open Trae for CoderAI (in another terminal)
trae .

# Open Trae for OverseerAI (in another terminal)
trae ./GitBrain
```

### Sending a Task to CoderAI

```bash
# From OverseerAI
gitbrain send coder '{
  "type": "task",
  "task_id": "feature-001",
  "description": "Implement user authentication",
  "task_type": "coding",
  "priority": 8
}'
```

### Submitting Code for Review

```bash
# From CoderAI
gitbrain send overseer '{
  "type": "code",
  "task_id": "feature-001",
  "files": ["Sources/Auth/UserAuth.swift", "Tests/AuthTests.swift"],
  "description": "User authentication implementation"
}'
```

### Checking Messages

```bash
# Check messages for coder
gitbrain check coder

# Check messages for overseer
gitbrain check overseer
```

### Clearing Messages

```bash
# Clear old messages for coder
gitbrain clear coder

# Clear old messages for overseer
gitbrain clear overseer
```

### Using Custom GitBrain Location

```bash
# Set environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain

# All commands will now use the custom path
gitbrain check coder
gitbrain send overseer '{"type":"status"}'
gitbrain clear overseer
```

## Troubleshooting

### Command Not Found

**Error**: `command not found: gitbrain`

**Solution**: Install the CLI globally or add the build directory to your PATH.

```bash
# Add to PATH
export PATH="$PATH:/path/to/gitbrainswift/.build/debug"

# Or install globally
swift build -c release
sudo cp .build/release/gitbrain /usr/local/bin/gitbrain
```

### GitBrain Folder Not Found

**Error**: `The folder "GitBrain" doesn't exist`

**Solution**: Initialize GitBrain first.

```bash
gitbrain init
```

### Invalid JSON

**Error**: `The data couldn't be read`

**Solution**: Ensure your JSON is valid.

```bash
# Validate JSON before sending
echo '{"type":"task"}' | jq .

# Or use a file
echo '{"type":"task"}' > message.json
gitbrain send overseer message.json
```

### Permission Denied

**Error**: `You don't have permission to save the file`

**Solution**: Check folder permissions.

```bash
# Check permissions
ls -la ./GitBrain

# Fix permissions
chmod 755 ./GitBrain
chmod 755 ./GitBrain/Overseer
chmod 755 ./GitBrain/Memory
```

## Advanced Usage

### Scripting

You can use GitBrainSwift CLI in scripts:

```bash
#!/bin/bash

# Check for new messages
messages=$(gitbrain check coder 2>&1)

if [[ $messages == *"Messages for 'coder': 0"* ]]; then
    echo "No new messages"
else
    echo "New messages received:"
    echo "$messages"
fi
```

### Automation with Cron

Automate GitBrainSwift tasks using cron:

```bash
# Check for messages every 5 minutes
*/5 * * * * cd /path/to/project && gitbrain check coder >> /var/log/gitbrain.log

# Clear old messages daily at midnight
0 0 * * * cd /path/to/project && gitbrain clear coder && gitbrain clear overseer
```

### Integration with Git Hooks

Integrate GitBrainSwift with Git hooks:

```bash
# .git/hooks/pre-commit
#!/bin/bash
gitbrain send overseer '{
  "type": "status",
  "description": "Committing changes",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
}'
```

## Performance Tips

1. **Use Environment Variables**: Set `GITBRAIN_PATH` to avoid repeating the path.

2. **Clear Old Messages**: Regularly clear old messages to improve performance.

3. **Use File Paths**: For large messages, use file paths instead of inline JSON.

4. **Batch Operations**: Group related operations together to reduce overhead.

## Security Considerations

1. **Protect GitBrain Folder**: Ensure the GitBrain folder has appropriate permissions.

2. **Validate Messages**: Always validate message content before processing.

3. **Secure Communication**: Messages are stored locally, but ensure the file system is secure.

4. **Clean Up**: Remove the GitBrain folder after development is complete.

## Cross-Language Usage

GitBrainSwift CLI can be used from any programming language that can spawn subprocesses:

### Python

```python
import subprocess
import json

message = {
    "type": "task",
    "task_id": "py-task-001",
    "description": "Implement Python function"
}

result = subprocess.run(
    ["gitbrain", "send", "overseer", json.dumps(message)],
    capture_output=True,
    text=True
)
print(result.stdout)
```

### JavaScript/Node.js

```javascript
const { exec } = require('child_process');

const message = JSON.stringify({
    type: 'task',
    task_id: 'js-task-001',
    description: 'Implement JavaScript function'
});

exec(`gitbrain send overseer '${message}'`, (error, stdout, stderr) => {
    if (error) {
        console.error(`Error: ${stderr}`);
        return;
    }
    console.log(stdout);
});
```

### Rust

```rust
use std::process::Command;

fn main() {
    let message = r#"{"type":"task","task_id":"rs-task-001","description":"Implement Rust function"}"#;
    
    let output = Command::new("gitbrain")
        .args(&["send", "overseer", message])
        .output()
        .expect("Failed to execute command");
    
    println!("{}", String::from_utf8_lossy(&output.stdout));
}
```

### Go

```go
package main

import (
    "encoding/json"
    "fmt"
    "os/exec"
)

func main() {
    message := map[string]interface{}{
        "type":        "task",
        "task_id":     "go-task-001",
        "description": "Implement Go function",
    }
    
    jsonData, _ := json.Marshal(message)
    
    cmd := exec.Command("gitbrain", "send", "overseer", string(jsonData))
    output, err := cmd.CombinedOutput()
    if err != nil {
        fmt.Printf("Error: %s\n", err)
        return
    }
    fmt.Println(string(output))
}
```

## Contributing

To contribute to the CLI tools:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Open an issue on GitHub
- Check the README.md
- Review the troubleshooting section

## See Also

- [README.md](../README.md) - Main project documentation
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Design decisions and rationale
- [CROSS_LANGUAGE_DEPLOYMENT.md](CROSS_LANGUAGE_DEPLOYMENT.md) - Cross-language usage examples
- [DEVELOPMENT.md](DEVELOPMENT.md) - Building, testing, and contributing
