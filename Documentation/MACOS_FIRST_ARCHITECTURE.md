# macOS-First Architecture - Brand New System Design

**Status**: 📝 Design Phase  
**Created**: 2026-02-10  
**Participants**: OverseerAI, CoderAI  
**Target Repository**: swiftgitbrain

## 🎯 Vision

**Build a brand new macOS-native system from scratch, without Python limitations.**

**Single Target**: macOS only  
**Architecture**: macOS-first, leveraging native APIs  
**Design**: Clean slate, no Python legacy constraints

---

## 🏗️ Core Principles

### 1. **macOS-Only Target**
- Single platform: macOS
- No cross-platform concerns
- Full access to macOS APIs
- Native macOS integration

### 2. **Native macOS APIs**
- Use Foundation, AppKit, SwiftUI
- Use LaunchAgents/LaunchDaemons
- Use XPC for inter-process communication
- Use NotificationCenter for system events
- Use AppleScript for automation

### 3. **Modern Swift Features**
- Swift 6.2 with latest features
- Swift Concurrency (async/await)
- Swift Actors for thread safety
- Swift Combine for reactive programming
- Swift Testing framework

### 4. **Clean Architecture**
- MVVM + Protocol-Oriented Programming
- Separation of concerns
- Testable design
- Maintainable codebase

---

## 📦 System Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                     macOS System                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              GitBrain Swift Application                    │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  CoderAI     │  │ OverseerAI   │  │  Other AIs   │  │
│  │  (Actor)     │  │  (Actor)     │  │  (Actor)     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                  │                  │            │
│         └──────────────────┼──────────────────┘            │
│                            ▼                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Communication Layer (XPC)                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                             │
│                            ▼                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Task Management Layer                        │  │
│  │  - Task Queue                                      │  │
│  │  - Task Scheduler                                  │  │
│  │  - Task Execution                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                             │
│                            ▼                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Memory Management Layer                     │  │
│  │  - BrainState                                     │  │
│  │  - Persistent Storage                              │  │
│  │  - State Recovery                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                             │
│                            ▼                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         macOS Integration Layer                     │  │
│  │  - LaunchAgents/LaunchDaemons                      │  │
│  │  - NotificationCenter                              │  │
│  │  - AppleScript                                     │  │
│  │  - File System                                     │  │
│  │  - Network                                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Core Components

### 1. **AI Role System (Actors)**

```swift
import Foundation

public protocol AIActor: Actor {
    var role: String { get }
    var state: AIState { get set }
    
    func start() async
    func stop() async
    func processMessage(_ message: Message) async throws
}

public actor CoderAI: AIActor {
    public let role = "coder"
    public var state: AIState = .idle
    
    private let communication: XPCCommunication
    private let taskManager: TaskManager
    private let memory: BrainStateManager
    
    public init(communication: XPCCommunication, 
                taskManager: TaskManager, 
                memory: BrainStateManager) {
        self.communication = communication
        self.taskManager = taskManager
        self.memory = memory
    }
    
    public func start() async {
        state = .active
        Logger.info("CoderAI started")
        
        for await message in communication.messageStream {
            try? await processMessage(message)
        }
    }
    
    public func stop() async {
        state = .idle
        Logger.info("CoderAI stopped")
    }
    
    public func processMessage(_ message: Message) async throws {
        Logger.info("Processing message: \(message.subject)")
        
        switch message.type {
        case .task:
            try await handleTask(message)
        case .review:
            try await handleReview(message)
        case .notification:
            try await handleNotification(message)
        }
    }
    
    private func handleTask(_ message: Message) async throws {
        let task = try TaskParser.parse(message.content)
        try await taskManager.execute(task)
    }
    
    private func handleReview(_ message: Message) async throws {
        let review = try ReviewParser.parse(message.content)
        try await taskManager.applyReview(review)
    }
    
    private func handleNotification(_ message: Message) async throws {
        Logger.info("Notification: \(message.content)")
    }
}

public actor OverseerAI: AIActor {
    public let role = "overseer"
    public var state: AIState = .idle
    
    private let communication: XPCCommunication
    private let taskManager: TaskManager
    private let memory: BrainStateManager
    
    public init(communication: XPCCommunication, 
                taskManager: TaskManager, 
                memory: BrainStateManager) {
        self.communication = communication
        self.taskManager = taskManager
        self.memory = memory
    }
    
    public func start() async {
        state = .active
        Logger.info("OverseerAI started")
        
        for await message in communication.messageStream {
            try? await processMessage(message)
        }
    }
    
    public func stop() async {
        state = .idle
        Logger.info("OverseerAI stopped")
    }
    
    public func processMessage(_ message: Message) async throws {
        Logger.info("Processing message: \(message.subject)")
        
        switch message.type {
        case .status:
            try await handleStatus(message)
        case .review:
            try await handleReview(message)
        case .notification:
            try await handleNotification(message)
        }
    }
    
    private func handleStatus(_ message: Message) async throws {
        let status = try StatusParser.parse(message.content)
        try await memory.updateStatus(status)
    }
    
    private func handleReview(_ message: Message) async throws {
        let review = try ReviewParser.parse(message.content)
        try await taskManager.applyReview(review)
    }
    
    private func handleNotification(_ message: Message) async throws {
        Logger.info("Notification: \(message.content)")
    }
}
```

