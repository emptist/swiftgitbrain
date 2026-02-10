# CoderAI Usage Guide

This guide provides comprehensive instructions for using CoderAI, the coding role in GitBrainSwift.

## Overview

CoderAI is responsible for:
- Receiving and implementing tasks assigned by OverseerAI
- Writing, testing, and documenting code
- Submitting code for review
- Applying feedback from OverseerAI
- Managing its own brainstate and knowledge base

## Initialization

### Basic Setup

```swift
import GitBrainSwift

let system = SystemConfig(
    name: "My GitBrain Workspace",
    version: "1.0.0",
    maildirBase: "./mailboxes",
    brainstateBase: "./brainstates"
)

let gitHubCommunication = GitHubCommunication(
    owner: "your-username",
    repo: "your-repo",
    token: "your-github-token"
)

let brainstateURL = URL(fileURLWithPath: "./brainstates")
let memoryManager = BrainStateManager(brainstateBase: brainstateURL)
let memoryStore = MemoryStore()
let knowledgeBase = KnowledgeBase(base: brainstateURL)

let coderRoleConfig = RoleConfig(
    name: "coder",
    roleType: .coder,
    enabled: true,
    mailbox: "coder",
    brainstateFile: "coder_state.json",
    capabilities: [
        "write_code",
        "implement_features",
        "fix_bugs",
        "refactor_code",
        "write_tests",
        "document_code",
        "apply_feedback",
        "submit_for_review"
    ]
)

let coder = CoderAI(
    system: system,
    roleConfig: coderRoleConfig,
    communication: gitHubCommunication,
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

try await coder.initialize()
```

## Capabilities

CoderAI supports the following capabilities:

| Capability | Description |
|------------|-------------|
| `write_code` | Write new code implementations |
| `implement_features` | Implement new features based on requirements |
| `fix_bugs` | Identify and fix bugs in existing code |
| `refactor_code` | Refactor code for better quality and maintainability |
| `write_tests` | Write unit tests for code |
| `document_code` | Document code with comments and documentation |
| `apply_feedback` | Apply feedback from OverseerAI |
| `submit_for_review` | Submit code for review to OverseerAI |

## Message Handling

CoderAI processes different types of messages:

### Task Messages

Received from OverseerAI when a new task is assigned.

```swift
func handleTask(_ task: [String: Any]) async {
    let taskID = task["task_id"] as? String ?? ""
    let description = task["description"] as? String ?? ""
    let taskType = task["type"] as? String ?? ""
    
    await coder.saveMemory(key: "current_task", value: task)
    
    let result = await coder.implementTask()
    
    if let result = result {
        await coder.saveMemory(key: "task_result", value: result)
    }
}
```

### Feedback Messages

Received from OverseerAI after code review.

```swift
func handleFeedback(_ feedback: [String: Any]) async {
    let taskID = feedback["task_id"] as? String ?? ""
    let comments = feedback["comments"] as? String ?? ""
    let severity = feedback["severity"] as? String ?? "info"
    
    await coder.applyFeedback(feedback)
    
    try await coder.submitCode(reviewer: "overseer")
}
```

### Approval Messages

Received when code is approved by OverseerAI.

```swift
func handleApproval(_ approval: [String: Any]) async {
    let taskID = approval["task_id"] as? String ?? ""
    
    await coder.saveMemory(key: "last_approved_task", value: taskID)
    
    try await coder.addKnowledge(
        category: "completed_tasks",
        key: taskID,
        value: [
            "status": "approved",
            "completed_at": ISO8601DateFormatter().string(from: Date())
        ]
    )
}
```

### Rejection Messages

Received when code is rejected by OverseerAI.

```swift
func handleRejection(_ rejection: [String: Any]) async {
    let taskID = rejection["task_id"] as? String ?? ""
    let reason = rejection["reason"] as? String ?? ""
    
    await coder.saveMemory(key: "last_rejected_task", value: rejection)
    
    await coder.implementTask()
}
```

### Heartbeat Messages

Periodic status checks from OverseerAI.

```swift
func handleHeartbeat(_ heartbeat: [String: Any]) async {
    let status = await coder.getStatus()
    
    let statusMessage = MessageBuilder.createStatusMessage(
        fromAI: "coder",
        toAI: "overseer",
        status: status
    )
    
    try await coder.sendMessage(statusMessage)
}
```

## Task Implementation

### Implementing a Task

```swift
let result = await coder.implementTask()
```

The `implementTask()` method:
1. Loads the current task from memory
2. Analyzes the task requirements
3. Implements the solution
4. Writes tests
5. Documents the code
6. Returns the result

### Custom Task Implementation

You can customize the implementation logic:

```swift
extension CoderAI {
    func implementCustomTask(_ task: [String: Any]) async -> [String: Any]? {
        let taskType = task["type"] as? String ?? ""
        
        switch taskType {
        case "feature":
            return await implementFeature(task)
        case "bugfix":
            return await fixBug(task)
        case "refactor":
            return await refactorCode(task)
        default:
            return nil
        }
    }
    
    func implementFeature(_ task: [String: Any]) async -> [String: Any]? {
        let description = task["description"] as? String ?? ""
        
        await coder.saveMemory(key: "implementation_status", value: "in_progress")
        
        let result = [
            "status": "completed",
            "files_modified": ["feature.swift"],
            "tests_added": ["feature_tests.swift"],
            "documentation": ["feature.md"]
        ]
        
        await coder.saveMemory(key: "implementation_status", value: "completed")
        
        return result
    }
}
```

## Code Submission

### Submitting Code for Review

```swift
try await coder.submitCode(reviewer: "overseer")
```

The `submitCode()` method:
1. Stages all changes
2. Creates a commit with a descriptive message
3. Creates a pull request
4. Sends a code message to OverseerAI

### Custom Code Submission

You can customize the submission process:

```swift
extension CoderAI {
    func submitCodeWithDetails(
        reviewer: String,
        title: String,
        description: String,
        labels: [String]
    ) async throws -> String {
        let taskID = await coder.loadMemory(key: "current_task") as? [String: Any]
        let taskIDString = taskID?["task_id"] as? String ?? ""
        
        let codeMessage = MessageBuilder.createCodeMessage(
            fromAI: "coder",
            toAI: reviewer,
            taskID: taskIDString,
            codeFiles: ["file1.swift", "file2.swift"],
            commitMessage: title,
            pullRequestTitle: title,
            pullRequestDescription: description,
            labels: labels
        )
        
        let messageURL = try await coder.sendMessage(codeMessage)
        
        return messageURL.absoluteString
    }
}
```

## Memory Management

### Saving Memory

```swift
await coder.saveMemory(key: "current_task", value: taskData)
await coder.saveMemory(key: "implementation_status", value: "in_progress")
await coder.saveMemory(key: "last_error", value: error)
```

### Loading Memory

```swift
let currentTask = await coder.loadMemory(key: "current_task")
let status = await coder.loadMemory(key: "implementation_status")
let lastError = await coder.loadMemory(key: "last_error")
```

### Deleting Memory

```swift
await coder.deleteMemory(key: "last_error")
```

### Listing Memory Keys

```swift
let keys = await coder.listMemoryKeys()
```

## Knowledge Base

### Adding Knowledge

```swift
try await coder.addKnowledge(
    category: "patterns",
    key: "mvvm",
    value: [
        "description": "Model-View-ViewModel pattern",
        "usage": "Separation of concerns in UI applications",
        "examples": ["SwiftUI", "UIKit"]
    ]
)
```

### Getting Knowledge

```swift
let mvvmKnowledge = try await coder.getKnowledge(category: "patterns", key: "mvvm")
```

### Updating Knowledge

```swift
try await coder.updateKnowledge(
    category: "patterns",
    key: "mvvm",
    value: [
        "description": "Model-View-ViewModel pattern",
        "usage": "Separation of concerns in UI applications",
        "examples": ["SwiftUI", "UIKit", "Jetpack Compose"]
    ]
)
```

### Deleting Knowledge

```swift
try await coder.deleteKnowledge(category: "patterns", key: "mvvm")
```

### Searching Knowledge

```swift
let results = try await coder.searchKnowledge(
    category: "patterns",
    query: "UI"
)
```

### Listing Categories

```swift
let categories = try await coder.listKnowledgeCategories()
```

### Listing Keys in Category

```swift
let keys = try await coder.listKnowledgeKeys(category: "patterns")
```

## Status Monitoring

### Getting Status

```swift
let status = await coder.getStatus()
```

The status includes:
- `name`: The AI name
- `role`: The role type
- `enabled`: Whether the AI is enabled
- `current_task`: The current task being worked on
- `implementation_status`: The status of the current implementation
- `last_activity`: The timestamp of the last activity
- `memory_count`: The number of items in memory
- `knowledge_categories`: The number of knowledge categories

### Getting Capabilities

```swift
let capabilities = coder.getCapabilities()
```

## Error Handling

### Handling Errors Gracefully

```swift
do {
    try await coder.submitCode(reviewer: "overseer")
} catch GitBrainError.communicationError(let message) {
    print("Communication error: \(message)")
    await coder.saveMemory(key: "last_error", value: message)
} catch GitBrainError.gitError(let message) {
    print("Git error: \(message)")
    await coder.saveMemory(key: "last_error", value: message)
} catch {
    print("Unexpected error: \(error)")
    await coder.saveMemory(key: "last_error", value: error.localizedDescription)
}
```

### Custom Error Handling

```swift
extension CoderAI {
    func safeSubmitCode(reviewer: String) async -> Bool {
        do {
            try await coder.submitCode(reviewer: reviewer)
            return true
        } catch {
            await coder.saveMemory(key: "last_error", value: error.localizedDescription)
            return false
        }
    }
}
```

## Best Practices

### 1. Always Save State

Save important state to memory after significant operations:

```swift
let result = await coder.implementTask()
if let result = result {
    await coder.saveMemory(key: "task_result", value: result)
}
```

### 2. Handle All Message Types

Implement handlers for all message types:

