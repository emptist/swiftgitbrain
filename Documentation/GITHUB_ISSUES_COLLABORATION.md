# GitHub Issues Collaboration Guide

This guide explains how CoderAI and OverseerAI can collaborate using GitHub Issues for communication.

## Overview

GitBrainSwift supports two communication methods:

1. **Shared Worktree Communication** - File-based messaging for real-time collaboration
2. **GitHub Issues Communication** - Persistent, versioned messaging via GitHub Issues

GitHub Issues communication is ideal for:
- Remote AI collaboration across different machines
- Persistent message history and audit trails
- Integration with existing GitHub workflows
- Code review via Pull Requests

## Setup

### Prerequisites

1. **GitHub Repository**: Create a GitHub repository for AI collaboration
2. **GitHub Personal Access Token**: Generate a token with `repo` and `issues` permissions

### Creating a GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` - Full control of private repositories
   - `issues` - Full control of issues
4. Copy the generated token

## Using GitHub Issues Communication

### Basic Setup

```swift
import GitBrainSwift

let communication = GitHubCommunication(
    owner: "your-username",
    repo: "your-repo",
    token: "your-github-token"
)
```

### Initialize CoderAI with GitHub Communication

```swift
let coder = CoderAI(
    system: systemConfig,
    roleConfig: coderRoleConfig,
    communication: communication,  // GitHubCommunication instance
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

try await coder.initialize()
```

### Initialize OverseerAI with GitHub Communication

```swift
let overseer = OverseerAI(
    system: systemConfig,
    roleConfig: overseerRoleConfig,
    communication: communication,  // GitHubCommunication instance
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

try await overseer.initialize()
```

## How It Works

### Message Format

Messages are sent as GitHub Issues with a specific format:

**Title**: `[to-role] message-type: message-id-prefix`

**Body**:
```markdown
**From:** sender
**To:** recipient
**Type:** message-type
**Timestamp:** ISO8601-timestamp
**Priority:** priority-level

```json
{
  "id": "message-id",
  "from_ai": "sender",
  "to_ai": "recipient",
  "message_type": "type",
  "content": { ... },
  "timestamp": "ISO8601-timestamp",
  "priority": 1,
  "metadata": { }
}
```
```

**Labels**:
- `gitbrain` - Identifies GitBrain messages
- `message-type` - Message type (task, code, review, etc.)
- `to-role` - Target role (coder, overseer)

### Sending Messages

```swift
let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    taskDescription: "Implement feature X",
    taskType: "coding",
    priority: 1
)

let issueURL = try await communication.sendMessage(message, from: "overseer", to: "coder")
print("Message sent to: \(issueURL)")
```

### Receiving Messages

```swift
let messages = try await communication.receiveMessages(for: "coder")

for message in messages {
    print("Received: \(message.messageType)")
    print("From: \(message.fromAI)")
    print("Content: \(message.content)")
}
```

### Message Lifecycle

1. **Creation**: Message is created as a GitHub Issue
2. **Delivery**: Recipient polls for issues with `to-role` label
3. **Processing**: Recipient processes the message
4. **Closure**: Issue is automatically closed after processing

## Demo

### Running the GitHub Collaboration Demo

1. Set environment variables:

```bash
export GITHUB_TOKEN=your_github_token_here
export GITHUB_OWNER=your_username
export GITHUB_REPO=your_repository
```

2. Run the demo:

```bash
swift run gitbrain-github-demo
```

### Demo Scenarios

The demo demonstrates the complete collaboration flow:

1. **Task Assignment**: OverseerAI assigns a task to CoderAI via GitHub Issue
2. **Task Processing**: CoderAI receives and processes the task
3. **Code Implementation**: CoderAI implements the task
4. **Code Submission**: CoderAI submits code for review via GitHub Issue
5. **Code Review**: OverseerAI receives and reviews the code
6. **Approval/Rejection**: OverseerAI approves or rejects the code via GitHub Issue
7. **Feedback**: CoderAI receives the approval/rejection

## API Reference

### GitHubCommunication

#### Initialization

```swift
public init(owner: String, repo: String, token: String)
```

#### Methods

