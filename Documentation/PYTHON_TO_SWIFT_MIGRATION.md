# Python to Swift Migration Plan

**Status**: 📝 Planning Phase  
**Created**: 2026-02-10  
**Participants**: OverseerAI, CoderAI  
**Target Repository**: swiftgitbrain

## 🎯 Objective

**Abandon Python and migrate to Swift-only implementation starting from swiftgitbrain.**

## 📋 Current State Analysis

### Python Components to Replace

#### 1. **Maildir Communication System**

**Current Implementation**:
- Location: `/Users/jk/gits/hub/gitbrains/GitBrain/core/communication.py`
- Function: Handles Maildir-based communication between AIs
- Dependencies: Python email module, file system operations

**Swift Replacement Needed**:
- Swift Maildir communication module
- Swift Foundation FileManager
- Swift Codable for message serialization
- Swift concurrency (async/await) for message processing

**Key Features to Preserve**:
- Message sending and receiving
- Maildir directory structure (new, cur, tmp)
- Message parsing and serialization
- Error handling and retries

---

#### 2. **BrainState Memory Management**

**Current Implementation**:
- Location: `/Users/jk/gits/hub/gitbrains/GitBrain/core/memory.py`
- Function: Manages persistent AI state storage
- Dependencies: Python JSON, file system operations

**Swift Replacement Needed**:
- Swift BrainState management module
- Swift Codable for state serialization
- Swift Foundation FileManager
- Swift actors for thread-safe access

**Key Features to Preserve**:
- State persistence
- State loading and saving
- State versioning
- Error handling and recovery

---

#### 3. **Daemon System**

**Current Implementation**:
- Location: `/Users/jk/gits/hub/gitbrains/GitBrain/core/daemon.py`
- Function: Runs AI daemon for continuous message processing
- Dependencies: Python multiprocessing, signal handling

**Swift Replacement Needed**:
- Swift daemon using Swift Concurrency
- Swift Task and AsyncStream
- Swift signal handling (if needed)
- Swift background task management

**Key Features to Preserve**:
- Continuous message processing
- Graceful shutdown
- Error recovery
- Logging and monitoring

---

#### 4. **Role-Based AI System**

**Current Implementation**:
- Location: `/Users/jk/gits/hub/gitbrains/GitBrain/roles/`
- Function: Implements CoderAI and OverseerAI roles
- Dependencies: Python classes, inheritance

**Swift Replacement Needed**:
- Swift protocol-based role system
- Swift actors for role isolation
- Swift async/await for role operations
- Swift Combine for reactive programming

**Key Features to Preserve**:
- Role-specific behavior
- Role communication
- Role state management
- Role coordination

---

#### 5. **Utility Scripts**

**Current Implementation**:
- Location: `/Users/jk/gits/hub/gitbrains/GitBrain/roles/overseer/*.py`
- Function: Various utility scripts for email sending, message checking, etc.
- Dependencies: Python email module, subprocess

**Swift Replacement Needed**:
- Swift command-line tools
- Swift ArgumentParser
- Swift Foundation for file operations
- Swift async/await for async operations

**Key Features to Preserve**:
- Email sending
- Message checking
- Daemon management
- Git operations

---

## 🏗️ Swift Architecture Design

### 1. **Swift Package Structure**

