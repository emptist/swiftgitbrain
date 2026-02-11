import Foundation

public actor GitManager {
    private let worktree: URL
    private let fileManager: FileManager
    
    public init(worktree: URL) {
        self.worktree = worktree
        self.fileManager = FileManager.default
    }
    
    public func add(_ files: [String]) async throws {
        for file in files {
            try await executeGitCommand(["add", file])
        }
    }
    
    public func commit(_ message: String) async throws {
        try await executeGitCommand(["commit", "-m", message])
    }
    
    public func push() async throws {
        try await executeGitCommand(["push"])
    }
    
    public func pull() async throws {
        try await executeGitCommand(["pull"])
    }
    
    public func sync() async throws {
        try await pull()
        try await push()
    }
    
    public func getStatus() async throws -> GitStatus {
        let output = try await executeGitCommand(["status", "--porcelain"])
        return parseGitStatus(output)
    }
    
    public func getCurrentBranch() async throws -> String {
        let output = try await executeGitCommand(["rev-parse", "--abbrev-ref", "HEAD"])
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func createBranch(_ name: String) async throws {
        try await executeGitCommand(["checkout", "-b", name])
    }
    
    public func checkoutBranch(_ name: String) async throws {
        try await executeGitCommand(["checkout", name])
    }
    
    public func mergeBranch(_ name: String) async throws {
        try await executeGitCommand(["merge", name])
    }
    
    public func addRemote(name: String, url: String) async throws {
        try await executeGitCommand(["remote", "add", name, url])
    }
    
    public func getRemoteURL() async throws -> String {
        let output = try await executeGitCommand(["remote", "get-url", "origin"])
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func executeGitCommand(_ arguments: [String]) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = worktree
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        try process.run()
        
        let timeoutDuration: TimeInterval = 30
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
            process.terminate()
            throw GitError.commandFailed(arguments: arguments, output: "Command timed out after \(timeoutDuration)s", exitCode: -1)
        }
        
        process.waitUntilExit()
        timeoutTask.cancel()
        
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: stdoutData, encoding: .utf8) ?? ""
        let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            let fullOutput = errorOutput.isEmpty ? output : "\(output)\n\(errorOutput)"
            throw GitError.commandFailed(arguments: arguments, output: fullOutput, exitCode: process.terminationStatus)
        }
        
        return output
    }
    
    private func parseGitStatus(_ output: String) -> GitStatus {
        var status = GitStatus()
        
        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            let prefix = String(line.prefix(2))
            let path = String(line.dropFirst(3))
            
            switch prefix {
            case "M ":
                status.modified.append(path)
            case " M":
                status.modified.append(path)
            case "A ":
                status.added.append(path)
            case "D ":
                status.deleted.append(path)
            case "??":
                status.untracked.append(path)
            default:
                break
            }
        }
        
        return status
    }
}

public struct GitStatus: Sendable {
    public var added: [String] = []
    public var modified: [String] = []
    public var deleted: [String] = []
    public var untracked: [String] = []
    
    public var isClean: Bool {
        return added.isEmpty && modified.isEmpty && deleted.isEmpty && untracked.isEmpty
    }
    
    public var hasChanges: Bool {
        return !isClean
    }
}

public enum GitError: Error, LocalizedError {
    case commandFailed(arguments: [String], output: String, exitCode: Int32)
    case notAGitRepository
    case branchNotFound(String)
    case mergeConflict
    
    public var errorDescription: String? {
        switch self {
        case .commandFailed(let arguments, let output, let exitCode):
            return "Git command failed: \(arguments.joined(separator: " ")). Exit code: \(exitCode). Output: \(output)"
        case .notAGitRepository:
            return "Not a git repository"
        case .branchNotFound(let branch):
            return "Branch not found: \(branch)"
        case .mergeConflict:
            return "Merge conflict detected"
        }
    }
}