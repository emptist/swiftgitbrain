# CLI Tools Documentation

This guide provides comprehensive documentation for the GitBrainSwift CLI tools.

## Overview

GitBrainSwift includes command-line tools for managing the AI collaboration system. These tools provide convenient ways to initialize, configure, and monitor GitBrainSwift from the terminal.

## Installation

### Building the CLI

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain
swift build
```

### Installing Globally

```bash
swift build -c release
sudo cp .build/release/GitBrainCLI /usr/local/bin/gitbrain
```

## Commands

### init

Initialize a new GitBrainSwift workspace.

```bash
gitbrain init --owner <username> --repo <repository> [options]
```

#### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--owner` | GitHub repository owner | Yes |
| `--repo` | GitHub repository name | Yes |
| `--token` | GitHub personal access token | No (uses env var) |
| `--brainstate-base` | Path to brainstate directory | No (default: ./brainstates) |
| `--shared-worktree` | Path to shared worktree | No (default: ./shared-worktree) |

#### Examples

```bash
gitbrain init --owner myusername --repo myproject
```

```bash
gitbrain init --owner myusername --repo myproject --token ghp_xxx
```

```bash
gitbrain init --owner myusername --repo myproject --brainstate-base ./states --shared-worktree ./shared
```

### worktree

Manage Git worktrees for AI collaboration.

#### worktree create

Create a new worktree for an AI role.

```bash
gitbrain worktree create --path <path> --branch <branch> [options]
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--path` | Path for the new worktree | Yes |
| `--branch` | Branch name for the worktree | Yes |
| `--role` | AI role name | No |

##### Examples

```bash
gitbrain worktree create --path ./coder-worktree --branch feature/coder-001
```

```bash
gitbrain worktree create --path ./overseer-worktree --branch main --role overseer
```

#### worktree list

List all worktrees in the repository.

```bash
gitbrain worktree list
```

##### Output

```
Worktrees:
  - ./coder-worktree (feature/coder-001)
  - ./overseer-worktree (main)
  - ./shared-worktree (shared)
```

#### worktree remove

Remove a worktree.

```bash
gitbrain worktree remove --path <path>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--path` | Path to the worktree to remove | Yes |

##### Examples

```bash
gitbrain worktree remove --path ./coder-worktree
```

#### worktree setup-shared

Setup a shared worktree for AI communication.

```bash
gitbrain worktree setup-shared --repository <repo-path> --shared-path <path>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--repository` | Path to the repository | Yes |
| `--shared-path` | Path for the shared worktree | Yes |

##### Examples

```bash
gitbrain worktree setup-shared --repository . --shared-path ./shared-worktree
```

### sync

Synchronize with GitHub repository.

```bash
gitbrain sync [options]
```

#### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--pull` | Pull changes from remote | No (default: true) |
| `--push` | Push changes to remote | No (default: true) |
| `--worktree` | Worktree path to sync | No (default: current directory) |

#### Examples

```bash
gitbrain sync
```

```bash
gitbrain sync --pull --push
```

```bash
gitbrain sync --worktree ./coder-worktree
```

### monitor

Monitor messages for a specific AI role.

```bash
gitbrain monitor --role <role> [options]
```

#### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--role` | AI role name (coder, overseer) | Yes |
| `--interval` | Check interval in seconds | No (default: 5) |
| `--output` | Output format (text, json) | No (default: text) |

#### Examples

```bash
gitbrain monitor --role coder
```

```bash
gitbrain monitor --role coder --interval 10
```

```bash
gitbrain monitor --role overseer --output json
```

### status

Display the status of the GitBrainSwift system.

```bash
gitbrain status [options]
```

#### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--role` | Filter by role | No |
| `--worktree` | Worktree path | No |

#### Examples

```bash
gitbrain status
```

```bash
gitbrain status --role coder
```

```bash
gitbrain status --worktree ./coder-worktree
```

#### Output

```
GitBrainSwift Status:
  System: My GitBrain Workspace
  Version: 1.0.0
  
  Roles:
    - coder: enabled
    - overseer: enabled
  
  Worktrees:
    - ./coder-worktree (feature/coder-001)
    - ./overseer-worktree (main)
    - ./shared-worktree (shared)
  
  Messages:
    - coder: 3 unread
    - overseer: 1 unread
```

### message

Send a message to an AI role.

```bash
gitbrain message --to <role> --type <type> [options]
```

#### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--to` | Recipient role name | Yes |
| `--type` | Message type (task, code, review, feedback, approval, rejection, status, heartbeat) | Yes |
| `--content` | Message content (JSON) | No |
| `--priority` | Message priority (1-10) | No (default: 5) |
| `--file` | Load message from file | No |

#### Examples

```bash
gitbrain message --to coder --type task --content '{"task_id":"001","description":"Implement feature"}'
```

```bash
gitbrain message --to overseer --type code --priority 8 --file ./message.json
```

### brainstate

Manage AI brainstate files.

#### brainstate list

List all brainstates.

```bash
gitbrain brainstate list
```

#### Output

```
Brainstates:
  - coder_state.json (coder) - Last updated: 2024-01-15T10:30:00Z
  - overseer_state.json (overseer) - Last updated: 2024-01-15T10:35:00Z
```