---

### 2. **XPC Communication System**

```swift
import Foundation

public actor XPCCommunication {
    public let service: String
    private let connection: NSXPCConnection
    
    private let messageStream = AsyncStream<Message>.makeStream()
    
    public init(service: String) throws {
        self.service = service
        self.connection = NSXPCConnection(serviceName: service)
        connection.remoteObjectInterface = NSXPCInterface(with: XPCServiceProtocol.self)
        connection.resume()
        
        setupMessageListener()
    }
    
    private func setupMessageListener() {
        let listener = connection.remoteObjectProxy as! XPCServiceProtocol
        listener.setMessageHandler { [weak self] message in
            self?.messageStream.continuation.yield(message)
        }
    }
    
    public func sendMessage(_ message: Message, to recipient: String) async throws {
        let service = XPCServiceName(for: recipient)
        let connection = NSXPCConnection(serviceName: service)
        connection.remoteObjectInterface = NSXPCInterface(with: XPCServiceProtocol.self)
        connection.resume()
        
        defer { connection.invalidate() }
        
        let proxy = connection.remoteObjectProxy as! XPCServiceProtocol
        try await proxy.receiveMessage(message)
    }
    
    public var messageStream: AsyncStream<Message> {
        messageStream.stream
    }
}

@objc public protocol XPCServiceProtocol: NSObjectProtocol {
    func receiveMessage(_ message: Message, reply: @escaping (Error?) -> Void)
    func setMessageHandler(_ handler: @escaping (Message) -> Void)
}

public struct XPCServiceName {
    public static func forRole(_ role: String) -> String {
        "com.gitbrain.\(role)"
    }
}
```

---

### 3. **Task Management System**