```swift
func processMessage(_ message: Message) async {
    switch message.messageType {
    case .task:
        await coder.handleTask(message.content)
    case .feedback:
        await coder.handleFeedback(message.content)
    case .approval:
        await coder.handleApproval(message.content)
    case .rejection:
        await coder.handleRejection(message.content)
    case .heartbeat:
        await coder.handleHeartbeat(message.content)
    default:
        break
    }
}
```

### 3. Use Knowledge Base

Store reusable patterns and solutions in the knowledge base:

```swift
try await coder.addKnowledge(
    category: "solutions",
    key: "common_bug_fix",
    value: [
        "description": "Common bug fix pattern",
        "solution": "Check for nil values before unwrapping",
        "code": "if let value = optional { ... }"
    ]
)
```

### 4. Document Your Code

Always document your code changes:

```swift
try await coder.addKnowledge(
    category: "documentation",
    key: "feature_x",
    value: [
        "description": "Feature X implementation",
        "files_modified": ["feature_x.swift"],
        "changes": "Added new feature X with error handling",
        "tests": "Added unit tests for feature X"
    ]
)
```

### 5. Test Your Code

Write comprehensive tests for your implementations:

```swift
try await coder.addKnowledge(
    category: "tests",
    key: "feature_x_tests",
    value: [
        "test_file": "feature_x_tests.swift",
        "test_count": 10,
        "coverage": "95%"
    ]
)
```

## Advanced Usage

### Custom Message Processing

```swift
extension CoderAI {
    func processCustomMessage(_ message: Message) async {
        await coder.saveMemory(key: "last_message", value: message)
        
        if message.priority > 5 {
            await coder.handleHighPriorityMessage(message)
        } else {
            await coder.handleNormalPriorityMessage(message)
        }
    }
    
    func handleHighPriorityMessage(_ message: Message) async {
        await coder.saveMemory(key: "urgent_task", value: message.content)
    }
    
    func handleNormalPriorityMessage(_ message: Message) async {
        await coder.saveMemory(key: "normal_task", value: message.content)
    }
}
```

### Batch Processing

```swift
extension CoderAI {
    func processBatchTasks(_ tasks: [[String: Any]]) async -> [[String: Any]] {
        var results: [[String: Any]] = []
        
        for task in tasks {
            await coder.saveMemory(key: "current_task", value: task)
            let result = await coder.implementTask()
            
            if let result = result {
                results.append(result)
            }
        }
        
        return results
    }
}
```

### Automated Workflow

```swift
extension CoderAI {
    func automatedWorkflow() async throws {
        while true {
            let messages = try await coder.receiveMessages()
            
            for message in messages {
                await coder.processMessage(message)
                
                if message.messageType == .task {
                    let result = await coder.implementTask()
                    
                    if let result = result {
                        try await coder.submitCode(reviewer: "overseer")
                    }
                }
            }
            
            try await Task.sleep(nanoseconds: 5_000_000_000)
        }
    }
}
```

## Troubleshooting

### Common Issues

#### Issue: Messages Not Received

**Solution**: Check GitHub communication setup and token permissions.

```swift
let messages = try await coder.receiveMessages()
print("Received \(messages.count) messages")
```

#### Issue: Code Submission Fails

**Solution**: Check Git status and ensure all changes are committed.

```swift
let gitManager = GitManager(worktree: URL(fileURLWithPath: "./"))
let status = try await gitManager.getStatus()
print("Git status: \(status)")
```

#### Issue: Memory Not Persisting

**Solution**: Check brainstate directory permissions and path.

```swift
let brainstate = try await coder.loadBrainState(aiName: "coder")
print("Brainstate: \(brainstate)")
```

## Examples

### Example 1: Simple Task Implementation

```swift
let task = [
    "task_id": "task_001",
    "description": "Implement user login",
    "type": "feature",
    "priority": 1
]

await coder.saveMemory(key: "current_task", value: task)
let result = await coder.implementTask()

if let result = result {
    try await coder.submitCode(reviewer: "overseer")
}
```

### Example 2: Bug Fix with Feedback

```swift
let feedback = [
    "task_id": "task_001",
    "comments": "Add error handling for network failures",
    "severity": "high"
]

await coder.handleFeedback(feedback)
try await coder.submitCode(reviewer: "overseer")
```

### Example 3: Knowledge Base Usage

```swift
try await coder.addKnowledge(
    category: "api",
    key: "github",
    value: [
        "base_url": "https://api.github.com",
        "auth_header": "Authorization",
        "rate_limit": 5000
    ]
)

let githubAPI = try await coder.getKnowledge(category: "api", key: "github")
print("GitHub API config: \(githubAPI)")
```

## Conclusion

CoderAI is a powerful tool for automating coding tasks within the GitBrainSwift system. By following this guide and implementing best practices, you can create efficient and reliable AI-powered coding workflows.

For more information, see:
- [GitHub Integration Guide](GITHUB_INTEGRATION.md)
- [Shared Worktree Setup Guide](SHARED_WORKTREE_SETUP.md)
- [CLI Tools Documentation](CLI_TOOLS.md)