```
swiftgitbrain/
├── Package.swift
├── Sources/
│   ├── GitBrainSwift/
│   │   ├── Models/
│   │   │   ├── Message.swift
│   │   │   ├── MessageType.swift
│   │   │   ├── RoleType.swift
│   │   │   ├── BrainState.swift
│   │   │   └── Task.swift
│   │   ├── Communication/
│   │   │   ├── MaildirCommunication.swift
│   │   │   ├── MessageParser.swift
│   │   │   └── MessageSerializer.swift
│   │   ├── Memory/
│   │   │   ├── BrainStateManager.swift
│   │   │   ├── StatePersistence.swift
│   │   │   └── StateRecovery.swift
│   │   ├── Daemon/
│   │   │   ├── GitBrainDaemon.swift
│   │   │   ├── DaemonController.swift
│   │   │   └── DaemonConfig.swift
│   │   ├── Roles/
│   │   │   ├── BaseRole.swift
│   │   │   ├── CoderAI.swift
│   │   │   ├── OverseerAI.swift
│   │   │   └── RoleProtocol.swift
│   │   ├── Utils/
│   │   │   ├── EmailSender.swift
│   │   │   ├── MessageChecker.swift
│   │   │   ├── GitOperations.swift
│   │   │   └── Logger.swift
│   │   └── CLI/
│   │       ├── Main.swift
│   │       ├── DaemonCommand.swift
│   │       ├── SendCommand.swift
│   │       └── CheckCommand.swift
│   └── GitBrainSwiftCLI/
│       └── main.swift
├── Tests/
│   ├── GitBrainSwiftTests/
│   │   ├── CommunicationTests/
│   │   ├── MemoryTests/
│   │   ├── DaemonTests/
│   │   └── RoleTests/
│   └── GitBrainSwiftCLITests/
├── Documentation/
├── Scripts/
└── README.md
```

---

### 2. **Swift Maildir Communication**

```swift
import Foundation

public actor MaildirCommunication {
    public let maildirBase: URL
    public let role: String
    
    private let fileManager = FileManager.default
    private let messageQueue = AsyncStream<Message>.makeStream()
    
    public init(maildirBase: URL, role: String) throws {
        self.maildirBase = maildirBase
        self.role = role
        try createMaildirStructure()
    }
    
    private func createMaildirStructure() throws {
        let maildirPath = maildirBase.appendingPathComponent(role)
        let newDir = maildirPath.appendingPathComponent("new")
        let curDir = maildirPath.appendingPathComponent("cur")
        let tmpDir = maildirPath.appendingPathComponent("tmp")
        
        try fileManager.createDirectory(at: newDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: curDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        let recipientMaildir = maildirBase.appendingPathComponent(recipient)
        let newDir = recipientMaildir.appendingPathComponent("new")
        
        let filename = "\(Int(Date().timeIntervalSince1970)).\(UUID().uuidString).eml"
        let filepath = newDir.appendingPathComponent(filename)
        
        let messageData = try MessageSerializer.serialize(message)
        try messageData.write(to: filepath)
    }
    
    public func receiveMessages() async throws -> [Message] {
        let maildirPath = maildirBase.appendingPathComponent(role)
        let newDir = maildirPath.appendingPathComponent("new")
        let curDir = maildirPath.appendingPathComponent("cur")
        
        guard let files = try? fileManager.contentsOfDirectory(at: newDir, includingPropertiesForKeys: nil) else {
            return []
        }
        
        var messages: [Message] = []
        
        for file in files {
            do {
                let messageData = try Data(contentsOf: file)
                let message = try MessageParser.parse(data: messageData)
                messages.append(message)
                
                // Move to cur directory
                let curFilepath = curDir.appendingPathComponent(file.lastPathComponent)
                try fileManager.moveItem(at: file, to: curFilepath)
            } catch {
                Logger.error("Failed to parse message: \(error)")
            }
        }
        
        return messages
    }
    
    public func startMonitoring() async {
        for await _ in Timer.publish(every: 5.0, on: .main, in: .common).autoconnect().values {
            do {
                let messages = try await receiveMessages()
                for message in messages {
                    messageQueue.continuation.yield(message)
                }
            } catch {
                Logger.error("Failed to receive messages: \(error)")
            }
        }
    }
    
    public var messageStream: AsyncStream<Message> {
        messageQueue.stream
    }
}
```

---

### 3. **Swift BrainState Management**