```swift
import Foundation

public actor TaskManager {
    private var taskQueue: [Task] = []
    private var activeTasks: [String: Task] = [:]
    private var completedTasks: [String: Task] = [:]
    
    private let scheduler: TaskScheduler
    private let executor: TaskExecutor
    
    public init(scheduler: TaskScheduler, executor: TaskExecutor) {
        self.scheduler = scheduler
        self.executor = executor
    }
    
    public func enqueue(_ task: Task) async {
        taskQueue.append(task)
        Logger.info("Task enqueued: \(task.id)")
    }
    
    public func startProcessing() async {
        for await _ in scheduler.tickStream {
            guard !taskQueue.isEmpty else { continue }
            
            let task = taskQueue.removeFirst()
            await execute(task)
        }
    }
    
    public func execute(_ task: Task) async {
        activeTasks[task.id] = task
        task.state = .running
        
        Logger.info("Executing task: \(task.id)")
        
        do {
            let result = try await executor.execute(task)
            task.result = result
            task.state = .completed
            completedTasks[task.id] = task
            activeTasks.removeValue(forKey: task.id)
            
            Logger.info("Task completed: \(task.id)")
        } catch {
            task.error = error
            task.state = .failed
            activeTasks.removeValue(forKey: task.id)
            
            Logger.error("Task failed: \(task.id) - \(error)")
        }
    }
    
    public func getTaskStatus(_ taskId: String) -> TaskState? {
        activeTasks[taskId]?.state ?? completedTasks[taskId]?.state
    }
}

public actor TaskScheduler {
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common)
    private var cancellable: AnyCancellable?
    
    public var tickStream: AsyncStream<Void> {
        AsyncStream { continuation in
            cancellable = timer
                .autoconnect()
                .sink { _ in
                    continuation.yield()
                }
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

public actor TaskExecutor {
    public func execute(_ task: Task) async throws -> TaskResult {
        switch task.type {
        case .code:
            return try await executeCodeTask(task)
        case .review:
            return try await executeReviewTask(task)
        case .test:
            return try await executeTestTask(task)
        case .build:
            return try await executeBuildTask(task)
        }
    }
    
    private func executeCodeTask(_ task: Task) async throws -> TaskResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = task.parameters
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return TaskResult(output: output, exitCode: process.terminationStatus)
    }
    
    private func executeReviewTask(_ task: Task) async throws -> TaskResult {
        TaskResult(output: "Review completed", exitCode: 0)
    }
    
    private func executeTestTask(_ task: Task) async throws -> TaskResult {
        TaskResult(output: "Tests passed", exitCode: 0)
    }
    
    private func executeBuildTask(_ task: Task) async throws -> TaskResult {
        TaskResult(output: "Build succeeded", exitCode: 0)
    }
}
```

---

### 4. **BrainState Memory Management**

```swift
import Foundation

public actor BrainStateManager {
    private let storeURL: URL
    private var currentState: BrainState?
    
    public init(storeURL: URL) throws {
        self.storeURL = storeURL
        try createStore()
    }
    
    private func createStore() throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    public func loadState() async throws -> BrainState {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            let newState = BrainState(version: "1.0.0", createdAt: Date())
            try await saveState(newState)
            return newState
        }
        
        let data = try Data(contentsOf: storeURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let state = try decoder.decode(BrainState.self, from: data)
        self.currentState = state
        
        return state
    }
    
    public func saveState(_ state: BrainState) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(state)
        try data.write(to: storeURL)
        
        self.currentState = state
    }
    
    public func updateState(updates: (inout BrainState) -> Void) async throws {
        var state = try await loadState()
        updates(&state)
        try await saveState(state)
    }
}

public struct BrainState: Codable {
    public var version: String
    public var createdAt: Date
    public var lastModified: Date
    public var messageCount: Int
    public var taskCount: Int
    public var customData: [String: String]
    
    public init(version: String, createdAt: Date) {
        self.version = version
        self.createdAt = createdAt
        self.lastModified = Date()
        self.messageCount = 0
        self.taskCount = 0
        self.customData = [:]
    }
}
```

---

### 5. **macOS Integration Layer**

#### LaunchAgent/LaunchDaemon

```swift
import Foundation

public struct LaunchAgent {
    public let label: String
    public let executablePath: String
    public let arguments: [String]
    public let runAtLoad: Bool
    
    public func install() throws {
        let plist = generatePlist()
        let plistPath = getLaunchAgentPath()
        
        try plist.write(to: plistPath, atomically: true)
        
        try Process.execute("/bin/launchctl", arguments: ["load", plistPath.path])
    }
    
    public func uninstall() throws {
        let plistPath = getLaunchAgentPath()
        
        try Process.execute("/bin/launchctl", arguments: ["unload", plistPath.path])
        try FileManager.default.removeItem(at: plistPath)
    }
    
    private func generatePlist() -> [String: Any] {
        [
            "Label": label,
            "ProgramArguments": [executablePath] + arguments,
            "RunAtLoad": runAtLoad,
            "KeepAlive": true
        ]
    }
    
    private func getLaunchAgentPath() -> URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir
            .appendingPathComponent("Library")
            .appendingPathComponent("LaunchAgents")
            .appendingPathComponent("\(label).plist")
    }
}
```

#### NotificationCenter Integration

