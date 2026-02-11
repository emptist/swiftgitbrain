# GitBrainSwift

A Swift Package Manager (SwiftPM) implementation of GitBrain - a lightweight AI collaboration platform for AI-assisted development.

## Overview

GitBrainSwift enables two AIs to collaborate on software development through:
- **File-based communication**: Simple read/write operations between AIs
- **Persistent memory**: Cross-session brainstate management
- **Role separation**: CoderAI (full-featured) and OverseerAI (review-only)
- **Development-only**: Can be safely removed after development is complete

## Use Case

GitBrainSwift is a **developer tool package** that enables AI-assisted collaborative development. Users add this package to their developing branch to facilitate AI collaboration in project development.

### Typical Workflow

1. **Setup**: Initialize GitBrain folder structure in your project
2. **CoderAI**: Open Trae at project root - has full access to all folders
3. **OverseerAI**: Open Trae at `GitBrain/Overseer/` - has read access to whole project, write access to Overseer folder
4. **Collaboration**: AIs communicate through file-based messages
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

## Communication Flow

```
CoderAI (root/) ──writes──> GitBrain/Overseer/
OverseerAI (GitBrain/Overseer/) ──reads──> GitBrain/Overseer/
OverseerAI ──writes──> GitBrain/Memory/
CoderAI ──reads──> GitBrain/Memory/
```

## CLI Commands

```bash
# Initialize GitBrain folder structure
gitbrain init [path]

# Send a message to another AI
gitbrain send <to> <message> [path]
# to: 'coder' or 'overseer'
# message: JSON string or file path
# path: GitBrain folder path (default: ./GitBrain)

# Check messages for a role
gitbrain check [role] [path]
# role: 'coder' or 'overseer' (default: coder)

# Clear messages for a role
gitbrain clear [role] [path]
# role: 'coder' or 'overseer' (default: coder)
```

## Examples

### Send a code review request

```bash
gitbrain send overseer '{"type":"code_review","files":["Sources/MyFile.swift"],"description":"Please review this implementation"}'
```

### Check messages for CoderAI

```bash
gitbrain check coder
```

### Clear Overseer messages

```bash
gitbrain clear overseer
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
Simple file-based messaging system:
- `sendMessageToOverseer()`: Send message from CoderAI to OverseerAI
- `sendMessageToCoder()`: Send message from OverseerAI to CoderAI
- `getMessagesForCoder()`: Get messages for CoderAI from Memory folder
- `getMessagesForOverseer()`: Get messages for OverseerAI from Overseer folder

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

## Message Format

Messages are stored as JSON files with timestamps:

```json
{
  "from": "coder",
  "to": "overseer",
  "timestamp": "2024-01-01T12:00:00Z",
  "content": {
    "type": "code_review",
    "files": ["Sources/MyFile.swift"],
    "description": "Please review this implementation"
  }
}
```

## Cross-Session Memory

Brainstate is stored in `GitBrain/Memory/` as JSON files, enabling:
- Persistent memory across sessions
- Knowledge retention between AI interactions
- State restoration after interruptions

## Cleanup

After development is complete, you can safely remove the GitBrain folder:

```bash
rm -rf GitBrain
```

Or remove the package dependency from your `Package.swift`.

## Platform Support

- macOS 14+ (Primary platform)
- iOS 17+
- tvOS 17+
- watchOS 10+

## Requirements

- Swift 6.2+
- Swift Package Manager
- Trae or similar AI editor

## License

MIT License

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit a Pull Request.

## Support

For issues and questions, please open an issue on GitHub.
