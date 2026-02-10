# Shared Worktree Setup Guide

This guide provides comprehensive instructions for setting up and managing shared Git worktrees for AI collaboration in GitBrainSwift.

## Overview

Git worktrees allow multiple AIs to work on the same repository simultaneously in isolated environments. This enables:
- **Parallel development**: Multiple AIs can work on different branches simultaneously
- **Isolated environments**: Each AI has its own working directory
- **Shared repository**: All worktrees share the same Git repository
- **Real-time collaboration**: Changes can be synchronized between worktrees

## Prerequisites

1. **Git 2.5+**: Worktree support was introduced in Git 2.5
2. **Git repository**: An existing Git repository to work with
3. **File system permissions**: Write access to the repository and worktree directories

## Checking Git Version

```bash
git --version
```

Ensure you have Git 2.5 or later:

```bash
git worktree --version
```

## Understanding Git Worktrees

### What is a Worktree?

A Git worktree is a linked working directory associated with a Git repository. Each worktree:
- Has its own working directory
- Shares the same `.git` directory
- Can be on a different branch
- Can be in a different location

### Worktree Architecture

```
repository/
├── .git/                    # Shared Git directory
├── main-worktree/           # Main working directory
│   ├── src/
│   └── README.md
├── coder-worktree/          # CoderAI working directory
│   ├── src/
│   └── README.md
├── overseer-worktree/       # OverseerAI working directory
│   ├── src/
│   └── README.md
└── shared-worktree/         # Shared communication directory
    ├── messages/
    └── status/
```

## Basic Worktree Commands

### List Worktrees

```bash
git worktree list
```

Output:
```
/path/to/repo              abc1234 [main]
/path/to/coder-worktree    def5678 [feature/coder-001]
/path/to/overseer-worktree ghi9012 [feature/overseer-001]
```

### Create a Worktree

```bash
git worktree add <path> <branch>
```

Example:
```bash
git worktree add ./coder-worktree feature/coder-001
```

### Remove a Worktree

```bash
git worktree remove <path>
```

Example:
```bash
git worktree remove ./coder-worktree
```

### Prune Worktrees

Remove worktree directories that no longer exist:

```bash
git worktree prune
```

## Setting Up Shared Worktree for GitBrainSwift

### Step 1: Initialize Repository

If you don't have a repository yet:

```bash
mkdir gitbrain-workspace
cd gitbrain-workspace
git init
echo "# GitBrain Workspace" > README.md
git add README.md
git commit -m "Initial commit"
```

### Step 2: Create Shared Worktree

The shared worktree is used for real-time communication between AIs:

```bash
git worktree add ./shared-worktree shared
```

Create the shared worktree structure:

```bash
cd shared-worktree
mkdir -p messages/coder
mkdir -p messages/overseer
mkdir -p status
cd ..
```

### Step 3: Create AI Worktrees

Create worktrees for each AI role:

```bash
git worktree add ./coder-worktree feature/coder-001
git worktree add ./overseer-worktree feature/overseer-001
```

### Step 4: Configure GitBrainSwift

Initialize GitBrainSwift:

```bash
gitbrain init --owner your-username --repo gitbrain-workspace
```

Configure the shared worktree path:

```bash
gitbrain config set --key paths.sharedWorktree --value ./shared-worktree
```

### Step 5: Verify Setup

List all worktrees:

```bash
gitbrain worktree list
```

Check system status:

```bash
gitbrain status
```

## Using WorktreeManager

### Setup Shared Worktree

```swift
import GitBrainSwift

let worktreeManager = WorktreeManager(repository: URL(fileURLWithPath: "."))

let sharedWorktree = try await WorktreeManager.setupSharedWorktree(
    repository: ".",
    sharedPath: "./shared-worktree"
)

print("Shared worktree created at: \(sharedWorktree.path)")
print("Branch: \(sharedWorktree.branch)")
```

### Create Worktree for AI Role

```swift
let coderWorktree = try await worktreeManager.createWorktree(
    path: "./coder-worktree",
    branch: "feature/coder-001"
)

print("Coder worktree created at: \(coderWorktree.path)")
print("Branch: \(coderWorktree.branch)")
```

### List Worktrees

```swift
let worktrees = try await worktreeManager.listWorktrees()

for worktree in worktrees {
    print("Worktree: \(worktree.path)")
    print("Branch: \(worktree.branch)")
    print("Committed: \(worktree.committed)")
}
```

### Remove Worktree

```swift
try await worktreeManager.removeWorktree("./coder-worktree")
```

## Using SharedWorktreeCommunication