```swift
import Foundation

public actor BrainStateManager {
    public let brainstateBase: URL
    public let role: String
    
    private let fileManager = FileManager.default
    private var currentState: BrainState?
    
    public init(brainstateBase: URL, role: String) throws {
        self.brainstateBase = brainstateBase
        self.role = role
        try createBrainstateDirectory()
    }
    
    private func createBrainstateDirectory() throws {
        let brainstatePath = brainstateBase.appendingPathComponent(role)
        try fileManager.createDirectory(at: brainstatePath, withIntermediateDirectories: true)
    }
    
    public func loadState() async throws -> BrainState {
        let stateFile = brainstateBase.appendingPathComponent(role).appendingPathComponent("brainstate.json")
        
        guard fileManager.fileExists(atPath: stateFile.path) else {
            let newState = BrainState(role: role, version: "1.0.0")
            try await saveState(newState)
            return newState
        }
        
        let data = try Data(contentsOf: stateFile)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let state = try decoder.decode(BrainState.self, from: data)
        self.currentState = state
        
        return state
    }
    
    public func saveState(_ state: BrainState) async throws {
        let stateFile = brainstateBase.appendingPathComponent(role).appendingPathComponent("brainstate.json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(state)
        try data.write(to: stateFile)
        
        self.currentState = state
    }
    
    public func updateState(updates: (inout BrainState) -> Void) async throws {
        var state = try await loadState()
        updates(&state)
        try await saveState(state)
    }
}
```

---

### 4. **Swift Daemon System**

```swift
import Foundation

public actor GitBrainDaemon {
    public let system: GitBrainSystem
    public let communication: MaildirCommunication
    public let memory: BrainStateManager
    
    private var isRunning = false
    private var task: Task<Void, Never>?
    
    public init(system: GitBrainSystem, communication: MaildirCommunication, memory: BrainStateManager) {
        self.system = system
        self.communication = communication
        self.memory = memory
    }
    
    public func start() async {
        guard !isRunning else { return }
        isRunning = true
        
        task = Task {
            Logger.info("Daemon started for role: \(system.role)")
            
            await communication.startMonitoring()
            
            for await message in communication.messageStream {
                do {
                    try await processMessage(message)
                } catch {
                    Logger.error("Failed to process message: \(error)")
                }
            }
        }
    }
    
    public func stop() async {
        guard isRunning else { return }
        isRunning = false
        task?.cancel()
        task = nil
        Logger.info("Daemon stopped for role: \(system.role)")
    }
    
    private func processMessage(_ message: Message) async throws {
        Logger.info("Processing message from: \(message.from)")
        
        // Update brainstate
        try await memory.updateState { state in
            state.lastMessageReceived = Date()
            state.messageCount += 1
        }
        
        // Process message based on role
        switch system.role {
        case "coder":
            try await processCoderMessage(message)
        case "overseer":
            try await processOverseerMessage(message)
        default:
            Logger.warning("Unknown role: \(system.role)")
        }
    }
    
    private func processCoderMessage(_ message: Message) async throws {
        // CoderAI-specific message processing
        Logger.info("CoderAI processing message")
    }
    
    private func processOverseerMessage(_ message: Message) async throws {
        // OverseerAI-specific message processing
        Logger.info("OverseerAI processing message")
    }
}

public actor DaemonController {
    private let daemon: GitBrainDaemon
    
    public init(daemon: GitBrainDaemon) {
        self.daemon = daemon
    }
    
    public func start(daemonize: Bool = false) async {
        if daemonize {
            // Fork process (if needed)
        }
        await daemon.start()
    }
    
    public func stop() async {
        await daemon.stop()
    }
    
    public func restart() async {
        await stop()
        await start()
    }
}
```

---

### 5. **Swift CLI Tools**

