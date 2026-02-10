# GitBrainSwift

A Swift Package Manager (SwiftPM) implementation of GitBrain - a lightweight AI collaboration platform using GitHub Issues and shared Git worktrees for communication.

## Overview

GitBrainSwift enables multiple AIs to work together through:
- **GitHub-based communication**: Async message passing via GitHub Issues and PRs
- **Shared worktree communication**: Real-time file-based messaging between AIs
- **Brainstate memory**: Persistent AI states as versioned JSON files
- **Protocol-Oriented Programming**: Flexible and testable architecture
- **MVVM Architecture**: Clean separation of concerns
- **Swift Concurrency**: Safe async/await operations with Sendable protocol
- **macOS-first**: Optimized for macOS with native APIs and features

## Features

- GitHub Issues for persistent AI communication
- Shared worktree for real-time collaboration
- Persistent brainstate memory with JSON serialization
- Protocol-oriented design for flexibility
- Actor-based concurrency safety
- Comprehensive error handling
- Knowledge base for storing and retrieving information
- In-memory store for quick access
- SwiftUI-ready ViewModels
- Comprehensive unit tests using Swift Testing framework
- CLI tools for system management

## Installation

### Swift Package Manager

Add GitBrainSwift as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/yourusername/gitbrainswift.git",
        from: "1.0.0"
    )
]
```

### Xcode

1. File → Add Package Dependencies
2. Enter package URL: `https://github.com/yourusername/gitbrainswift.git`
3. Select version and add to your project

## Quick Start

### Prerequisites

1. **GitHub Repository**: Create a GitHub repository for AI collaboration
2. **GitHub Personal Access Token**: Generate a token with `repo` and `issues` permissions
3. **Git Worktrees**: Ensure Git worktrees are available (Git 2.5+)

### Initialize GitBrain System

```swift
import GitBrainSwift

let system = SystemConfig(
    name: "My GitBrain Workspace",
    version: "1.0.0",
    maildirBase: "./mailboxes",
    brainstateBase: "./brainstates"
)
```

### Create GitHub Communication System

```swift
let gitHubCommunication = GitHubCommunication(
    owner: "your-username",
    repo: "your-repo",
    token: "your-github-token"
)
```

### Create Shared Worktree Communication

```swift
let sharedWorktreeURL = URL(fileURLWithPath: "./shared-worktree")
let sharedCommunication = SharedWorktreeCommunication(sharedWorktree: sharedWorktreeURL)
```

### Create Memory Manager

```swift
let brainstateURL = URL(fileURLWithPath: "./brainstates")
let memoryManager = BrainStateManager(brainstateBase: brainstateURL)
let memoryStore = MemoryStore()
let knowledgeBase = KnowledgeBase(base: brainstateURL)
```

### Initialize CoderAI

```swift
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

### Initialize OverseerAI

```swift
let overseerRoleConfig = RoleConfig(
    name: "overseer",
    roleType: .overseer,
    enabled: true,
    mailbox: "overseer",
    brainstateFile: "overseer_state.json",
    capabilities: [
        "review_code",
        "approve_code",
        "reject_code",
        "request_changes",
        "provide_feedback",
        "assign_tasks",
        "monitor_progress",
        "enforce_quality_standards"
    ]
)

let overseer = OverseerAI(
    system: system,
    roleConfig: overseerRoleConfig,
    communication: gitHubCommunication,
    memoryManager: memoryManager,
    memoryStore: memoryStore,
    knowledgeBase: knowledgeBase
)

try await overseer.initialize()
```

## Usage Examples

### Sending a Task via GitHub

```swift
let taskMessage = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    taskDescription: "Implement a new feature",
    taskType: "coding",
    priority: 1
)

try await overseer.sendMessage(taskMessage)
```

### Processing GitHub Messages

```swift
let messages = try await coder.receiveMessages()

for message in messages {
    await coder.processMessage(message)
}
```

### Submitting Code via Pull Request

```swift
try await coder.submitCode(reviewer: "overseer")
```

### Reviewing Code

```swift
let reviewResult = await overseer.reviewCode(taskID: "task_001")

if reviewResult?["approved"] as? Bool == true {
    try await overseer.approveCode(taskID: "task_001", coder: "coder")
} else {
    try await overseer.rejectCode(
        taskID: "task_001",
        reason: "Code does not meet standards",
        coder: "coder"
    )
}
```

### Using Memory Store

```swift
await coder.saveMemory(key: "current_task", value: taskData)
let task = await coder.loadMemory(key: "current_task")
```

### Using Knowledge Base

```swift
try await coder.addKnowledge(
    category: "tasks",
    key: "task_001",
    value: [
        "description": "Implement feature",
        "status": "completed"
    ]
)

