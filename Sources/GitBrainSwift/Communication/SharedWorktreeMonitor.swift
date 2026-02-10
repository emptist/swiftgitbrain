import Foundation
import Dispatch

public actor SharedWorktreeMonitor {
    private let sharedWorktree: URL
    private let fileManager: FileManager
    private var eventStream: DispatchSourceFileSystemObject?
    private var handlers: [String: (Message) async -> Void]
    private var communication: SharedWorktreeCommunication
    private var isMonitoring = false
    private var task: Task<Void, Never>?
    
    public init(sharedWorktree: URL) async throws {
        self.sharedWorktree = sharedWorktree
        self.fileManager = FileManager.default
        self.handlers = [:]
        self.communication = SharedWorktreeCommunication(sharedWorktree: sharedWorktree)
    }
    
    public func start() async throws {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        
        let descriptor = open(sharedWorktree.path, O_EVTONLY)
        guard descriptor != -1 else {
            throw MonitorError.failedToOpenWorktree
        }
        
        eventStream = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: .write,
            queue: .main
        )
        
        eventStream?.setEventHandler { [weak self] in
            Task {
                await self?.handleFileSystemEvent()
            }
        }
        
        eventStream?.setCancelHandler { [weak self] in
            close(descriptor)
            self?.isMonitoring = false
        }
        
        eventStream?.resume()
        
        task = Task {
            while isMonitoring {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await checkForNewMessages()
            }
        }
    }
    
    public func stop() {
        isMonitoring = false
        eventStream?.cancel()
        eventStream = nil
        task?.cancel()
        task = nil
    }
    
    public func registerHandler(
        for role: String,
        handler: @escaping (Message) async -> Void
    ) {
        handlers[role] = handler
    }
    
    public func unregisterHandler(for role: String) {
        handlers.removeValue(forKey: role)
    }
    
    private func handleFileSystemEvent() async {
        await checkForNewMessages()
    }
    
    private func checkForNewMessages() async {
        for role in handlers.keys {
            do {
                let messages = try await communication.receiveMessages(for: role)
                
                for message in messages {
                    if let handler = handlers[role] {
                        await handler(message)
                    }
                }
            } catch {
                print("Error checking messages for \(role): \(error)")
            }
        }
    }
    
    public func getRegisteredRoles() -> [String] {
        return Array(handlers.keys)
    }
    
    public func isRunning() -> Bool {
        return isMonitoring
    }
    
    public enum MonitorError: Error {
        case failedToOpenWorktree
        case alreadyMonitoring
        case notMonitoring
    }
}