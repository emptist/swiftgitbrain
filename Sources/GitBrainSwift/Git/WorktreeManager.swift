import Foundation

public actor WorktreeManager {
    private let repository: URL
    private let fileManager: FileManager
    
    public init(repository: URL) {
        self.repository = repository
        self.fileManager = FileManager.default
    }
    
    public static func setupSharedWorktree(
        repository: String,
        sharedPath: String
    ) async throws -> Worktree {
        let manager = WorktreeManager(repository: URL(fileURLWithPath: repository))
        return try await manager.createWorktree(path: sharedPath, branch: "master")
    }
    
    public func createWorktree(path: String, branch: String) async throws -> Worktree {
        let gitManager = GitManager(worktree: repository)
        
        let output = try await executeGitCommand(["worktree", "add", path, branch])
        
        let worktree = Worktree(
            path: path,
            branch: branch,
            repository: repository.path
        )
        
        return worktree
    }
    
    public func listWorktrees() async throws -> [Worktree] {
        let output = try await executeGitCommand(["worktree", "list", "--porcelain"])
        return parseWorktreeList(output)
    }
    
    public func removeWorktree(_ path: String) async throws {
        _ = try await executeGitCommand(["worktree", "remove", path])
    }
    
    public func syncWorktree(_ path: String) async throws {
        let worktreeURL = URL(fileURLWithPath: path)
        let gitManager = GitManager(worktree: worktreeURL)
        
        try await gitManager.pull()
        try await gitManager.push()
    }
    
    public func getWorktreeInfo(_ path: String) async throws -> WorktreeInfo {
        let worktreeURL = URL(fileURLWithPath: path)
        let gitManager = GitManager(worktree: worktreeURL)
        
        let branch = try await gitManager.getCurrentBranch()
        let status = try await gitManager.getStatus()
        
        return WorktreeInfo(
            path: path,
            branch: branch,
            isClean: status.isClean,
            hasChanges: status.hasChanges,
            modifiedFiles: status.modified,
            addedFiles: status.added,
            deletedFiles: status.deleted,
            untrackedFiles: status.untracked
        )
    }
    
    public func pruneWorktrees() async throws {
        _ = try await executeGitCommand(["worktree", "prune"])
    }
    
    public func moveWorktree(from: String, to: String) async throws {
        _ = try await executeGitCommand(["worktree", "move", from, to])
    }
    
    private func executeGitCommand(_ arguments: [String]) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = repository
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw WorktreeError.commandFailed(arguments: arguments, output: output, exitCode: process.terminationStatus)
        }
        
        return output
    }
    
    private func parseWorktreeList(_ output: String) -> [Worktree] {
        var worktrees: [Worktree] = []
        var currentWorktree: [String: String] = [:]
        
        for line in output.components(separatedBy: "\n") {
            if line.isEmpty { continue }
            
            let parts = line.components(separatedBy: " ")
            if parts.count >= 2 {
                let key = parts[0]
                let value = parts[1...].joined(separator: " ")
                currentWorktree[key] = value
            } else if currentWorktree.isEmpty {
                worktrees.append(Worktree(
                    path: line,
                    branch: "",
                    repository: repository.path
                ))
            }
        }
        
        return worktrees
    }
}

public struct Worktree: Sendable, Identifiable {
    public let id = UUID()
    public let path: String
    public let branch: String
    public let repository: String
    
    public var url: URL {
        return URL(fileURLWithPath: path)
    }
}

public struct WorktreeInfo: Sendable {
    public let path: String
    public let branch: String
    public let isClean: Bool
    public let hasChanges: Bool
    public let modifiedFiles: [String]
    public let addedFiles: [String]
    public let deletedFiles: [String]
    public let untrackedFiles: [String]
}

public enum WorktreeError: Error, LocalizedError {
    case commandFailed(arguments: [String], output: String, exitCode: Int32)
    case worktreeNotFound(String)
    case worktreeAlreadyExists(String)
    case invalidPath(String)
    
    public var errorDescription: String? {
        switch self {
        case .commandFailed(let arguments, let output, let exitCode):
            return "Git worktree command failed: \(arguments.joined(separator: " ")). Exit code: \(exitCode). Output: \(output)"
        case .worktreeNotFound(let path):
            return "Worktree not found: \(path)"
        case .worktreeAlreadyExists(let path):
            return "Worktree already exists: \(path)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        }
    }
}