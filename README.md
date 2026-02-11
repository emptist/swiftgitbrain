# GitBrainSwift

A Swift Package Manager (SwiftPM) implementation of GitBrain - a lightweight AI collaboration platform for AI-assisted development.

## Overview

GitBrainSwift enables two AIs to collaborate on software development through:
- **File-based communication**: Simple read/write operations between AIs
- **Message validation**: Schema-based validation for all message types
- **Plugin system**: Extensible architecture for custom behavior
- **Persistent memory**: Cross-session brainstate management
- **Role separation**: CoderAI (full-featured) and OverseerAI (review-only)
- **Cross-language support**: CLI executable usable in any programming language
- **Development-only**: Can be safely removed after development is complete

## Use Case

GitBrainSwift is a **developer tool package** that enables AI-assisted collaborative development. Users add this package to their developing branch to facilitate AI collaboration in project development.

### Typical Workflow

1. **Setup**: Initialize GitBrain folder structure in your project
2. **CoderAI**: Open Trae at project root - has full access to all folders
3. **OverseerAI**: Open Trae at `GitBrain/Overseer/` - has read access to whole project, write access to Overseer folder
4. **Collaboration**: AIs communicate through validated file-based messages
5. **Cleanup**: Remove GitBrain folder when development is complete

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
trae ./GitBrain/Overseer
```

OverseerAI has read access to the whole project and write access to `GitBrain/Overseer/`.

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

#### FileBasedCommunication
Simple file-based messaging system with plugin support:
- `sendMessageToOverseer()`: Send message from CoderAI to OverseerAI
- `sendMessageToCoder()`: Send message from OverseerAI to CoderAI
- `getMessagesForCoder()`: Get messages for CoderAI from Memory folder
- `getMessagesForOverseer()`: Get messages for OverseerAI from Overseer folder
- `registerPlugin()`: Register a plugin for message processing
- `initializePlugins()`: Initialize all registered plugins
- `shutdownPlugins()`: Shutdown all registered plugins

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
Manages persistent AI brainstate:
- `createBrainState()`: Create new brainstate for an AI
- `loadBrainState()`: Load existing brainstate
- `updateBrainState()`: Update brainstate with new data
- `getBrainStateValue()`: Get specific value from brainstate

#### MemoryStore
In-memory storage for quick access:
- `set()`: Store value
- `get()`: Retrieve value
- `delete()`: Delete value
- `exists()`: Check if key exists

#### KnowledgeBase
Knowledge management system:
- `addKnowledge()`: Add knowledge item
- `getKnowledge()`: Retrieve knowledge item
- `searchKnowledge()`: Search knowledge base

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