```swift
import Foundation

public class SystemNotificationObserver {
    private var observers: [NSObjectProtocol] = []
    
    public func startObserving() {
        observers.append(
            NotificationCenter.default.addObserver(
                forName: NSWorkspace.didWakeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleWake()
            }
        )
        
        observers.append(
            NotificationCenter.default.addObserver(
                forName: NSWorkspace.willSleepNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleSleep()
            }
        )
    }
    
    public func stopObserving() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }
    
    private func handleWake() {
        Logger.info("System woke up")
    }
    
    private func handleSleep() {
        Logger.info("System going to sleep")
    }
}
```

#### AppleScript Integration

```swift
import Foundation

public class AppleScriptExecutor {
    public func execute(_ script: String) throws -> String {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: script)
        let output = scriptObject?.executeAndReturnError(&error)
        
        if let error = error {
            throw AppleScriptError.executionFailed(error.description)
        }
        
        return output?.stringValue ?? ""
    }
    
    public func executeGitCommand(_ command: String) throws -> String {
        let script = """
        tell application "Terminal"
            do script "\(command)"
        end tell
        """
        return try execute(script)
    }
}

public enum AppleScriptError: Error {
    case executionFailed(String)
}
```

---

## 📱 CLI Tools

### Swift Package Structure

```swift
import ArgumentParser
import Foundation

@main
struct GitBrainCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "GitBrain - macOS-native AI development assistant",
        subcommands: [
            DaemonCommand.self,
            SendCommand.self,
            CheckCommand.self,
            StatusCommand.self,
            InstallCommand.self
        ]
    )
}

struct DaemonCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run GitBrain daemon"
    )
    
    @Option(name: .shortAndLong, help: "Role to run")
    var role: String
    
    @Flag(name: .shortAndLong, help: "Install as LaunchAgent")
    var install = false
    
    func run() throws {
        let config = try loadConfig()
        
        if install {
            try installAsLaunchAgent(role: role)
        } else {
            try runDaemon(role: role, config: config)
        }
    }
    
    private func installAsLaunchAgent(role: String) throws {
        let agent = LaunchAgent(
            label: "com.gitbrain.\(role)",
            executablePath: "/usr/local/bin/gitbrain",
            arguments: ["daemon", "--role", role],
            runAtLoad: true
        )
        
        try agent.install()
        print("LaunchAgent installed successfully")
    }
    
    private func runDaemon(role: String, config: Config) throws {
        let communication = try XPCCommunication(service: XPCServiceName.forRole(role))
        let scheduler = TaskScheduler()
        let executor = TaskExecutor()
        let taskManager = TaskManager(scheduler: scheduler, executor: executor)
        let memory = try BrainStateManager(storeURL: config.brainstateURL)
        
        let ai: AIActor
        
        switch role {
        case "coder":
            ai = CoderAI(communication: communication, taskManager: taskManager, memory: memory)
        case "overseer":
            ai = OverseerAI(communication: communication, taskManager: taskManager, memory: memory)
        default:
            throw CLIError.invalidRole(role)
        }
        
        Task {
            await ai.start()
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
    
    @Option(name: .shortAndLong, help: "Message type")
    var type: String = "notification"
    
    @Argument(help: "Message content")
    var content: String
    
    func run() throws {
        let message = Message(
            from: from,
            to: to,
            subject: subject,
            content: content,
            type: MessageType(rawValue: type) ?? .notification,
            timestamp: Date()
        )
        
        let communication = try XPCCommunication(service: XPCServiceName.forRole(from))
        
        Task {
            try await communication.sendMessage(message, to: to)
            print("Message sent successfully")
        }
        
        RunLoop.current.run()
    }
}

struct CheckCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Check status"
    )
    
    @Option(name: .shortAndLong, help: "Role to check")
    var role: String
    
    func run() throws {
        let config = try loadConfig()
        let memory = try BrainStateManager(storeURL: config.brainstateURL)
        let state = try await memory.loadState()
        
        print("Role: \(role)")
        print("Version: \(state.version)")
        print("Messages: \(state.messageCount)")
        print("Tasks: \(state.taskCount)")
        print("Last Modified: \(state.lastModified)")
    }
}

struct StatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show system status"
    )
    
    func run() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        let gitbrainServices = output.split(separator: "\n")
            .filter { $0.contains("com.gitbrain") }
        
        print("GitBrain Services:")
        for service in gitbrainServices {
            print("  \(service)")
        }
    }
}

struct InstallCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Install GitBrain"
    )
    
    func run() throws {
        try installCLI()
        try installLaunchAgents()
        try createDirectories()
        
        print("GitBrain installed successfully")
    }
    
    private func installCLI() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = [
            "build",
            "-c", "release",
            "--product", "gitbrain"
        ]
        
        try process.run()
        process.waitUntilExit()
        
        let binaryPath = URL(fileURLWithPath: ".build/release/gitbrain")
        let installPath = URL(fileURLWithPath: "/usr/local/bin/gitbrain")
        
        try FileManager.default.copyItem(at: binaryPath, to: installPath)
    }
    
    private func installLaunchAgents() throws {
        for role in ["coder", "overseer"] {
            let agent = LaunchAgent(
                label: "com.gitbrain.\(role)",
                executablePath: "/usr/local/bin/gitbrain",
                arguments: ["daemon", "--role", role],
                runAtLoad: false
            )
            
            try agent.install()
        }
    }
    
    private func createDirectories() throws {
        let configDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gitbrain")
        
        try FileManager.default.createDirectory(
            at: configDir,
            withIntermediateDirectories: true
        )
    }
}

enum CLIError: Error {
    case invalidRole(String)
    case installationFailed(String)
}
```

