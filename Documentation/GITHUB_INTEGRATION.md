# GitHub Integration Guide

This guide provides comprehensive instructions for integrating GitBrainSwift with GitHub for AI communication.

## Overview

GitBrainSwift uses GitHub as the primary communication channel between AIs. This integration provides:
- **Persistent communication**: GitHub Issues serve as durable message storage
- **Version control**: All communication is tracked and versioned
- **Collaboration features**: Labels, milestones, and comments enhance communication
- **API access**: Full GitHub API integration for automation

## Prerequisites

1. **GitHub Account**: Create a GitHub account if you don't have one
2. **GitHub Repository**: Create a repository for AI collaboration
3. **Personal Access Token**: Generate a token with appropriate permissions
4. **Git**: Install Git 2.5+ for worktree support

## GitHub Personal Access Token

### Creating a Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token" → "Generate new token (classic)"
3. Configure the token:
   - **Note**: Enter a descriptive name (e.g., "GitBrainSwift")
   - **Expiration**: Choose an expiration period (or "No expiration")
   - **Scopes**: Select the following scopes:
     - `repo` - Full control of private repositories
     - `issues` - Read and write issues
     - `pull_requests` - Read and write pull requests
     - `contents` - Read and write repository contents
4. Click "Generate token"
5. **Important**: Copy the token immediately. You won't be able to see it again.

### Storing the Token Securely

#### Environment Variable (Recommended)

```bash
export GITHUB_TOKEN="ghp_xxx"
```

Add to your shell profile (~/.zshrc, ~/.bashrc, etc.):

```bash
echo 'export GITHUB_TOKEN="ghp_xxx"' >> ~/.zshrc
source ~/.zshrc
```

#### Configuration File

Add to `~/.gitbrain/config.json`:

```json
{
  "github": {
    "token": "ghp_xxx"
  }
}
```

**Security Note**: Never commit your token to version control. Add `config.json` to `.gitignore`.

## Repository Setup

### Creating a New Repository

1. Go to GitHub and create a new repository
2. Choose a descriptive name (e.g., "gitbrain-workspace")
3. Initialize with a README if desired
4. Clone the repository:

```bash
git clone https://github.com/your-username/gitbrain-workspace.git
cd gitbrain-workspace
```

### Configuring the Repository

Initialize GitBrainSwift:

```bash
gitbrain init --owner your-username --repo gitbrain-workspace
```

This creates the necessary configuration and directory structure.

## GitHub Communication Protocol

### Message Structure

GitBrainSwift uses GitHub Issues to send messages between AIs. Each message is an Issue with:

- **Title**: Message type and summary
- **Body**: Message content in JSON format
- **Labels**: Message metadata (sender, recipient, type, priority)
- **Comments**: Follow-up communication

### Message Types

| Type | Description | Example Title |
|------|-------------|---------------|
| `task` | Task assignment | `[TASK] Implement user login` |
| `code` | Code submission | `[CODE] Submit feature implementation` |
| `review` | Code review | `[REVIEW] Review PR #123` |
| `feedback` | Feedback on code | `[FEEDBACK] Comments on PR #123` |
| `approval` | Code approval | `[APPROVAL] PR #123 approved` |
| `rejection` | Code rejection | `[REJECTION] PR #123 rejected` |
| `status` | Status update | `[STATUS] Current progress` |
| `heartbeat` | Heartbeat message | `[HEARTBEAT] System check` |

### Labels

GitBrainSwift uses labels to categorize messages:

| Label | Description | Example |
|-------|-------------|---------|
| `from:coder` | Message from CoderAI | `from:coder` |
| `from:overseer` | Message from OverseerAI | `from:overseer` |
| `to:coder` | Message to CoderAI | `to:coder` |
| `to:overseer` | Message to OverseerAI | `to:overseer` |
| `type:task` | Task message | `type:task` |
| `type:code` | Code message | `type:code` |
| `priority:high` | High priority | `priority:high` |
| `priority:medium` | Medium priority | `priority:medium` |
| `priority:low` | Low priority | `priority:low` |

## Using GitHubCommunication

### Basic Usage

```swift
import GitBrainSwift

let gitHubCommunication = GitHubCommunication(
    owner: "your-username",
    repo: "your-repo",
    token: "your-github-token"
)
```

### Sending a Message

```swift
let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    taskDescription: "Implement user login",
    taskType: "feature",
    priority: 1
)

let issueURL = try await gitHubCommunication.sendMessage(message, from: "overseer", to: "coder")
print("Message sent: \(issueURL)")
```

### Receiving Messages

```swift
let messages = try await gitHubCommunication.receiveMessages(for: "coder")

for message in messages {
    print("Received message from \(message.fromAI)")
    print("Type: \(message.messageType)")
    print("Content: \(message.content)")
}
```

### Getting Message Count

```swift
let count = try await gitHubCommunication.getMessageCount(for: "coder")
print("Unread messages: \(count)")
```

### Clearing Messages

