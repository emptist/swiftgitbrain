# GitBrainSwift

[![CI](https://github.com/yourusername/gitbrainswift/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/gitbrainswift/actions/workflows/ci.yml)
[![Quality](https://github.com/yourusername/gitbrainswift/actions/workflows/quality.yml/badge.svg)](https://github.com/yourusername/gitbrainswift/actions/workflows/quality.yml)
[![CD](https://github.com/yourusername/gitbrainswift/actions/workflows/deploy.yml/badge.svg)](https://github.com/yourusername/gitbrainswift/actions/workflows/deploy.yml)

A Swift Package Manager (SwiftPM) implementation of GitBrain - a lightweight AI collaboration platform for AI-assisted development.

## Overview

GitBrainSwift enables two AIs to collaborate on software development through:
- **BrainState-based communication**: Real-time messaging via PostgreSQL database with sub-millisecond latency
- **File-based communication**: Legacy file-based messaging (being phased out)
- **Message validation**: Schema-based validation for all message types
- **Plugin system**: Extensible architecture for custom behavior
- **Persistent memory**: Cross-session brainstate management with PostgreSQL database
- **Role separation**: CoderAI (full-featured) and OverseerAI (review-only)
- **Cross-language support**: CLI executable usable in any programming language
- **Development-only**: Can be safely removed after development is complete

## Use Case

GitBrainSwift is a **developer tool package** that enables AI-assisted collaborative development. Users add this package to their developing branch to facilitate AI collaboration in project development.

### Typical Workflow

1. **Setup**: Initialize GitBrain folder structure in your project
2. **CoderAI**: Open Trae at project root - has full access to all folders
3. **OverseerAI**: Open Trae at `GitBrain/` - has read access to whole project, write access to GitBrain folder
4. **Collaboration**: AIs communicate through BrainState-based real-time messaging (sub-millisecond latency)
5. **Cleanup**: Remove GitBrain folder when development is complete

### Critical Note: File-Based Messaging Does Not Work

The legacy file-based messaging system (`FileBasedCommunication`) has **critical performance issues**:
- **5+ minute latency** due to polling (unusable for real-time collaboration)
- **No real-time notifications** (messages delayed by polling intervals)
- **660+ message files** cluttering file system
- **Unreliable** (file I/O issues, no transactional safety)

**Solution**: Use `BrainStateCommunication` for real-time messaging:
- **Sub-millisecond latency** (300,000x improvement)
- **Real-time notifications** via database
- **Database-backed** (transactional safety)
- **Clean architecture** (matches founder's design)

## Installation

### Swift Package Manager

Add GitBrainSwift as a development dependency in your `Package.swift`:

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

### 1. Initialize GitBrain

```bash
gitbrain init
```

This creates the following structure:
```
ProjectA/
├── GitBrain/
│   ├── Overseer/          # OverseerAI working folder
│   ├── Memory/            # Shared persistent memory
│   ├── Docs/              # Documentation for AIs
│   └── README.md          # GitBrain usage guide
├── Sources/               # Your project code
└── Package.swift
```

### 2. Open Trae for CoderAI

```bash
trae .
```

CoderAI has access to all folders in the project.

### 3. Open Trae for OverseerAI

```bash
trae ./GitBrain
```

OverseerAI has read access to whole project and write access to `GitBrain/`.

### 4. Ask AIs to Read Documentation

Ask each AI to read `GitBrain/Docs/` to understand their role and responsibilities.

## CLI Commands

```bash
# Initialize GitBrain folder structure
gitbrain init [path]

# Send a message to another AI
gitbrain send <to> <message> [path]
# to: 'coder' or 'overseer'
# message: JSON string or file path
# path: GitBrain folder path (default: ./GitBrain or $GITBRAIN_PATH)

# Check messages for a role
gitbrain check [role] [path]
# role: 'coder' or 'overseer' (default: coder)
# path: GitBrain folder path (default: ./GitBrain or $GITBRAIN_PATH)

# Clear messages for a role
gitbrain clear [role] [path]
# role: 'coder' or 'overseer' (default: coder)
# path: GitBrain folder path (default: ./GitBrain or $GITBRAIN_PATH)
```

### Environment Variables

```bash
# Set default GitBrain path
export GITBRAIN_PATH=/custom/path/to/GitBrain

# Now all commands use this path
gitbrain check coder
gitbrain send overseer '{"type":"review"}'

# Database configuration (optional, defaults to localhost:5432)
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=postgres
export GITBRAIN_DB_PASSWORD=postgres
```

## Database Setup

GitBrainSwift uses PostgreSQL for persistent storage of AI brainstate and knowledge base. The database is optional - if not configured, the system will use in-memory storage.

### Prerequisites

- PostgreSQL 14+ installed and running
- Database user with appropriate permissions

### Quick Setup

```bash
# Create database
createdb gitbrain

# Create tables (automatic on first run)
# Tables are created automatically when GitBrainSwift initializes
```

### Configuration

Database connection can be configured through environment variables or programmatically:

```swift
import GitBrainSwift

// Using environment variables (recommended)
let dbManager = DatabaseManager(config: .fromEnvironment())

// Using custom configuration
let config = DatabaseConfig(
    host: "localhost",
    port: 5432,
    database: "gitbrain",
    username: "postgres",
    password: "postgres"
)
let dbManager = DatabaseManager(config: config)

// Initialize database
let databases = try await dbManager.initialize()

// Create repositories
let kbRepo = try await dbManager.createKnowledgeRepository()
let bsmRepo = try await dbManager.createBrainStateRepository()
```

### Database Schema

The following tables are automatically created:

#### knowledge_items
- `id`: Primary key
- `category`: Knowledge category
- `key`: Knowledge key
- `value`: JSON-encoded value
- `metadata`: JSON-encoded metadata
- `timestamp`: Creation timestamp

#### brain_states
- `id`: Primary key
- `ai_name`: AI identifier
- `role`: AI role (coder/overseer)
- `state`: JSON-encoded state
- `timestamp`: Last update timestamp

### Testing with Mock Repositories

For testing without a database, use mock repositories:

```swift
import GitBrainSwift

// Use mock repository for testing
let mockRepo = MockKnowledgeRepository()
let knowledgeBase = KnowledgeBase(repository: mockRepo)

// All operations work the same way
try await knowledgeBase.addKnowledge(category: "test", key: "item", value: value)
```

### Data Migration

GitBrainSwift provides a migration tool to transfer data from file-based storage to PostgreSQL:

#### Using the Migration CLI

```bash
# Set up database connection
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=your_username
export GITBRAIN_DB_PASSWORD=your_password

# Migrate knowledge base
swift run gitbrain-migrate migrate knowledge /path/to/GitBrain

# Migrate brain states
swift run gitbrain-migrate migrate brainstate /path/to/GitBrain

# Validate migration
swift run gitbrain-migrate validate
```

#### Programmatic Migration

```swift
import GitBrainSwift

let config = DatabaseConfig.fromEnvironment()
let dbManager = DatabaseManager(config: config)
_ = try await dbManager.initialize()

let migration = DataMigration()
let sourceURL = URL(fileURLWithPath: "/path/to/GitBrain")

// Migrate knowledge base
let kbRepo = try await dbManager.createKnowledgeRepository()
try await migration.migrateKnowledgeBase(from: sourceURL, to: kbRepo)

// Migrate brain states
let bsmRepo = try await dbManager.createBrainStateRepository()
try await migration.migrateBrainStates(from: sourceURL, to: bsmRepo)

// Validate migration
let report = try await migration.validateMigration(
    knowledgeRepo: kbRepo,
    brainStateRepo: bsmRepo
)
print(report.description)

try await dbManager.close()
```

## Message Types and Validation

GitBrainSwift validates all outgoing messages against defined schemas. Supported message types:

### Task Message
```json
{
  "type": "task",
  "task_id": "task-001",
  "description": "Implement new feature",
  "task_type": "coding|review|testing|documentation",
  "priority": 5
}
```

### Code Message
```json
{
  "type": "code",
  "code": "func example() {}",
  "language": "swift",
  "file_path": "Sources/Example.swift",
  "line_number": 10
}
```

### Review Message
```json
{
  "type": "review",
  "task_id": "task-001",
  "approved": true,
  "reviewer": "OverseerAI",
  "comments": [
    {
      "line": 10,
      "type": "error|warning|suggestion|info",
      "message": "Fix this issue"
    }
  ]
}
```

### Feedback Message
```json
{
  "type": "feedback",
  "task_id": "task-001",
  "message": "Code review completed",
  "severity": "info|warning|error",
  "suggestions": ["Add error handling"]
}
```

### Approval Message
```json
{
  "type": "approval",
  "task_id": "task-001",
  "approver": "OverseerAI",
  "approved_at": "2024-01-01T12:00:00Z"
}
```

### Rejection Message
```json
{
  "type": "rejection",
  "task_id": "task-001",
  "rejecter": "OverseerAI",
  "reason": "Code does not meet standards",
  "rejected_at": "2024-01-01T12:00:00Z"
}
```

### Status Message
```json
{
  "type": "status",
  "status": "working|idle|blocked|completed",
  "message": "Currently working on feature X",
  "progress": 45
}
```

### Heartbeat Message
```json
{
  "type": "heartbeat",
  "timestamp": "2024-01-01T12:00:00Z",
  "status": "active"
}
```

## Plugin System

GitBrainSwift includes a plugin system for extending functionality.

### Available Plugins

#### LoggingPlugin
Logs all messages sent and received.

```swift
import GitBrainSwift

let communication = FileBasedCommunication(overseerFolder: overseerURL)
let loggingPlugin = LoggingPlugin(logFileURL: logFileURL)
try await communication.registerPlugin(loggingPlugin)
```

#### MessageTransformPlugin
Adds metadata (timestamps, recipients) to messages.

```swift
let transformPlugin = MessageTransformPlugin()
try await communication.registerPlugin(transformPlugin)
```

### Creating Custom Plugins

```swift
import GitBrainSwift

public struct MyCustomPlugin: GitBrainPlugin, Sendable {
    public let pluginName = "MyCustomPlugin"
    public let pluginVersion = "1.0.0"
    public let pluginDescription = "My custom plugin"
    
    public func onMessageReceived(_ message: SendableContent, from: String) async throws -> SendableContent? {
        // Process incoming message
        return nil // Return modified message or nil
    }
    
    public func onMessageSending(_ message: SendableContent, to: String) async throws -> SendableContent? {
        // Process outgoing message
        return nil // Return modified message or nil
    }
}
```

### Plugin Lifecycle

1. **Registration**: `registerPlugin(_:)` - Add plugin to manager
2. **Initialization**: `onInitialize()` - Called when plugin is initialized
3. **Message Processing**: `onMessageReceived(_:from:)` and `onMessageSending(_:to:)` - Called for each message
4. **Shutdown**: `onShutdown()` - Called when plugin is removed

## Cross-Language Usage

GitBrainSwift CLI can be used in projects written in any programming language.

### Python Example

```python
import json
import subprocess

message = {
    "type": "task",
    "task_id": "py-task-001",
    "description": "Implement Python function",
    "task_type": "coding",
    "priority": 7
}

subprocess.run(["gitbrain", "send", "overseer", json.dumps(message)])
```

### JavaScript Example

```javascript
const { execSync } = require('child_process');

const message = {
    type: "task",
    task_id: "js-task-001",
    description: "Implement JavaScript function",
    task_type: "coding",
    priority: 7
};

execSync(`gitbrain send overseer '${JSON.stringify(message)}'`);
```

### Rust Example

```rust
use std::process::Command;

let message = r#"{
    "type": "task",
    "task_id": "rust-task-001",
    "description": "Implement Rust function",
    "task_type": "coding",
    "priority": 7
}"#;

Command::new("gitbrain")
    .args(&["send", "overseer", message])
    .status()
    .expect("Failed to execute gitbrain");
```

### Go Example

```go
import "os/exec"

message := `{
    "type": "task",
    "task_id": "go-task-001",
    "description": "Implement Go function",
    "task_type": "coding",
    "priority": 7
}`

cmd := exec.Command("gitbrain", "send", "overseer", message)
cmd.Run()
```

For more examples, see [CROSS_LANGUAGE_DEPLOYMENT.md](Documentation/CROSS_LANGUAGE_DEPLOYMENT.md).

## Communication Flow

```
CoderAI (root/) ──writes──> GitBrain/Overseer/
OverseerAI (GitBrain/Overseer/) ──reads──> GitBrain/Overseer/
OverseerAI ──writes──> GitBrain/Memory/
CoderAI ──reads──> GitBrain/Memory/
```

## Architecture

### Roles

#### CoderAI
- **Location**: Project root
- **Access**: Read/write access to all folders
- **Capabilities**: Write code, implement features, fix bugs, write tests, submit for review
- **Communication**: Writes to `GitBrain/Overseer/`, reads from `GitBrain/Memory/`

#### OverseerAI
- **Location**: `GitBrain/Overseer/`
- **Access**: Read access to whole project, write access to `GitBrain/Overseer/`
- **Capabilities**: Review code, provide feedback, approve/reject submissions, manage issues
- **Communication**: Reads from `GitBrain/Overseer/`, writes to `GitBrain/Memory/`

### Components

#### BrainStateCommunication
Real-time messaging system using BrainState infrastructure:
- `sendMessage(_:to:)`: Send message to another AI via BrainState
- `receiveMessages(for:)`: Receive unread messages from BrainState
- `markAsRead(_:for:)`: Mark message as read in BrainState
- **Performance**: Sub-millisecond latency (300,000x improvement over file-based)
- **Architecture**: Database-backed with PostgreSQL
- **Status**: Primary communication system (file-based being phased out)

#### FileBasedCommunication
Legacy file-based messaging system (being phased out):
- `sendMessageToOverseer()`: Send message from CoderAI to OverseerAI
- `sendMessageToCoder()`: Send message from OverseerAI to CoderAI
- `getMessagesForCoder()`: Get messages for CoderAI from Memory folder
- `getMessagesForOverseer()`: Get messages for OverseerAI from Overseer folder
- **Performance**: 5+ minute latency (being replaced)
- **Status**: Legacy system, use BrainStateCommunication instead

#### MessageValidator
Schema-based message validation:
- `validate()`: Validate message content against schema
- Supports all message types with field type checking
- Custom validators for specific fields

#### PluginManager
Plugin lifecycle management:
- `registerPlugin()`: Register a new plugin
- `unregisterPlugin()`: Remove a plugin
- `initializeAll()`: Initialize all plugins
- `shutdownAll()`: Shutdown all plugins
- `processIncomingMessage()`: Process message through all plugins
- `processOutgoingMessage()`: Process message through all plugins

#### BrainStateManager
Manages persistent AI brainstate with repository pattern:
- `createBrainState()`: Create new brainstate for an AI
- `loadBrainState()`: Load existing brainstate
- `updateBrainState()`: Update brainstate with new data
- `getBrainStateValue()`: Get specific value from brainstate
- Uses `BrainStateRepositoryProtocol` for storage (Fluent or Mock)

#### MemoryStore
In-memory storage for quick access:
- `set()`: Store value
- `get()`: Retrieve value
- `delete()`: Delete value
- `exists()`: Check if key exists

#### KnowledgeBase
Knowledge management system with repository pattern:
- `addKnowledge()`: Add knowledge item
- `getKnowledge()`: Retrieve knowledge item
- `searchKnowledge()`: Search knowledge base
- Uses `KnowledgeRepositoryProtocol` for storage (Fluent or Mock)

#### DatabaseManager
PostgreSQL database connection and repository management:
- `initialize()`: Initialize database connection and run migrations
- `createKnowledgeRepository()`: Create knowledge repository
- `createBrainStateRepository()`: Create brain state repository
- `close()`: Close database connection

#### Repositories
Protocol-based storage implementations:
- `KnowledgeRepositoryProtocol`: Interface for knowledge storage
- `BrainStateRepositoryProtocol`: Interface for brain state storage
- `FluentKnowledgeRepository`: PostgreSQL implementation using Fluent ORM
- `FluentBrainStateRepository`: PostgreSQL implementation using Fluent ORM
- `MockKnowledgeRepository`: In-memory implementation for testing
- `MockBrainStateRepository`: In-memory implementation for testing

## Examples

### Send a task message

```bash
gitbrain send overseer '{"type":"task","task_id":"task-001","description":"Implement new feature","task_type":"coding","priority":5}'
```

### Send a review message

```bash
gitbrain send coder '{"type":"review","task_id":"task-001","approved":true,"reviewer":"OverseerAI","comments":[{"line":10,"type":"suggestion","message":"Consider using let instead of var"}]}'
```

### Check messages for CoderAI

```bash
gitbrain check coder
```

### Clear Overseer messages

```bash
gitbrain clear overseer
```

### Using custom GitBrain path

```bash
# Method 1: Command-line argument
gitbrain check coder /custom/path/to/GitBrain

# Method 2: Environment variable
export GITBRAIN_PATH=/custom/path/to/GitBrain
gitbrain check coder
```

## Testing

Run the cross-language integration test:

```bash
./test_cross_language.sh
```

This tests GitBrainSwift with messages from Python, JavaScript, Rust, and Go contexts.

## Cleanup

After development is complete, you can safely remove the GitBrain folder:

```bash
rm -rf GitBrain
```

Or remove the package dependency from your `Package.swift`.

## Platform Support

- macOS 15+ (Primary platform)
- iOS 17+
- tvOS 17+
- watchOS 10+

## Requirements

- Swift 6.2+
- Swift Package Manager
- Trae or similar AI editor
- PostgreSQL 14+ (optional, for persistent storage)

## Design Decisions

For detailed information about design decisions and architectural choices, see [DESIGN_DECISIONS.md](Documentation/DESIGN_DECISIONS.md).

## Development

For information on building, testing, and contributing to GitBrainSwift, see [DEVELOPMENT.md](Documentation/DEVELOPMENT.md).

## License

MIT License

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit a Pull Request.

## Support

For issues and questions, please open an issue on GitHub.