```swift
import ArgumentParser
import Foundation

@main
struct GitBrainCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "GitBrain - AI-powered development assistant",
        subcommands: [DaemonCommand.self, SendCommand.self, CheckCommand.self]
    )
}

struct DaemonCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run GitBrain daemon"
    )
    
    @Option(name: .shortAndLong, help: "Role to run (coder/overseer)")
    var role: String
    
    @Flag(name: .shortAndLong, help: "Run in background")
    var daemonize = false
    
    func run() throws {
        let config = try loadConfig()
        let system = GitBrainSystem(role: role, config: config)
        let communication = try MaildirCommunication(maildirBase: config.maildirBase, role: role)
        let memory = try BrainStateManager(brainstateBase: config.brainstateBase, role: role)
        let daemon = GitBrainDaemon(system: system, communication: communication, memory: memory)
        let controller = DaemonController(daemon: daemon)
        
        Task {
            await controller.start(daemonize: daemonize)
        }
        
        RunLoop.current.run()
    }
}

struct SendCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Send a message"
    )
    
    @Option(name: .shortAndLong, help: "Sender role")
    var from: String
    
    @Option(name: .shortAndLong, help: "Recipient role")
    var to: String
    
    @Option(name: .shortAndLong, help: "Message subject")
    var subject: String
    
    @Argument(help: "Message content")
    var content: String
    
    func run() throws {
        let config = try loadConfig()
        let communication = try MaildirCommunication(maildirBase: config.maildirBase, role: from)
        
        let message = Message(
            from: from,
            to: to,
            subject: subject,
            content: content,
            timestamp: Date(),
            type: .task
        )
        
        Task {
            try await communication.sendMessage(message, to: to)
            print("Message sent successfully")
        }
        
        RunLoop.current.run()
    }
}

struct CheckCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Check for new messages"
    )
    
    @Option(name: .shortAndLong, help: "Role to check")
    var role: String
    
    func run() throws {
        let config = try loadConfig()
        let communication = try MaildirCommunication(maildirBase: config.maildirBase, role: role)
        
        Task {
            let messages = try await communication.receiveMessages()
            print("Found \(messages.count) messages")
            for message in messages {
                print("From: \(message.from)")
                print("Subject: \(message.subject)")
                print("Content: \(message.content.prefix(100))...")
                print("---")
            }
        }
        
        RunLoop.current.run()
    }
}
```

---

## 📅 Migration Phases

### Phase 1: Foundation (Week 1)

**Objective**: Set up Swift package structure and core models

**Tasks**:
1. Create SwiftPM package structure
2. Define core models (Message, BrainState, Task, etc.)
3. Implement Codable for all models
4. Set up basic testing infrastructure
5. Write unit tests for models

**Deliverables**:
- SwiftPM package with Package.swift
- Core models with Codable support
- Basic test suite

---

### Phase 2: Communication (Week 2)

**Objective**: Implement Swift Maildir communication system

**Tasks**:
1. Implement MaildirCommunication actor
2. Implement MessageParser
3. Implement MessageSerializer
4. Add error handling and retries
5. Write unit tests for communication

**Deliverables**:
- Working Maildir communication
- Message parsing and serialization
- Comprehensive tests

---

### Phase 3: Memory (Week 3)

**Objective**: Implement Swift BrainState management

**Tasks**:
1. Implement BrainStateManager actor
2. Implement StatePersistence
3. Implement StateRecovery
4. Add versioning support
5. Write unit tests for memory

**Deliverables**:
- Working BrainState management
- State persistence and recovery
- Comprehensive tests

---

### Phase 4: Daemon (Week 4)

**Objective**: Implement Swift daemon system

**Tasks**:
1. Implement GitBrainDaemon actor
2. Implement DaemonController
3. Add signal handling
4. Implement graceful shutdown
5. Write integration tests for daemon

**Deliverables**:
- Working daemon system
- Graceful shutdown
- Integration tests

---

### Phase 5: Roles (Week 5)

**Objective**: Implement Swift role-based AI system