**sendMessage**
```swift
public func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
```
Sends a message as a GitHub Issue and returns the issue URL.

**receiveMessages**
```swift
public func receiveMessages(for role: String) async throws -> [Message]
```
Retrieves all messages for a specific role and closes the issues.

**getMessageCount**
```swift
public func getMessageCount(for role: String) async throws -> Int
```
Returns the count of pending messages for a role.

**clearMessages**
```swift
public func clearMessages(for role: String) async throws -> Int
```
Closes all pending messages for a role and returns the count.

## Best Practices

### Label Management

- Use consistent labels for filtering
- Label format: `to-{role}` for recipient identification
- Label format: `message-{type}` for message type filtering

### Issue Management

- Issues are automatically closed after processing
- Closed issues serve as a communication history
- Use GitHub's issue search for querying past messages

### Rate Limiting

GitHub API has rate limits:
- Authenticated requests: 5,000 requests/hour
- Unauthenticated requests: 60 requests/hour

Always use authentication for production use.

### Error Handling

```swift
do {
    let messages = try await communication.receiveMessages(for: "coder")
} catch GitHubError.rateLimitExceeded {
    print("Rate limit exceeded, please wait")
} catch GitHubError.unauthorized {
    print("Invalid GitHub token")
} catch {
    print("Error: \(error)")
}
```

## Comparison: GitHub Issues vs Shared Worktree

| Feature | GitHub Issues | Shared Worktree |
|----------|---------------|-----------------|
| **Latency** | Higher (network) | Lower (local) |
| **Persistence** | Permanent | Temporary |
| **History** | Full audit trail | Manual cleanup |
| **Remote Access** | Yes | No |
| **Integration** | GitHub ecosystem | Local filesystem |
| **Setup** | Requires GitHub account | Local only |
| **Use Case** | Remote collaboration | Local collaboration |

## Troubleshooting

### Common Issues

**"Unauthorized" Error**
- Verify your GitHub token has correct permissions
- Check that the token hasn't expired

**"Rate Limit Exceeded" Error**
- Wait for the rate limit to reset
- Use authentication to increase limits
- Implement exponential backoff

**"Resource Not Found" Error**
- Verify the repository exists
- Check the owner and repository names
- Ensure the token has access to the repository

### Debugging

Enable debug logging by checking the issue URLs returned by `sendMessage`:

```swift
let issueURL = try await communication.sendMessage(message, from: "from", to: "to")
print("Issue created: \(issueURL)")
```

## Security Considerations

1. **Token Storage**: Never commit GitHub tokens to version control
2. **Environment Variables**: Use environment variables for sensitive data
3. **Token Permissions**: Use minimal required permissions
4. **Token Rotation**: Rotate tokens regularly
5. **Private Repositories**: Use private repositories for sensitive projects

## Example: Complete Workflow

```swift
import GitBrainSwift

let communication = GitHubCommunication(
    owner: "my-org",
    repo: "ai-collaboration",
    token: ProcessInfo.processInfo.environment["GITHUB_TOKEN"]!
)

let coder = CoderAI(
    system: systemConfig,
    roleConfig: coderRoleConfig,
    communication: communication,
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

let overseer = OverseerAI(
    system: systemConfig,
    roleConfig: overseerRoleConfig,
    communication: communication,
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

try await coder.initialize()
try await overseer.initialize()

try await overseer.assignTask(
    taskID: "task_001",
    coder: "coder",
    description: "Implement feature X",
    taskType: "coding"
)

let messages = try await coder.receiveMessages()
for message in messages {
    await coder.processMessage(message)
}

let codeSubmission = await coder.implementTask()
try await coder.submitCode(reviewer: "overseer")

let overseerMessages = try await overseer.receiveMessages()
for message in overseerMessages {
    await overseer.processMessage(message)
}

let review = await overseer.reviewCode(taskID: "task_001")
if let approved = review?["approved"] as? Bool, approved {
    try await overseer.approveCode(taskID: "task_001", coder: "coder")
}
```

## Additional Resources

- [GitHub Issues API Documentation](https://docs.github.com/en/rest/issues)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitBrainSwift README](../README.md)
- [Shared Worktree Setup Guide](SHARED_WORKTREE_SETUP.md)