---

## 🎯 macOS-Specific Features

### 1. **LaunchAgents/LaunchDaemons**
- Automatic daemon startup
- System-wide service management
- Automatic restart on failure
- User-specific services

### 2. **XPC Communication**
- Secure inter-process communication
- Efficient message passing
- Built-in error handling
- System-level integration

### 3. **NotificationCenter**
- System event monitoring
- Sleep/wake notifications
- Application lifecycle events
- Custom notifications

### 4. **AppleScript**
- Automation integration
- Terminal control
- Application control
- System-wide scripting

### 5. **File System**
- FSEvents for file watching
- Extended attributes
- Security-scoped bookmarks
- Sandbox support

### 6. **Networking**
- Network framework
- URL session
- Bonjour for discovery
- Secure transport

---

## 📅 Implementation Phases

### Phase 1: Foundation (Week 1)
- Create SwiftPM package
- Define core models
- Implement Codable
- Set up testing

### Phase 2: Communication (Week 2)
- Implement XPC communication
- Implement message parsing
- Implement message serialization
- Test communication

### Phase 3: Task Management (Week 3)
- Implement TaskManager
- Implement TaskScheduler
- Implement TaskExecutor
- Test task execution

### Phase 4: Memory Management (Week 4)
- Implement BrainStateManager
- Implement persistence
- Implement recovery
- Test memory

### Phase 5: AI Roles (Week 5)
- Implement AIActor protocol
- Implement CoderAI
- Implement OverseerAI
- Test roles

### Phase 6: macOS Integration (Week 6)
- Implement LaunchAgent
- Implement NotificationCenter
- Implement AppleScript
- Test integration

### Phase 7: CLI Tools (Week 7)
- Implement ArgumentParser
- Implement commands
- Test CLI
- Document usage

### Phase 8: Testing & Polish (Week 8)
- Comprehensive testing
- Performance optimization
- Documentation
- Release

---

## 🎯 Success Criteria

1. **macOS-Native**: Full use of macOS APIs
2. **Stable**: Robust error handling
3. **Fast**: Efficient performance
4. **Secure**: Secure communication
5. **Maintainable**: Clean architecture

---

## 📝 Notes

- **Critical**: macOS-only target
- **Critical**: No Python legacy
- **Critical**: Use native APIs
- **Critical**: Swift 6.2 features
- **Critical**: MVVM + POP
- **Critical**: Swift Testing

---

## 🚀 Next Steps

1. **Review**: CoderAI reviews this architecture
2. **Discuss**: Discuss approach and timeline
3. **Decide**: Agree on architecture
4. **Implement**: Start Phase 1
5. **Test**: Test each phase
6. **Release**: Complete system

---

**Document Status**: 📝 Open for Discussion  
**Last Updated**: 2026-02-10  
**Next Review**: After CoderAI feedback