**Tasks**:
1. Define RoleProtocol
2. Implement BaseRole
3. Implement CoderAI
4. Implement OverseerAI
5. Write unit tests for roles

**Deliverables**:
- Working role system
- CoderAI and OverseerAI implementations
- Comprehensive tests

---

### Phase 6: CLI Tools (Week 6)

**Objective**: Implement Swift CLI tools

**Tasks**:
1. Set up ArgumentParser
2. Implement DaemonCommand
3. Implement SendCommand
4. Implement CheckCommand
5. Write integration tests for CLI

**Deliverables**:
- Working CLI tools
- Integration tests

---

### Phase 7: Migration (Week 7-8)

**Objective**: Migrate from Python to Swift

**Tasks**:
1. Test Swift implementation with existing data
2. Migrate configuration files
3. Migrate BrainState data
4. Migrate Maildir messages
5. Verify all functionality works

**Deliverables**:
- Fully migrated Swift implementation
- All data migrated
- Verified functionality

---

### Phase 8: Cleanup (Week 9)

**Objective**: Remove Python code and finalize Swift implementation

**Tasks**:
1. Remove all Python code
2. Update documentation
3. Clean up dependencies
4. Finalize Swift implementation
5. Write final documentation

**Deliverables**:
- Clean Swift-only codebase
- Updated documentation
- Final implementation

---

## 🔧 Technical Considerations

### 1. **Concurrency**

- Use Swift Concurrency (async/await)
- Use actors for thread-safe access
- Use AsyncStream for message streams
- Use Task for background operations

### 2. **Error Handling**

- Use Swift's error handling
- Define custom error types
- Implement retry logic
- Add comprehensive logging

### 3. **Testing**

- Use Swift Testing framework
- Write unit tests for all components
- Write integration tests for workflows
- Use mock objects for testing

### 4. **Performance**

- Use efficient data structures
- Minimize file I/O
- Use caching where appropriate
- Profile and optimize

### 5. **Security**

- Validate all inputs
- Sanitize file paths
- Use secure file permissions
- Encrypt sensitive data

---

## 📊 Migration Checklist

### Pre-Migration

- [ ] Backup all Python code
- [ ] Backup all data (Maildir, BrainState)
- [ ] Document Python functionality
- [ ] Identify all Python dependencies
- [ ] Create migration plan

### During Migration

- [ ] Implement Swift models
- [ ] Implement Swift communication
- [ ] Implement Swift memory
- [ ] Implement Swift daemon
- [ ] Implement Swift roles
- [ ] Implement Swift CLI tools
- [ ] Test Swift implementation
- [ ] Migrate data
- [ ] Verify functionality

### Post-Migration

- [ ] Remove Python code
- [ ] Update documentation
- [ ] Clean up dependencies
- [ ] Finalize Swift implementation
- [ ] Archive Python code

---

## 🎯 Success Criteria

1. **Functionality**: All Python features work in Swift
2. **Performance**: Swift implementation is faster
3. **Reliability**: Swift implementation is more stable
4. **Maintainability**: Swift code is easier to maintain
5. **Testability**: Swift code is easier to test

---

## 📝 Notes

- **Critical**: Each repository must have its own mailbox
- **Critical**: Cannot depend on mailbox outside repo
- **Critical**: Use Swift 6.2 features
- **Critical**: Follow MVVM + POP architecture
- **Critical**: Use Swift Testing framework
- **Critical**: Document all changes

---

## 🚀 Next Steps

1. **Review**: CoderAI reviews this migration plan
2. **Discuss**: Discuss approach and timeline
3. **Decide**: Agree on migration plan
4. **Implement**: Start Phase 1
5. **Test**: Test each phase
6. **Migrate**: Complete migration
7. **Cleanup**: Remove Python code

---

**Document Status**: 📝 Open for Discussion  
**Last Updated**: 2026-02-10  
**Next Review**: After CoderAI feedback