```swift
let cleared = try await gitHubCommunication.clearMessages(for: "coder")
print("Cleared \(cleared) messages")
```

## Pull Request Integration

### Creating a Pull Request

CoderAI submits code via Pull Requests:

```swift
let codeMessage = MessageBuilder.createCodeMessage(
    fromAI: "coder",
    toAI: "overseer",
    taskID: "task_001",
    codeFiles: ["feature.swift", "feature_tests.swift"],
    commitMessage: "Implement user login feature",
    pullRequestTitle: "[FEATURE] User login implementation",
    pullRequestDescription: "Implements user login with OAuth support",
    labels: ["type:code", "priority:high"]
)

let issueURL = try await gitHubCommunication.sendMessage(codeMessage, from: "coder", to: "overseer")
```

### Reviewing a Pull Request

OverseerAI reviews Pull Requests:

```swift
let reviewMessage = MessageBuilder.createReviewMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    pullRequestNumber: 123,
    reviewResult: [
        "approved": true,
        "comments": "Great implementation! Minor suggestions for improvement."
    ]
)

let issueURL = try await gitHubCommunication.sendMessage(reviewMessage, from: "overseer", to: "coder")
```

### Approving a Pull Request

```swift
let approvalMessage = MessageBuilder.createApprovalMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    pullRequestNumber: 123,
    comments: "Approved. Ready to merge."
)

let issueURL = try await gitHubCommunication.sendMessage(approvalMessage, from: "overseer", to: "coder")
```

### Requesting Changes

```swift
let feedbackMessage = MessageBuilder.createFeedbackMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    pullRequestNumber: 123,
    comments: "Please add error handling for network failures",
    severity: "high"
)

let issueURL = try await gitHubCommunication.sendMessage(feedbackMessage, from: "overseer", to: "coder")
```

## GitHub API Integration

### Using GitHub API Directly

```swift
import Foundation

struct GitHubAPI {
    let owner: String
    let repo: String
    let token: String
    
    func createIssue(title: String, body: String, labels: [String]) async throws -> URL {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/issues")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let issueData: [String: Any] = [
            "title": title,
            "body": body,
            "labels": labels
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: issueData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
        
        let issue = try JSONDecoder().decode(GitHubIssue.self, from: data)
        return issue.htmlURL
    }
    
    func getIssues(labels: [String]? = nil, state: String = "open") async throws -> [GitHubIssue] {
        var components = URLComponents(string: "https://api.github.com/repos/\(owner)/\(repo)/issues")!
        components.queryItems = [
            URLQueryItem(name: "state", value: state)
        ]
        
        if let labels = labels {
            components.queryItems?.append(URLQueryItem(name: "labels", value: labels.joined(separator: ",")))
        }
        
        guard let url = components.url else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([GitHubIssue].self, from: data)
    }
    
    func closeIssue(issueNumber: Int) async throws {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/issues/\(issueNumber)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let patchData: [String: Any] = ["state": "closed"]
        request.httpBody = try JSONSerialization.data(withJSONObject: patchData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
    }
}

struct GitHubIssue: Codable {
    let number: Int
    let title: String
    let body: String?
    let htmlURL: URL
    let state: String
    let labels: [GitHubLabel]
    
    enum CodingKeys: String, CodingKey {
        case number, title, body, state, labels
        case htmlURL = "html_url"
    }
}

struct GitHubLabel: Codable {
    let name: String
}

enum GitHubError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}
```

## GitHub Webhooks

### Setting Up Webhooks

Webhooks allow GitHub to notify your application of events in real-time.

1. Go to your repository Settings → Webhooks → Add webhook
2. Configure the webhook:
   - **Payload URL**: Your webhook endpoint URL
   - **Content type**: `application/json`
   - **Secret**: A secret key for verification
   - **Events**: Select events you want to receive (Issues, Pull Requests, etc.)
3. Click "Add webhook"

### Handling Webhook Events

```swift
import Vapor

func handleGitHubWebhook(_ req: Request) async throws -> HTTPStatus {
    let signature = req.headers.first(name: "X-Hub-Signature-256") ?? ""
    let eventType = req.headers.first(name: "X-GitHub-Event") ?? ""
    
    let body = try req.body.collect()
    let data = body.get()
    
    guard verifySignature(data: data, signature: signature, secret: "your-webhook-secret") else {
        throw Abort(.unauthorized)
    }
    
    switch eventType {
    case "issues":
        let issue = try JSONDecoder().decode(GitHubIssueEvent.self, from: data)
        try await handleIssueEvent(issue)
    case "pull_request":
        let pr = try JSONDecoder().decode(GitHubPREvent.self, from: data)
        try await handlePREvent(pr)
    default:
        break
    }
    
    return .ok
}

func verifySignature(data: Data, signature: String, secret: String) -> Bool {
    let hmac = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: secret.data(using: .utf8)!))
    let expectedSignature = "sha256=" + Data(hmac).base64EncodedString()
    return signature == expectedSignature
}

struct GitHubIssueEvent: Codable {
    let action: String
    let issue: GitHubIssue
    let repository: GitHubRepository
}

struct GitHubPREvent: Codable {
    let action: String
    let pullRequest: GitHubPullRequest
    let repository: GitHubRepository
}

struct GitHubRepository: Codable {
    let name: String
    let owner: GitHubOwner
}

struct GitHubOwner: Codable {
    let login: String
}

struct GitHubPullRequest: Codable {
    let number: Int
    let title: String
    let state: String
    let htmlURL: URL
    
    enum CodingKeys: String, CodingKey {
        case number, title, state
        case htmlURL = "html_url"
    }
}
```

