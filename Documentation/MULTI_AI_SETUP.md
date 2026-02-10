# GitBrainSwift Multi-AI Setup Guide

This guide explains how to set up multiple AIs (CoderAI and OverseerAI) to collaborate using the same Git repository.

## Architecture

```
Git Repository: gitbrainswift
├── Sources/
│   ├── GitBrainSwift/          ← Shared library code
│   ├── GitBrainCLI/            ← CLI tools
│   └── GitBrainGitHubDemo/      ← Demo programs
├── coder-worktree/              ← CoderAI's working directory
│   ├── .coder-state/           ← CoderAI's local state
│   └── coder-messages/         ← Local message cache (optional)
├── overseer-worktree/          ← OverseerAI's working directory
│   ├── .overseer-state/        ← OverseerAI's local state
│   └── overseer-messages/      ← Local message cache (optional)
└── Documentation/               ← Shared documentation
```

## Key Concepts

### 1. Code Sharing via Git
- Both AIs work in the same Git repository
- Code changes are shared via `git push` and `git pull`
- Each AI has its own worktree for isolation
- Pull Requests can be used for code review

### 2. Communication via GitHub Issues
- Messages are sent as GitHub Issues
- No file sharing required for communication
- Persistent message history
- Works across different machines

## Setup Steps

### Step 1: Create Repository Structure

```bash
# Create main repository
mkdir -p gitbrainswift
cd gitbrainswift
git init

# Create worktrees
git worktree add coder-worktree -b coder
git worktree add overseer-worktree -b overseer
```

### Step 2: Deploy GitBrainSwift Library

The GitBrainSwift library code should be in the main repository:

```bash
# In the main repository
git checkout main

# Copy or create GitBrainSwift library
mkdir -p Sources/GitBrainSwift
# ... add all library files ...

# Commit and push
git add .
git commit -m "Add GitBrainSwift library"
git push origin main
```

### Step 3: Setup CoderAI Worktree

```bash
# Switch to coder worktree
cd coder-worktree

# Pull latest code
git pull origin coder

# Setup environment
export GITHUB_TOKEN=your_token
export GITHUB_OWNER=your_username
export GITHUB_REPO=gitbrainswift

# Initialize CoderAI
swift run gitbrain-github-demo
```

### Step 4: Setup OverseerAI Worktree

```bash
# Switch to overseer worktree
cd ../overseer-worktree

# Pull latest code
git pull origin overseer

# Setup environment
export GITHUB_TOKEN=your_token
export GITHUB_OWNER=your_username
export GITHUB_REPO=gitbrainswift

# Initialize OverseerAI
# (Use similar initialization as CoderAI)
```

## Workflow

### Scenario: OverseerAI Assigns Task to CoderAI

1. **OverseerAI** creates GitHub Issue:
   ```swift
   let communication = GitHubCommunication(
       owner: "your-username",
       repo: "gitbrainswift",
       token: token
   )

   let message = MessageBuilder.createTaskMessage(
       fromAI: "overseer",
       toAI: "coder",
       taskID: "task_001",
       taskDescription: "Implement feature X"
   )

   try await communication.sendMessage(message, from: "overseer", to: "coder")
   ```

2. **CoderAI** receives task via GitHub Issue:
   ```swift
   let messages = try await communication.receiveMessages(for: "coder")
   for message in messages {
       await coder.processMessage(message)
   }
   ```

3. **CoderAI** implements feature and commits code:
   ```bash
   # In coder-worktree
   git add .
   git commit -m "Implement feature X"
   git push origin coder
   ```

4. **CoderAI** submits code via GitHub Issue:
   ```swift
   try await coder.submitCode(reviewer: "overseer")
   ```

5. **OverseerAI** receives code via GitHub Issue:
   ```swift
   let messages = try await communication.receiveMessages(for: "overseer")
   for message in messages {
       await overseer.processMessage(message)
   }
   ```

6. **OverseerAI** reviews code by pulling from Git:
   ```bash
   # In overseer-worktree
   git fetch origin coder
   git checkout coder
   # Review code...
   ```

7. **OverseerAI** approves/rejects via GitHub Issue:
   ```swift
   if approved {
       try await overseer.approveCode(taskID: "task_001", coder: "coder")
   } else {
       try await overseer.rejectCode(taskID: "task_001", reason: "Needs improvement", coder: "coder")
   }
   ```

## Advantages

### For Code Sharing:
- ✅ Version control via Git
- ✅ Pull Requests for code review
- ✅ Merge conflicts handled by Git
- ✅ Complete code history
- ✅ Branch isolation per AI

### For Communication:
- ✅ No file permission issues
- ✅ Works across different machines
- ✅ Persistent message history
- ✅ Searchable via GitHub UI
- ✅ Built-in features (labels, comments)

## Environment Variables

Both AIs need these environment variables:

```bash
# GitHub Configuration
export GITHUB_TOKEN=your_github_token
export GITHUB_OWNER=your_username
export GITHUB_REPO=gitbrainswift

# Optional: Worktree-specific paths
export CODER_WORKTREE=/path/to/coder-worktree
export OVERSEER_WORKTREE=/path/to/overseer-worktree
export BRAINSTATE_BASE=/path/to/brainstates
```

## Quick Start

### Initial Setup (One-time):

```bash
# Clone repository
git clone https://github.com/your-username/gitbrainswift.git
cd gitbrainswift

# Create worktrees
git worktree add coder-worktree -b coder
git worktree add overseer-worktree -b overseer

# Set environment variables
export GITHUB_TOKEN=your_token
export GITHUB_OWNER=your_username
export GITHUB_REPO=gitbrainswift
```

### Daily Workflow:

**CoderAI:**
```bash
cd coder-worktree
git pull origin coder
swift run coder-ai  # Run CoderAI
git add .
git commit -m "Update code"
git push origin coder
```

**OverseerAI:**
```bash
cd overseer-worktree
git pull origin overseer
swift run overseer-ai  # Run OverseerAI
git fetch origin coder
git checkout coder  # Review CoderAI's code
```

## Troubleshooting

### Worktree Issues

**Error: worktree already exists**
```bash
git worktree remove coder-worktree
git worktree add coder-worktree -b coder
```

**Error: branch already exists**
```bash
git checkout coder
cd ..
git worktree add coder-worktree coder
```

### GitHub Issues Issues

**Rate limit exceeded**
- Wait for rate limit to reset (1 hour)
- Use authentication (5,000 requests/hour)

**Unauthorized**
- Verify GITHUB_TOKEN is correct
- Check token has `repo` and `issues` permissions

### Git Issues

**Merge conflicts**
```bash
git pull origin coder
# Resolve conflicts
git add .
git commit -m "Resolve conflicts"
git push origin coder
```

## Best Practices

1. **Separate Branches**: Each AI works on its own branch
2. **Regular Pulls**: Always pull before pushing
3. **Clear Messages**: Close GitHub Issues after processing
4. **Use Labels**: Organize GitHub Issues with labels
5. **Commit Often**: Small, frequent commits are better
6. **Code Review**: Use Pull Requests for major changes
7. **Backup**: Regularly push to GitHub

## Summary

- **Code Sharing**: Git (push/pull, worktrees)
- **Communication**: GitHub Issues (messaging)
- **Code Review**: Pull Requests (optional)
- **Isolation**: Each AI has its own worktree
- **Collaboration**: Both work in same repository

This setup allows CoderAI and OverseerAI to collaborate effectively without file permission issues or manual file copying!