let knowledge = try await coder.getKnowledge(category: "tasks", key: "task_001")
```

## Architecture

### MVVM Pattern

GitBrainSwift follows the Model-View-ViewModel architecture:

- **Models**: Data structures (Message, BrainState, SystemConfig, etc.)
- **ViewModels**: Business logic and state management (CoderAI, OverseerAI)
- **Views**: SwiftUI views for UI (to be implemented by user)

### Protocol-Oriented Programming

Key protocols for flexibility and testability:

- `CommunicationProtocol`: Defines communication interface
- `BrainStateManagerProtocol`: Defines brainstate management interface
- `MemoryStoreProtocol`: Defines in-memory storage interface
- `KnowledgeBaseProtocol`: Defines knowledge base interface
- `BaseRole`: Defines AI role interface

### Actor-Based Concurrency

All stateful components use Swift actors for thread safety:

- `GitHubCommunication`: Handles GitHub API operations
- `SharedWorktreeCommunication`: Handles shared worktree messaging
- `SharedWorktreeMonitor`: Monitors shared worktree for changes
- `BrainStateManager`: Manages brainstate files
- `MemoryStore`: In-memory storage
- `KnowledgeBase`: Knowledge management
- `CoderAI`: Coder role implementation
- `OverseerAI`: Overseer role implementation

## Core Components

### Models

#### Message

Represents a message between AIs:

```swift
public struct Message: Codable, Identifiable, Sendable {
    public let id: String
    public let fromAI: String
    public let toAI: String
    public let messageType: MessageType
    public let content: [String: Any]
    public let timestamp: String
    public let priority: Int
    public let metadata: [String: String]
}
```

#### BrainState

Represents the persistent memory of an AI:

```swift
public struct BrainState: Codable, Sendable {
    public let aiName: String
    public let role: RoleType
    public var version: String
    public var lastUpdated: String
    public var state: [String: Any]
}
```

#### SystemConfig

Configuration for the GitBrain system:

```swift
public struct SystemConfig: Codable, Sendable {
    public var name: String
    public var version: String
    public var maildirBase: String
    public var brainstateBase: String
    public var checkInterval: Int
    public var configCheckInterval: Int
    public var hotReload: Bool
    public var autoSave: Bool
    public var saveInterval: Int
    public var roles: [String: RoleConfig]
}
```

### Communication

#### GitHubCommunication

Handles GitHub Issues for messaging:

```swift
public actor GitHubCommunication: CommunicationProtocol {
    private let owner: String
    private let repo: String
    private let token: String
    
    public func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
    public func receiveMessages(for role: String) async throws -> [Message]
    public func getMessageCount(for role: String) async throws -> Int
    public func clearMessages(for role: String) async throws -> Int
}
```

#### SharedWorktreeCommunication

Handles shared worktree messaging:

```swift
public actor SharedWorktreeCommunication: CommunicationProtocol {
    private let sharedWorktree: URL
    
    public func sendMessage(_ message: Message, from: String, to: String) async throws -> URL
    public func receiveMessages(for role: String) async throws -> [Message]
    public func getMessageCount(for role: String) async throws -> Int
    public func clearMessages(for role: String) async throws -> Int
}
```

#### SharedWorktreeMonitor

Monitors shared worktree for real-time updates:

```swift
public actor SharedWorktreeMonitor {
    private let sharedWorktree: URL
    
    public init(sharedWorktree: URL) async throws
    public func start() async throws
    public func stop()
    public func registerHandler(for role: String, handler: @escaping (Message) async -> Void)
}
```

#### MessageBuilder

Builder for creating different message types:

```swift
public struct MessageBuilder: Sendable {
    public static func createTaskMessage(...)
    public static func createCodeMessage(...)
    public static func createReviewMessage(...)
    public static func createFeedbackMessage(...)
    public static func createApprovalMessage(...)
    public static func createStatusMessage(...)
    public static func createHeartbeatMessage(...)
}
```

### Git Integration

#### GitManager

Manages Git operations:

```swift
public actor GitManager {
    private let worktree: URL
    
    public init(worktree: URL)
    public func add(_ files: [String]) async throws
    public func commit(_ message: String) async throws
    public func push() async throws
    public func pull() async throws
    public func sync() async throws
    public func getStatus() async throws -> GitStatus
}
```

#### WorktreeManager

Manages Git worktrees:

```swift
public actor WorktreeManager {
    private let repository: URL
    
    public init(repository: URL)
    public static func setupSharedWorktree(repository: String, sharedPath: String) async throws -> Worktree
    public func createWorktree(path: String, branch: String) async throws -> Worktree
    public func listWorktrees() async throws -> [Worktree]
    public func removeWorktree(_ path: String) async throws
}
```

### Memory

#### BrainStateManager

Manages AI brainstate files:

```swift
public actor BrainStateManager: BrainStateManagerProtocol {
    public func createBrainState(...) async throws -> BrainState
    public func loadBrainState(aiName: String) async throws -> BrainState?
    public func saveBrainState(_ brainState: BrainState) async throws
    public func updateBrainState(...) async throws -> Bool
    public func getBrainStateValue(...) async throws -> Any?
    public func deleteBrainState(aiName: String) async throws -> Bool
    public func listBrainStates() async throws -> [String]
    public func backupBrainState(...) async throws -> String?
    public func restoreBrainState(...) async throws -> Bool
}
```

#### MemoryStore

In-memory storage for quick access:

```swift
public actor MemoryStore: MemoryStoreProtocol {
    public func set(_ key: String, value: Any) async
    public func get(_ key: String, defaultValue: Any?) async -> Any?
    public func delete(_ key: String) async -> Bool
    public func exists(_ key: String) async -> Bool
    public func getTimestamp(_ key: String) async -> Date?
    public func clear() async
    public func listKeys() async -> [String]
}
```

#### KnowledgeBase

Knowledge management system:

```swift
public actor KnowledgeBase: KnowledgeBaseProtocol {
    public func addKnowledge(...) async throws
    public func getKnowledge(...) async throws -> [String: Any]?
    public func updateKnowledge(...) async throws -> Bool
    public func deleteKnowledge(...) async throws -> Bool
    public func listCategories() async throws -> [String]
    public func listKeys(category: String) async throws -> [String]
    public func searchKnowledge(...) async throws -> [[String: Any]]
}
```

### Roles

#### BaseRole Protocol

Defines the interface for AI roles:

```swift
public protocol BaseRole: Sendable {
    var system: SystemConfig { get }
    var roleConfig: RoleConfig { get }
    var communication: any CommunicationProtocol { get }
    var memoryManager: any BrainStateManagerProtocol { get }
    var memoryStore: any MemoryStoreProtocol { get }
    var knowledgeBase: any KnowledgeBaseProtocol { get }
    