#### brainstate show

Display a specific brainstate.

```bash
gitbrain brainstate show --role <role>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--role` | AI role name | Yes |
| `--output` | Output format (text, json) | No (default: text) |

##### Examples

```bash
gitbrain brainstate show --role coder
```

```bash
gitbrain brainstate show --role coder --output json
```

#### brainstate backup

Backup a brainstate.

```bash
gitbrain brainstate backup --role <role> [options]
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--role` | AI role name | Yes |
| `--destination` | Backup destination path | No (default: ./backups) |

##### Examples

```bash
gitbrain brainstate backup --role coder
```

```bash
gitbrain brainstate backup --role coder --destination ./my-backups
```

#### brainstate restore

Restore a brainstate from backup.

```bash
gitbrain brainstate restore --role <role> --source <source>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--role` | AI role name | Yes |
| `--source` | Backup source path | Yes |

##### Examples

```bash
gitbrain brainstate restore --role coder --source ./backups/coder_state_20240115.json
```

### knowledge

Manage the knowledge base.

#### knowledge add

Add knowledge to the knowledge base.

```bash
gitbrain knowledge add --category <category> --key <key> --value <value>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--category` | Knowledge category | Yes |
| `--key` | Knowledge key | Yes |
| `--value` | Knowledge value (JSON) | Yes |
| `--file` | Load knowledge from file | No |

##### Examples

```bash
gitbrain knowledge add --category patterns --key mvvm --value '{"description":"MVVM pattern"}'
```

```bash
gitbrain knowledge add --category api --key github --file ./github_api.json
```

#### knowledge get

Get knowledge from the knowledge base.

```bash
gitbrain knowledge get --category <category> --key <key> [options]
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--category` | Knowledge category | Yes |
| `--key` | Knowledge key | Yes |
| `--output` | Output format (text, json) | No (default: text) |

##### Examples

```bash
gitbrain knowledge get --category patterns --key mvvm
```

```bash
gitbrain knowledge get --category api --key github --output json
```

#### knowledge list

List knowledge categories or keys.

```bash
gitbrain knowledge list [options]
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--category` | List keys in category | No |

##### Examples

```bash
gitbrain knowledge list
```

```bash
gitbrain knowledge list --category patterns
```

#### knowledge search

Search the knowledge base.

```bash
gitbrain knowledge search --query <query> [options]
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--query` | Search query | Yes |
| `--category` | Search in specific category | No |

##### Examples

```bash
gitbrain knowledge search --query "pattern"
```

```bash
gitbrain knowledge search --query "API" --category api
```

#### knowledge delete

Delete knowledge from the knowledge base.

```bash
gitbrain knowledge delete --category <category> --key <key>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--category` | Knowledge category | Yes |
| `--key` | Knowledge key | Yes |

##### Examples

```bash
gitbrain knowledge delete --category patterns --key mvvm
```

### config

Manage GitBrainSwift configuration.

#### config get

Get a configuration value.

```bash
gitbrain config get --key <key>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--key` | Configuration key | Yes |

##### Examples

```bash
gitbrain config get --key system.name
```

```bash
gitbrain config get --key system.version
```

#### config set

Set a configuration value.

```bash
gitbrain config set --key <key> --value <value>
```

##### Options

| Option | Description | Required |
|--------|-------------|----------|
| `--key` | Configuration key | Yes |
| `--value` | Configuration value | Yes |

##### Examples

```bash
gitbrain config set --key system.checkInterval --value 10
```

```bash
gitbrain config set --key system.autoSave --value true
```

#### config list

List all configuration values.

```bash
gitbrain config list
```

#### Output

```
Configuration:
  system.name: My GitBrain Workspace
  system.version: 1.0.0
  system.checkInterval: 5
  system.configCheckInterval: 60
  system.hotReload: false
  system.autoSave: true
  system.saveInterval: 30
```

### help

Display help information.

```bash
gitbrain help [command]
```

#### Examples

```bash
gitbrain help
```

```bash
gitbrain help init
```

```bash
gitbrain help worktree
```

## Environment Variables

