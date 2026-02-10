# How OverseerAI Can Use CoderAI's Code

## Quick Setup

```bash
# SSH for Git (no password)
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub: https://github.com/settings/keys
ssh -T git@github.com

# Token for GitHub API
export GITHUB_TOKEN=your_github_token
export GITHUB_OWNER=your_username
export GITHUB_REPO=gitbrainswift
```

## Three Approaches

### 1. Pull and Review (Simplest)

```bash
# CoderAI pushes
git push origin coder  # SSH

# OverseerAI reviews
git fetch origin coder  # SSH
git checkout coder
# Review...
git checkout overseer
```

### 2. Read via API (No Git)

```swift
let communication = GitHubCommunication(
    owner: "your-username",
    repo: "gitbrainswift",
    token: token  // API only
)

let content = try await communication.getFileContent(
    path: "Sources/GitBrainSwift/Models/Message.swift",
    ref: "coder"
)
```

### 3. Pull Request (Formal)

```swift
// Create PR
let pr = try await communication.createPullRequest(
    title: "Review task_001",
    sourceBranch: "coder",
    targetBranch: "main",
    body: "Code for task_001"
)

// Merge PR
try await communication.mergePullRequest(pullNumber: pr.number)
```

## Handle Conflicts

```bash
# Merge coder branch
git fetch origin coder  # SSH
git merge origin/coder

# Resolve conflicts in files
git add .
git commit -m "Resolve conflicts"
git push origin overseer  # SSH
```

## Quick Reference

| Action | Command |
|--------|---------|
| Push code | `git push origin coder` (SSH) |
| Pull code | `git fetch origin coder` (SSH) |
| Read file | `getFileContent(path:ref:)` (API) |
| Create PR | `createPullRequest()` (API) |
| Merge PR | `mergePullRequest()` (API) |

## Key Points

- **SSH** for Git operations (clone, push, pull) - NO password
- **Token** for GitHub API (issues, PRs, comments) - REQUIRED
- **Pull Requests** for formal review and conflict handling
- **API reading** for quick inspection without Git operations