### Initialize Communication

```swift
import GitBrainSwift

let sharedWorktreeURL = URL(fileURLWithPath: "./shared-worktree")
let communication = SharedWorktreeCommunication(sharedWorktree: sharedWorktreeURL)
```

### Send Message

```swift
let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    taskDescription: "Implement feature",
    taskType: "coding",
    priority: 1
)

let messageURL = try await communication.sendMessage(message, from: "overseer", to: "coder")
print("Message saved to: \(messageURL)")
```

### Receive Messages

```swift
let messages = try await communication.receiveMessages(for: "coder")

for message in messages {
    print("From: \(message.fromAI)")
    print("Type: \(message.messageType)")
    print("Content: \(message.content)")
}
```

### Monitor Messages in Real-Time

```swift
let monitor = SharedWorktreeMonitor(sharedWorktree: sharedWorktreeURL)

try await monitor.start()

monitor.registerHandler(for: "coder") { message in
    print("Received message: \(message.messageType)")
    await self.processMessage(message)
}
```

## Worktree Directory Structure

### Shared Worktree Structure

```
shared-worktree/
├── messages/
│   ├── coder/
│   │   ├── 20240115_103000_task_001.json
│   │   ├── 20240115_104000_feedback_001.json
│   │   └── ...
│   ├── overseer/
│   │   ├── 20240115_103030_code_001.json
│   │   ├── 20240115_104030_status_001.json
│   │   └── ...
│   └── ...
├── status/
│   ├── coder.json
│   └── overseer.json
└── .git/                    # Link to main repository
```

### AI Worktree Structure

```
coder-worktree/
├── src/
│   ├── feature.swift
│   └── feature_tests.swift
├── .git/                    # Link to main repository
└── ...
```

## File System Events

The shared worktree uses macOS FSEvents for real-time monitoring:

```swift
import Foundation

class WorktreeMonitor {
    private let sharedWorktree: URL
    private var eventStream: DispatchSourceFileSystemObject?
    
    func startMonitoring() {
        let fileDescriptor = open(sharedWorktree.path, O_EVTONLY)
        
        eventStream = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.main
        )
        
        eventStream?.setEventHandler { [weak self] in
            self?.handleFileSystemEvent()
        }
        
        eventStream?.resume()
    }
    
    func handleFileSystemEvent() {
        print("File system event detected")
    }
    
    func stopMonitoring() {
        eventStream?.cancel()
        eventStream = nil
    }
}
```

## Synchronization Strategies

### Manual Synchronization

```bash
cd coder-worktree
git add .
git commit -m "Implement feature"
git push origin feature/coder-001

cd ../overseer-worktree
git pull origin feature/coder-001
```

### Automated Synchronization

```swift
import GitBrainSwift

let gitManager = GitManager(worktree: URL(fileURLWithPath: "./coder-worktree"))

try await gitManager.add(["."])
try await gitManager.commit("Implement feature")
try await gitManager.push()
```

### Periodic Synchronization

```swift
func syncPeriodically(interval: TimeInterval) async {
    while true {
        try? await gitManager.sync()
        try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
    }
}
```

## Best Practices

### 1. Use Descriptive Branch Names

```bash
git worktree add ./coder-worktree feature/coder-001-user-login
git worktree add ./overseer-worktree feature/overseer-001-code-review
```

### 2. Clean Up Unused Worktrees

```bash
git worktree prune
```

### 3. Use Shared Worktree for Communication Only

Don't modify source files in the shared worktree:

```bash
cd shared-worktree
git status  # Should be clean
```

### 4. Commit Frequently

Commit changes frequently to avoid conflicts:

```bash
cd coder-worktree
git add .
git commit -m "Implement user login"
```

### 5. Pull Before Pushing

Always pull before pushing to avoid conflicts:

```bash
git pull origin feature/coder-001
git push origin feature/coder-001
```

## Troubleshooting

### Worktree Already Exists

**Error**: `fatal: 'path' already exists`

**Solution**: Remove the existing directory or use a different path:

```bash
rm -rf ./coder-worktree
git worktree add ./coder-worktree feature/coder-001
```

### Branch Not Found

**Error**: `fatal: invalid branch: 'feature/coder-001'`

**Solution**: Create the branch first:

```bash
git checkout -b feature/coder-001
git worktree add ./coder-worktree feature/coder-001
```

### Worktree Corrupted

**Error**: `fatal: not a git repository`

**Solution**: Remove the worktree and recreate it:

```bash
git worktree remove ./coder-worktree
git worktree add ./coder-worktree feature/coder-001
```

### Permission Denied