## GitHub Actions Integration

### Automated Testing

Create `.github/workflows/test.yml`:

```yaml
name: Run Tests

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Swift
        uses: swift-actions/setup-swift@v1
        with:
          swift-version: 6.2
      
      - name: Run Tests
        run: swift test
```

### Automated Code Review

Create `.github/workflows/review.yml`:

```yaml
name: Code Review

on:
  pull_request:
    types: [opened]

jobs:
  review:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Swift
        uses: swift-actions/setup-swift@v1
        with:
          swift-version: 6.2
      
      - name: Build
        run: swift build
      
      - name: Lint
        run: swiftformat --lint .
      
      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Automated review completed. Build and lint passed!'
            })
```

## Best Practices

### 1. Use Descriptive Issue Titles

```swift
let goodTitle = "[TASK] Implement user authentication with OAuth"
let badTitle = "Task"
```

### 2. Use Labels Consistently

```swift
let labels = [
    "from:coder",
    "to:overseer",
    "type:code",
    "priority:high"
]
```

### 3. Include Structured Content

```swift
let content: [String: Any] = [
    "task_id": "task_001",
    "description": "Implement user login",
    "requirements": [
        "OAuth 2.0 support",
        "Session management",
        "Error handling"
    ],
    "acceptance_criteria": [
        "User can login with GitHub",
        "Session persists across restarts",
        "Errors are handled gracefully"
    ]
]
```

### 4. Close Issues After Processing

```swift
try await gitHubCommunication.closeIssue(issueNumber: 123)
```

### 5. Use Milestones for Tracking

```swift
let labels = [
    "milestone:v1.0",
    "type:task"
]
```

## Troubleshooting

### Authentication Failed

**Error**: `401 Unauthorized`

**Solution**: Check your GitHub token and permissions.

```bash
export GITHUB_TOKEN="ghp_xxx"
gitbrain config get --key github.token
```

### Rate Limit Exceeded

**Error**: `403 Rate limit exceeded`

**Solution**: Wait for the rate limit to reset or use authenticated requests.

```swift
let rateLimitRemaining = response.value(forHTTPHeaderField: "X-RateLimit-Remaining")
print("Remaining requests: \(rateLimitRemaining ?? "unknown")")
```

### Issue Not Found

**Error**: `404 Not Found`

**Solution**: Verify the repository name and owner.

```bash
gitbrain config get --key github.owner
gitbrain config get --key github.repo
```

### Label Not Found

**Error**: `422 Unprocessable Entity`

**Solution**: Create the label first.

```bash
gh label create "from:coder" --color "0066cc"
```

## Security Considerations

1. **Protect Your Token**: Never commit your GitHub token to version control
2. **Use Least Privilege**: Only grant necessary permissions to your token
3. **Rotate Tokens**: Regularly rotate your personal access tokens
4. **Use Webhook Secrets**: Always use secrets for webhook verification
5. **Validate Input**: Always validate and sanitize user input
6. **Use HTTPS**: Always use HTTPS for API calls

## Advanced Features

### Custom Issue Templates

Create `.github/ISSUE_TEMPLATE/task.md`:

```markdown
---
name: Task Assignment
about: Assign a task to an AI role
title: '[TASK] '
labels: 'type:task'
assignees: ''
---

## Task Description

<!-- Describe the task -->

## Requirements

<!-- List requirements -->

## Acceptance Criteria

<!-- List acceptance criteria -->
```

### Custom Labels

Create labels programmatically:

```swift
func createLabel(name: String, color: String, description: String) async throws {
    let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/labels")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    
    let labelData: [String: Any] = [
        "name": name,
        "color": color,
        "description": description
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: labelData)
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 201 else {
        throw GitHubError.requestFailed
    }
}
```

### Milestone Management

```swift
func createMilestone(title: String, description: String) async throws {
    let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/milestones")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    
    let milestoneData: [String: Any] = [
        "title": title,
        "description": description,
        "state": "open"
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: milestoneData)
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 201 else {
        throw GitHubError.requestFailed
    }
}
```

## See Also

- [Shared Worktree Setup Guide](SHARED_WORKTREE_SETUP.md)
- [CoderAI Usage Guide](CODERAI_USAGE.md)
- [CLI Tools Documentation](CLI_TOOLS.md)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [GitHub Webhooks Documentation](https://docs.github.com/en/developers/webhooks-and-events/webhooks)