GitBrainSwift CLI supports the following environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_TOKEN` | GitHub personal access token | `ghp_xxx` |
| `GITBRAIN_BRASTATE_BASE` | Path to brainstate directory | `./brainstates` |
| `GITBRAIN_SHARED_WORKTREE` | Path to shared worktree | `./shared-worktree` |
| `GITBRAIN_OWNER` | GitHub repository owner | `myusername` |
| `GITBRAIN_REPO` | GitHub repository name | `myproject` |

### Setting Environment Variables

#### macOS/Linux (bash/zsh)

```bash
export GITHUB_TOKEN="ghp_xxx"
export GITBRAIN_BRASTATE_BASE="./brainstates"
export GITBRAIN_SHARED_WORKTREE="./shared-worktree"
```

#### macOS/Linux (fish)

```bash
set -x GITHUB_TOKEN "ghp_xxx"
set -x GITBRAIN_BRASTATE_BASE "./brainstates"
set -x GITBRAIN_SHARED_WORKTREE "./shared-worktree"
```

#### Windows (PowerShell)

```powershell
$env:GITHUB_TOKEN="ghp_xxx"
$env:GITBRAIN_BRASTATE_BASE="./brainstates"
$env:GITBRAIN_SHARED_WORKTREE="./shared-worktree"
```

## Configuration File

GitBrainSwift can be configured using a configuration file.

### Location

The configuration file is located at:
- `~/.gitbrain/config.json` (user-specific)
- `.gitbrain/config.json` (project-specific)

### Example Configuration

```json
{
  "system": {
    "name": "My GitBrain Workspace",
    "version": "1.0.0",
    "checkInterval": 5,
    "configCheckInterval": 60,
    "hotReload": false,
    "autoSave": true,
    "saveInterval": 30
  },
  "github": {
    "owner": "myusername",
    "repo": "myproject",
    "token": "ghp_xxx"
  },
  "paths": {
    "brainstateBase": "./brainstates",
    "sharedWorktree": "./shared-worktree"
  },
  "roles": {
    "coder": {
      "enabled": true,
      "mailbox": "coder",
      "brainstateFile": "coder_state.json"
    },
    "overseer": {
      "enabled": true,
      "mailbox": "overseer",
      "brainstateFile": "overseer_state.json"
    }
  }
}
```

## Common Workflows

### Initial Setup

```bash
gitbrain init --owner myusername --repo myproject
gitbrain worktree setup-shared --repository . --shared-path ./shared-worktree
gitbrain worktree create --path ./coder-worktree --branch feature/coder-001 --role coder
gitbrain worktree create --path ./overseer-worktree --branch main --role overseer
```

### Daily Workflow

```bash
gitbrain sync
gitbrain monitor --role coder
```

### Submitting Code

```bash
cd ./coder-worktree
git add .
git commit -m "Implement feature"
gitbrain sync --push
gitbrain message --to overseer --type code --content '{"task_id":"001","files":["file1.swift"]}'
```

### Reviewing Code

```bash
cd ./overseer-worktree
gitbrain sync --pull
gitbrain message --to coder --type feedback --content '{"task_id":"001","comments":"Looks good!"}'
```

### Backup and Restore

```bash
gitbrain brainstate backup --role coder
gitbrain brainstate restore --role coder --source ./backups/coder_state_20240115.json
```

## Troubleshooting

### Command Not Found

**Error**: `command not found: gitbrain`

**Solution**: Install the CLI globally or add the build directory to your PATH.

```bash
export PATH="$PATH:/Users/jk/gits/hub/gitbrains/swiftgitbrain/.build/debug"
```

### GitHub Authentication Failed

**Error**: `GitHub authentication failed`

**Solution**: Check your GitHub token and permissions.

```bash
export GITHUB_TOKEN="ghp_xxx"
gitbrain config get --key github.token
```

### Worktree Already Exists

**Error**: `Worktree already exists`

**Solution**: Remove the existing worktree or use a different path.

```bash
gitbrain worktree remove --path ./coder-worktree
gitbrain worktree create --path ./coder-worktree --branch feature/coder-001
```

### No Messages Found

**Error**: `No messages found for role`

**Solution**: Check GitHub Issues and ensure messages are properly labeled.

```bash
gitbrain status --role coder
```

## Advanced Usage

### Scripting

You can use GitBrainSwift CLI in scripts:

```bash
#!/bin/bash

gitbrain sync
messages=$(gitbrain monitor --role coder --interval 1 --output json | jq '.messages')

if [ "$messages" != "[]" ]; then
    echo "Processing messages..."
fi
```

### Automation with Cron

Automate GitBrainSwift tasks using cron:

```bash
# Sync every 5 minutes
*/5 * * * * cd /path/to/project && gitbrain sync

# Monitor messages every minute
* * * * * cd /path/to/project && gitbrain monitor --role coder --interval 1
```

### Integration with Git Hooks

Integrate GitBrainSwift with Git hooks:

```bash
# .git/hooks/pre-commit
#!/bin/bash
gitbrain sync --pull
gitbrain message --to overseer --type status --content '{"status":"committing"}'
```

## Performance Tips

1. **Use Environment Variables**: Set frequently used values as environment variables to avoid repeating them.

2. **Adjust Check Intervals**: Increase check intervals for less frequent monitoring.

3. **Use JSON Output**: Use JSON output for programmatic processing.

4. **Batch Operations**: Group related operations together to reduce overhead.

## Security Considerations

1. **Protect GitHub Token**: Never commit your GitHub token to version control. Use environment variables or configuration files.

2. **Secure Configuration**: Ensure configuration files have appropriate permissions.

3. **Validate Inputs**: Always validate user inputs before processing.

4. **Use HTTPS**: Always use HTTPS for GitHub API calls.

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
- Check the documentation
- Review the troubleshooting section

## See Also

- [GitHub Integration Guide](GITHUB_INTEGRATION.md)
- [Shared Worktree Setup Guide](SHARED_WORKTREE_SETUP.md)
- [CoderAI Usage Guide](CODERAI_USAGE.md)
- [Implementation Guide](IMPLEMENTATION_GUIDE.md)
