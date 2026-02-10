# How OverseerAI Can Contact CoderAI

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

## Send Message to CoderAI

```swift
let communication = GitHubCommunication(
    owner: "your-username",
    repo: "gitbrainswift",
    token: token  // API only
)

let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    task: "Implement feature X",
    priority: .high
)

let issueURL = try await communication.sendMessage(message, from: "overseer", to: "coder")
print("Message sent: \(issueURL)")
```

## Receive Messages from CoderAI

```swift
let messages = try await communication.receiveMessages(for: "overseer")

for message in messages {
    switch message.messageType {
    case .code:
        print("Code received: \(message.content)")
    case .status:
        print("Status: \(message.content)")
    case .error:
        print("Error: \(message.content)")
    default:
        break
    }
}
```

## Message Types

| Type | Purpose |
|------|---------|
| `task` | Assign task to CoderAI |
| `code` | CoderAI submits code |
| `status` | Update on progress |
| `error` | Report errors |
| `approval` | Approve code |
| `rejection` | Reject code |

## Example: Task Assignment

```swift
let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    task: "Implement new Message type",
    priority: .high
)

try await communication.sendMessage(message, from: "overseer", to: "coder")
```

## Example: Code Review

```swift
// Receive code from CoderAI
let messages = try await communication.receiveMessages(for: "overseer")

for message in messages where message.messageType == .code {
    // Review code...
    let approved = true

    if approved {
        let response = MessageBuilder.createApprovalMessage(
            fromAI: "overseer",
            toAI: "coder",
            taskID: message.taskID
        )
        try await communication.sendMessage(response, from: "overseer", to: "coder")
    }
}
```

## Quick Reference

| Action | Code |
|--------|------|
| Send message | `sendMessage(message:from:to:)` |
| Receive messages | `receiveMessages(for:)` |
| Create task | `MessageBuilder.createTaskMessage()` |
| Create approval | `MessageBuilder.createApprovalMessage()` |
| Create rejection | `MessageBuilder.createRejectionMessage()` |

## Key Points

- **SSH** for Git operations (clone, push, pull) - NO password
- **Token** for GitHub API (issues, PRs, comments) - REQUIRED
- **GitHub Issues** as communication channel
- **Messages** are stored as JSON in issue body
- **Labels** identify recipient and message type