    func processMessage(_ message: Message) async
    func handleTask(_ task: [String: Any]) async
    func handleFeedback(_ feedback: [String: Any]) async
    func handleApproval(_ approval: [String: Any]) async
    func handleRejection(_ rejection: [String: Any]) async
    func handleHeartbeat(_ heartbeat: [String: Any]) async
    // ... more methods
}
```

#### CoderAI

Implements the coder role:

```swift
public actor CoderAI: BaseRole {
    public func initialize() async throws
    public func processMessage(_ message: Message) async
    public func implementTask() async -> [String: Any]?
    public func submitCode(reviewer: String) async throws -> String
    public func getCapabilities() -> [String]
    public func getStatus() async -> [String: Any]
}
```

#### OverseerAI

Implements the overseer role:

```swift
public actor OverseerAI: BaseRole {
    public func initialize() async throws
    public func processMessage(_ message: Message) async
    public func reviewCode(taskID: String) async -> [String: Any]?
    public func approveCode(...) async throws -> String
    public func rejectCode(...) async throws -> String
    public func requestChanges(...) async throws -> String
    public func assignTask(...) async throws -> String
    public func getCapabilities() -> [String]
    public func getStatus() async -> [String: Any]
}
```

## Message Types

- **task**: Task assignment from OverseerAI to CoderAI
- **code**: Code submission from CoderAI to OverseerAI
- **review**: Code review from OverseerAI
- **feedback**: Feedback from OverseerAI to CoderAI
- **approval**: Approval message
- **rejection**: Rejection message
- **status**: Status update
- **heartbeat**: Heartbeat message

## Communication Flow

```
OverseerAI ──GitHub Issue──> CoderAI ──Pull Request──> OverseerAI
     ↑                                    │
     └─────────GitHub Review──────────────┘
```

## CLI Tools

GitBrainSwift includes CLI tools for system management:

```bash
# Initialize GitBrain system
gitbrain init --owner <username> --repo <repository>

# Create worktree
gitbrain worktree create --path <path> --branch <branch>

# List worktrees
gitbrain worktree list

# Sync with GitHub
gitbrain sync

# Monitor messages
gitbrain monitor --role <role>
```

See [CLI Tools Documentation](Documentation/CLI_TOOLS.md) for more details.

## Testing

GitBrainSwift includes comprehensive unit tests using the Swift Testing framework:

```bash
swift test
```

### Test Coverage

- BrainState model tests
- Message model tests
- MessageBuilder tests
- MemoryStore tests
- BrainStateManager tests
- KnowledgeBase tests
- CoderAI tests
- OverseerAI tests
- SharedWorktreeCommunication tests
- GitManager tests

## Platform Support

- macOS 14+ (Primary platform)
- iOS 17+
- tvOS 17+
- watchOS 10+

## Requirements

- Swift 6.2+
- Swift Package Manager
- Git 2.5+ (for worktree support)
- GitHub account with Personal Access Token

## Documentation

- [GitHub Integration Guide](Documentation/GITHUB_INTEGRATION.md)
- [Shared Worktree Setup Guide](Documentation/SHARED_WORKTREE_SETUP.md)
- [CoderAI Usage Guide](Documentation/CODERAI_USAGE.md)
- [CLI Tools Documentation](Documentation/CLI_TOOLS.md)
- [Implementation Guide](Documentation/IMPLEMENTATION_GUIDE.md)
- [macOS-First Architecture](Documentation/MACOS_FIRST_ARCHITECTURE.md)

## License

MIT License

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit a Pull Request.

## Support

For issues and questions, please open an issue on GitHub.

## Acknowledgments

- Inspired by the Python GitBrain system
- Built with Swift 6.2 and Swift Testing framework
- Uses GitHub Issues for persistent communication
- Uses Git worktrees for multi-AI collaboration
