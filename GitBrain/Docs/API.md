# GitBrainSwift API Documentation

Welcome to the GitBrainSwift API documentation. This library provides a comprehensive set of tools for AI collaboration, knowledge management, and Git operations.

## Table of Contents

- [MessageCache](#messagecache)
- [AIDaemon](#aidaemon)
- [BrainStateManager](#brainstatemanager)
- [KnowledgeBase](#knowledgebase)
- [MemoryStore](#memorystore)
- [GitManager](#gitmanager)
- [PluginManager](#pluginmanager)
- [Logger](#logger)
- [SendableContent](#sendablecontent)
- [CodableAny](#codableany)

---

## KnowledgeBase

KnowledgeBase provides persistent storage for knowledge items organized by categories and keys.

### Initialization

```swift
// Using Fluent repository with PostgreSQL
let dbManager = DatabaseManager(config: .fromEnvironment())
let repository = try await dbManager.createKnowledgeRepository()
let knowledgeBase = KnowledgeBase(repository: repository)

// Using mock repository for testing
let mockRepo = MockKnowledgeRepository()
let knowledgeBase = KnowledgeBase(repository: mockRepo)
```

**Parameters:**
- `repository: KnowledgeRepositoryProtocol` - The repository implementation for data storage

### Methods

#### addKnowledge(category:key:value:metadata:)

Store a knowledge item in the database.

```swift
try await knowledgeBase.addKnowledge(
    category: "programming",
    key: "swift_basics",
    value: SendableContent(["topic": "Swift", "level": "beginner"])
)
```

**Parameters:**
- `category: String` - The category to store the item in
- `key: String` - The unique key for the item
- `value: SendableContent` - The content to store
- `metadata: SendableContent?` - Optional metadata for the item

**Throws:** `Error` if storage fails

#### getKnowledge(category:key:)

Retrieve a knowledge item from the database.

```swift
let item = try await knowledgeBase.getKnowledge(category: "programming", key: "swift_basics")
```

**Parameters:**
- `category: String` - The category to retrieve from
- `key: String` - The key of the item to retrieve

**Returns:** `SendableContent?` - The stored item, or nil if not found

**Throws:** `Error` if retrieval fails

#### updateKnowledge(category:key:value:metadata:)

Update an existing knowledge item.

```swift
let updated = try await knowledgeBase.updateKnowledge(
    category: "programming",
    key: "swift_basics",
    value: SendableContent(["topic": "Swift", "level": "advanced"])
)
```

**Parameters:**
- `category: String` - The category of the item to update
- `key: String` - The key of the item to update
- `value: SendableContent` - The new content
- `metadata: SendableContent?` - Optional new metadata

**Returns:** `Bool` - True if the item was updated, false if not found

**Throws:** `Error` if update fails

#### deleteKnowledge(category:key:)

Delete a knowledge item from the database.

```swift
let deleted = try await knowledgeBase.deleteKnowledge(category: "programming", key: "swift_basics")
```

**Parameters:**
- `category: String` - The category of the item to delete
- `key: String` - The key of the item to delete

**Returns:** `Bool` - True if the item was deleted, false if not found

**Throws:** `Error` if deletion fails

#### listCategories()

List all categories in the knowledge base.

```swift
let categories = try await knowledgeBase.listCategories()
```

**Returns:** `[String]` - Array of category names

**Throws:** `Error` if listing fails

#### listKeys(category:)

List all keys in a specific category.

```swift
let keys = try await knowledgeBase.listKeys(category: "programming")
```

**Parameters:**
- `category: String` - The category to list keys from

**Returns:** `[String]` - Array of key names

**Throws:** `Error` if listing fails

#### searchKnowledge(category:query:)

Search for knowledge items matching a query.

```swift
let results = try await knowledgeBase.searchKnowledge(category: "programming", query: "swift")
```

**Parameters:**
- `category: String` - The category to search in
- `query: String` - The search query (case-insensitive)

**Returns:** `[SendableContent]` - Array of matching items

**Throws:** `Error` if search fails

---

## MemoryStore

MemoryStore provides in-memory storage with optional expiration for temporary data.

### Initialization

```swift
let memoryStore = MemoryStore()
```

### Methods

#### set(_:value:)

Store a value in memory.

```swift
await memoryStore.set("session_id", value: SendableContent(["id": "12345"]))
```

**Parameters:**
- `key: String` - The key to store the value under
- `value: SendableContent` - The value to store

#### get(_:defaultValue:)

Retrieve a value from memory.

```swift
let value = await memoryStore.get("session_id")
```

**Parameters:**
- `key: String` - The key to retrieve
- `defaultValue: SendableContent?` - Optional default value if key doesn't exist

**Returns:** `SendableContent?` - The stored value, or default value if not found

#### delete(_:)

Delete a value from memory.

```swift
let deleted = await memoryStore.delete("session_id")
```

**Parameters:**
- `key: String` - The key to delete

**Returns:** `Bool` - True if the value was deleted, false if not found

#### exists(_:)

Check if a key exists in memory.

```swift
let exists = await memoryStore.exists("session_id")
```

**Parameters:**
- `key: String` - The key to check

**Returns:** `Bool` - True if the key exists

#### getTimestamp(_:)

Get the timestamp when a value was stored.

```swift
let timestamp = await memoryStore.getTimestamp("session_id")
```

**Parameters:**
- `key: String` - The key to get the timestamp for

**Returns:** `Date?` - The timestamp when the value was stored, or nil if not found

#### clear()

Clear all values from memory.

```swift
await memoryStore.clear()
```

#### listKeys()

List all keys in memory.

```swift
let keys = await memoryStore.listKeys()
```

**Returns:** `[String]` - Array of all keys

#### count()

Get the count of items in memory.

```swift
let count = await memoryStore.count()
```

**Returns:** `Int` - The number of items stored

---

## GitManager

GitManager provides Git operations for repository management.

### Initialization

```swift
let gitManager = GitManager(
    worktree: URL(fileURLWithPath: "/path/to/repo"),
    defaultTimeout: 30,
    maxRetries: 3
)
```

**Parameters:**
- `worktree: URL` - The path to the Git repository
- `defaultTimeout: TimeInterval` - Default timeout for Git operations (default: 30)
- `maxRetries: Int` - Maximum number of retries for transient failures (default: 3)

### Methods

#### add(_:)

Stage files for commit.

```swift
try await gitManager.add(["file1.swift", "file2.swift"])
```

**Parameters:**
- `files: [String]` - Array of file paths to stage

**Throws:** `GitError` if adding fails

#### commit(_:)

Create a commit with a message.

```swift
try await gitManager.commit("feat: Add new feature")
```

**Parameters:**
- `message: String` - The commit message

**Throws:** `GitError` if commit fails

#### push()

Push changes to the remote repository.

```swift
try await gitManager.push()
```

**Throws:** `GitError` if push fails

#### pull()

Pull changes from the remote repository.

```swift
try await gitManager.pull()
```

**Throws:** `GitError` if pull fails

#### sync()

Synchronize with the remote repository (pull then push).

```swift
try await gitManager.sync()
```

**Throws:** `GitError` if sync fails

#### getStatus()

Get the current status of the repository.

```swift
let status = try await gitManager.getStatus()
```

**Returns:** `GitStatus` - The repository status

**Throws:** `GitError` if getting status fails

#### getCurrentBranch()

Get the name of the current branch.

```swift
let branch = try await gitManager.getCurrentBranch()
```

**Returns:** `String` - The current branch name

**Throws:** `GitError` if getting branch fails

#### createBranch(_:)

Create a new branch and switch to it.

```swift
try await gitManager.createBranch("feature/new-feature")
```

**Parameters:**
- `name: String` - The name of the branch to create

**Throws:** `GitError` if creating branch fails

#### checkoutBranch(_:)

Switch to an existing branch.

```swift
try await gitManager.checkoutBranch("main")
```

**Parameters:**
- `name: String` - The name of the branch to switch to

**Throws:** `GitError` if checkout fails

#### mergeBranch(_:)

Merge a branch into the current branch.

```swift
try await gitManager.mergeBranch("feature/new-feature")
```

**Parameters:**
- `name: String` - The name of the branch to merge

**Throws:** `GitError` if merge fails

#### addRemote(name:url:)

Add a remote repository.

```swift
try await gitManager.addRemote(name: "origin", url: "https://github.com/user/repo.git")
```

**Parameters:**
- `name: String` - The name of the remote
- `url: String` - The URL of the remote repository

**Throws:** `GitError` if adding remote fails

#### getRemoteURL()

Get the URL of the origin remote.

```swift
let url = try await gitManager.getRemoteURL()
```

**Returns:** `String` - The URL of the origin remote

**Throws:** `GitError` if getting URL fails

---

## MessageCache

MessageCache provides database-backed messaging for AI collaboration with sub-millisecond latency. This is the **recommended** approach for AI communication.

### Initialization

```swift
let dbManager = DatabaseManager(config: .fromEnvironment())
let messageCache = try await dbManager.createMessageCacheManager(forAI: "Creator")
```

### Message Types

MessageCache supports 6 message types:

1. **TaskMessageModel** - Task assignments between AIs
2. **ReviewMessageModel** - Code review requests and responses
3. **CodeMessageModel** - Code submissions for review
4. **ScoreMessageModel** - Score requests and awards
5. **FeedbackMessageModel** - General feedback between AIs
6. **HeartbeatMessageModel** - Keep-alive signals

### Methods

#### sendTask(to:taskId:description:type:priority:)

Send a task to another AI.

```swift
let task = try await messageCache.sendTask(
    to: "Creator",
    taskId: "task-001",
    description: "Implement feature X",
    type: .coding,
    priority: 1
)
```

#### checkTasks(status:)

Check tasks for the current AI.

```swift
let tasks = try await messageCache.checkTasks(status: .pending)
```

#### sendFeedback(to:feedbackType:subject:content:)

Send feedback to another AI.

```swift
let feedback = try await messageCache.sendFeedback(
    to: "Monitor",
    feedbackType: .acknowledgment,
    subject: "Task Complete",
    content: "Feature X implemented successfully"
)
```

#### sendHeartbeat(to:role:status:currentTask:)

Send a heartbeat to show the AI is alive.

```swift
let heartbeat = try await messageCache.sendHeartbeat(
    to: "Monitor",
    role: .creator,
    status: "working",
    currentTask: "Implementing feature X"
)
```

---

## AIDaemon

AIDaemon provides automatic message polling and heartbeat sending for continuous AI communication.

### Initialization

```swift
let config = DaemonConfig(
    aiName: "Creator",
    role: .creator,
    pollInterval: 1.0,
    heartbeatInterval: 30.0,
    autoHeartbeat: true,
    processMessages: true
)

let daemon = AIDaemon(config: config, databaseManager: dbManager)
```

### Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| aiName | String | required | AI identifier |
| role | RoleType | required | .creator or .monitor |
| pollInterval | Double | 1.0 | Message polling interval in seconds |
| heartbeatInterval | Double | 30.0 | Heartbeat interval in seconds |
| autoHeartbeat | Bool | true | Enable automatic heartbeats |
| processMessages | Bool | true | Enable message processing |

### Event Callbacks

```swift
daemon.onTaskReceived = { task in
    print("Received task: \(task.taskId)")
}

daemon.onFeedbackReceived = { feedback in
    print("Received feedback: \(feedback.subject)")
}

daemon.onHeartbeatReceived = { heartbeat in
    print("Heartbeat from: \(heartbeat.fromAI)")
}
```

### Methods

#### start()

Start the daemon.

```swift
try await daemon.start()
```

#### stop()

Stop the daemon.

```swift
try await daemon.stop()
```

---

## BrainStateManager

BrainStateManager provides persistent AI state storage in the database.

### Initialization

```swift
let dbManager = DatabaseManager(config: .fromEnvironment())
let brainStateManager = try await dbManager.createBrainStateManager()
```

### Methods

#### createBrainState(aiName:role:initialState:)

Create a new brain state for an AI.

```swift
let state = try await brainStateManager.createBrainState(
    aiName: "Creator",
    role: .creator,
    initialState: ["mood": "focused", "task": "implementation"]
)
```

#### loadBrainState(aiName:)

Load brain state for an AI.

```swift
let state = try await brainStateManager.loadBrainState(aiName: "Creator")
```

#### updateBrainState(aiName:key:value:)

Update a specific key in brain state.

```swift
try await brainStateManager.updateBrainState(
    aiName: "Creator",
    key: "currentTask",
    value: "Feature X"
)
```

---

## PluginManager

PluginManager manages loading, execution, and unloading of plugins.

### Initialization

```swift
let pluginManager = PluginManager()
```

### Methods

#### registerPlugin(_:)

Register a plugin with the manager.

```swift
try pluginManager.registerPlugin(myPlugin)
```

**Parameters:**
- `plugin: Plugin` - The plugin to register

**Throws:** `PluginError` if registration fails

#### getPlugin(_:)

Get a registered plugin by name.

```swift
let plugin = pluginManager.getPlugin("MyPlugin")
```

**Parameters:**
- `name: String` - The name of the plugin

**Returns:** `Plugin?` - The plugin, or nil if not found

#### listPlugins()

List all registered plugins.

```swift
let plugins = pluginManager.listPlugins()
```

**Returns:** `[Plugin]` - Array of registered plugins

---

## Logger

Logger provides structured logging with different log levels.

### Methods

#### debug(_:context:metadata:)

Log a debug message.

```swift
GitBrainLogger.debug("Debug information")
```

**Parameters:**
- `message: String` - The message to log
- `context: LogContext?` - Optional context (file, function, line)
- `metadata: LogMetadata?` - Optional metadata

#### info(_:context:metadata:)

Log an info message.

```swift
GitBrainLogger.info("Operation completed successfully")
```

**Parameters:**
- `message: String` - The message to log
- `context: LogContext?` - Optional context (file, function, line)
- `metadata: LogMetadata?` - Optional metadata

#### warning(_:context:metadata:)

Log a warning message.

```swift
GitBrainLogger.warning("Operation took longer than expected")
```

**Parameters:**
- `message: String` - The message to log
- `context: LogContext?` - Optional context (file, function, line)
- `metadata: LogMetadata?` - Optional metadata

#### error(_:context:metadata:)

Log an error message.

```swift
GitBrainLogger.error("Failed to connect to database")
```

**Parameters:**
- `message: String` - The message to log
- `context: LogContext?` - Optional context (file, function, line)
- `metadata: LogMetadata?` - Optional metadata

#### fault(_:context:metadata:)

Log a fault message (critical error).

```swift
GitBrainLogger.fault("System failure detected")
```

**Parameters:**
- `message: String` - The message to log
- `context: LogContext?` - Optional context (file, function, line)
- `metadata: LogMetadata?` - Optional metadata

---

## SendableContent

SendableContent provides a thread-safe dictionary for storing structured data.

### Initialization

```swift
let content = SendableContent(["key": "value", "number": 42])
```

**Parameters:**
- `dictionary: [String: Any]` - The initial dictionary

### Properties

#### data

The underlying data dictionary.

```swift
let data = content.data
```

**Type:** `[String: CodableAny]`

### Methods

#### subscript(_:)

Get or set a value by key.

```swift
let value = content["key"]
content["new_key"] = CodableAny.string("new_value")
```

**Parameters:**
- `key: String` - The key to access

**Returns:** `CodableAny?`

#### toAnyDict()

Convert to a regular dictionary.

```swift
let dict = content.toAnyDict()
```

**Returns:** `[String: Any]`

#### merge(_:)

Merge another SendableContent into this one.

```swift
content.merge(otherContent)
```

**Parameters:**
- `other: SendableContent` - The content to merge

#### keys()

Get all keys.

```swift
let keys = content.keys()
```

**Returns:** `[String]`

#### contains(key:)

Check if a key exists.

```swift
let exists = content.contains(key: "key")
```

**Parameters:**
- `key: String` - The key to check

**Returns:** `Bool`

#### remove(key:)

Remove a key.

```swift
content.remove(key: "key")
```

**Parameters:**
- `key: String` - The key to remove

#### removeAll()

Remove all keys.

```swift
content.removeAll()
```

#### isEmpty

Check if the content is empty.

```swift
let empty = content.isEmpty
```

**Returns:** `Bool`

#### count

Get the number of items.

```swift
let count = content.count
```

**Returns:** `Int`

---

## CodableAny

CodableAny provides a type-safe wrapper for any JSON-serializable value.

### Cases

- `string(String)` - A string value
- `int(Int)` - An integer value
- `double(Double)` - A double value
- `bool(Bool)` - A boolean value
- `array([CodableAny])` - An array of values
- `dictionary([String: CodableAny])` - A dictionary of values
- `null` - A null value

### Properties

#### stringValue

Get the string value if applicable.

```swift
if let str = value.stringValue {
    print(str)
}
```

**Returns:** `String?`

#### intValue

Get the integer value if applicable.

```swift
if let int = value.intValue {
    print(int)
}
```

**Returns:** `Int?`

#### doubleValue

Get the double value if applicable.

```swift
if let double = value.doubleValue {
    print(double)
}
```

**Returns:** `Double?`

#### boolValue

Get the boolean value if applicable.

```swift
if let bool = value.boolValue {
    print(bool)
}
```

**Returns:** `Bool?`

#### arrayValue

Get the array value if applicable.

```swift
if let array = value.arrayValue {
    print(array)
}
```

**Returns:** `[CodableAny]?`

#### dictionaryValue

Get the dictionary value if applicable.

```swift
if let dict = value.dictionaryValue {
    print(dict)
}
```

**Returns:** `[String: CodableAny]?`

#### isNull

Check if the value is null.

```swift
if value.isNull {
    print("Value is null")
}
```

**Returns:** `Bool`

---

## Error Types

### GitError

Errors that can occur during Git operations.

- `commandFailed(arguments:output:exitCode:)` - A Git command failed
- `commandTimeout(arguments:timeout:)` - A Git command timed out
- `notAGitRepository` - The path is not a Git repository
- `branchNotFound(String)` - The specified branch was not found
- `mergeConflict` - A merge conflict occurred

### CommunicationError

Errors that can occur during file-based communication.

- `fileLocked(String)` - A file is locked by another process
- `writeFailed(String:underlyingError:)` - Failed to write to a file
- `readFailed(String:underlyingError:)` - Failed to read from a file
- `invalidMessageFormat(String)` - A message has an invalid format

### PluginError

Errors that can occur during plugin operations.

- `pluginNotFound(String)` - The specified plugin was not found
- `pluginLoadFailed(String:underlyingError:)` - Failed to load a plugin
- `pluginExecutionFailed(String:underlyingError:)` - Failed to execute a plugin

---

## Examples

### Basic KnowledgeBase Usage

```swift
let knowledgeBase = KnowledgeBase(base: URL(fileURLWithPath: "/tmp/knowledge"))

try await knowledgeBase.addKnowledge(
    category: "programming",
    key: "swift",
    value: SendableContent([
        "language": "Swift",
        "version": "5.9",
        "features": ["async/await", "actors", "structs"]
    ])
)

if let swiftInfo = try await knowledgeBase.getKnowledge(category: "programming", key: "swift") {
    print("Swift info: \(swiftInfo.toAnyDict())")
}
```

### Basic GitManager Usage

```swift
let gitManager = GitManager(worktree: URL(fileURLWithPath: "/path/to/repo"))

try await gitManager.add(["file.swift"])
try await gitManager.commit("feat: Add new file")
try await gitManager.push()

let status = try await gitManager.getStatus()
if status.isClean {
    print("Working directory is clean")
}
```

### Basic Logger Usage

```swift
GitBrainLogger.info("Starting operation")
GitBrainLogger.debug("Processing item: \(item)")

do {
    try await someOperation()
} catch {
    GitBrainLogger.error("Operation failed: \(error)")
}
```

---

## Thread Safety

All components in GitBrainSwift are designed with thread safety in mind:

- **KnowledgeBase**: Uses actor isolation for thread-safe access
- **MemoryStore**: Uses actor isolation for thread-safe access
- **GitManager**: Uses actor isolation for thread-safe Git operations
- **MessageCache**: Uses database transactions for concurrent access safety
- **AIDaemon**: Uses async/await for safe concurrent operations

All public APIs are safe to call from any thread or task.

---

## License

This API documentation is part of the GitBrainSwift project.