**Error**: `fatal: cannot mkdir: Permission denied`

**Solution**: Check directory permissions:

```bash
ls -la
chmod 755 .
git worktree add ./coder-worktree feature/coder-001
```

### File System Events Not Working

**Error**: Messages not being detected

**Solution**: Check file system permissions and restart monitoring:

```swift
try await monitor.stop()
try await monitor.start()
```

## Advanced Usage

### Multiple Shared Worktrees

```swift
let communication1 = SharedWorktreeCommunication(
    sharedWorktree: URL(fileURLWithPath: "./shared-worktree-1")
)

let communication2 = SharedWorktreeCommunication(
    sharedWorktree: URL(fileURLWithPath: "./shared-worktree-2")
)
```

### Custom Message Storage

```swift
extension SharedWorktreeCommunication {
    func getMessagesPath(for role: String) -> URL {
        return sharedWorktree
            .appendingPathComponent("messages")
            .appendingPathComponent(role)
    }
    
    func getMessageURL(for role: String, id: String) -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(timestamp)_\(id).json"
        return getMessagesPath(for: role).appendingPathComponent(filename)
    }
}
```

### Worktree Templates

Create a template for new worktrees:

```bash
mkdir -p ~/.gitbrain/templates/worktree
cat > ~/.gitbrain/templates/worktree/.gitignore << EOF
.DS_Store
*.swp
*~
EOF
```

Use the template:

```bash
git worktree add --template ~/.gitbrain/templates/worktree ./new-worktree feature/new-branch
```

## Performance Considerations

### 1. Minimize File System Events

Debounce file system events to avoid excessive processing:

```swift
var debounceTimer: Timer?

func handleFileSystemEvent() {
    debounceTimer?.invalidate()
    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        self.processMessages()
    }
}
```

### 2. Use Efficient Message Storage

Store messages in a compressed format:

```swift
let encoder = JSONEncoder()
encoder.outputFormatting = .sortedKeys
let data = try encoder.encode(message)
let compressed = try (data as NSData).compressed(using: .zlib)
```

### 3. Limit Message History

Clean up old messages periodically:

```swift
func cleanupOldMessages(maxAge: TimeInterval) async throws {
    let messages = try await communication.receiveMessages(for: "coder")
    let cutoff = Date().addingTimeInterval(-maxAge)
    
    for message in messages {
        let timestamp = ISO8601DateFormatter().date(from: message.timestamp)
        if let timestamp = timestamp, timestamp < cutoff {
            try? FileManager.default.removeItem(at: message.metadata["file_url"] as! URL)
        }
    }
}
```

## Security Considerations

### 1. File System Permissions

Ensure proper permissions on worktree directories:

```bash
chmod 755 ./shared-worktree
chmod 700 ./shared-worktree/messages
```

### 2. Message Encryption

Encrypt sensitive messages:

```swift
import CryptoKit

func encryptMessage(_ message: Message, key: SymmetricKey) throws -> Data {
    let encoder = JSONEncoder()
    let data = try encoder.encode(message)
    let sealed = try AES.GCM.seal(data, using: key)
    return sealed.combined!
}

func decryptMessage(_ data: Data, key: SymmetricKey) throws -> Message {
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    let decrypted = try AES.GCM.open(sealedBox, using: key)
    return try JSONDecoder().decode(Message.self, from: decrypted)
}
```

### 3. Access Control

Restrict access to worktree directories:

```bash
chown -R gitbrain:gitbrain ./shared-worktree
chmod -R 750 ./shared-worktree
```

## Monitoring and Debugging

### Log Worktree Activity

```swift
func logWorktreeActivity(_ message: String) {
    let logMessage = "[\(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
    
    if let handle = FileHandle(forWritingAtPath: "./shared-worktree/activity.log") {
        handle.seekToEndOfFile()
        handle.write(logMessage.data(using: .utf8)!)
        handle.closeFile()
    }
}
```

### Debug File System Events

```swift
extension SharedWorktreeMonitor {
    func debugFileSystemEvents() {
        eventStream?.setEventHandler { [weak self] in
            let event = self?.eventStream?.data ?? 0
            print("File system event: \(event)")
            self?.handleFileSystemEvent()
        }
    }
}
```

## See Also

- [GitHub Integration Guide](GITHUB_INTEGRATION.md)
- [CoderAI Usage Guide](CODERAI_USAGE.md)
- [CLI Tools Documentation](CLI_TOOLS.md)
- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [macOS FSEvents Documentation](https://developer.apple.com/documentation/corefoundation/1543982-fseventstreamcreate)
