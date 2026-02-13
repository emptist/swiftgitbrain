import Foundation

public actor GitManager {
    private let worktree: URL
    private let fileManager: FileManager
    private let defaultTimeout: TimeInterval
    private let maxRetries: Int
    
    public init(worktree: URL, defaultTimeout: TimeInterval = 30, maxRetries: Int = 3) {
        self.worktree = worktree
        self.fileManager = FileManager.default
        self.defaultTimeout = defaultTimeout
        self.maxRetries = maxRetries
        GitBrainLogger.info("GitManager initialized for worktree: \(worktree.path)")
    }
    
    public func add(_ files: [String]) async throws {
        GitBrainLogger.debug("Adding files: \(files.joined(separator: ", "))")
        for file in files {
            try await executeGitCommand(["add", file])
        }
        GitBrainLogger.info("Successfully added \(files.count) file(s)")
    }
    
    public func commit(_ message: String) async throws {
        GitBrainLogger.debug("Committing with message: \(message)")
        try await executeGitCommand(["commit", "-m", message])
        GitBrainLogger.info("Successfully committed changes")
    }
    
    public func push() async throws {
        GitBrainLogger.debug("Pushing changes")
        try await executeGitCommand(["push"])
        GitBrainLogger.info("Successfully pushed changes")
    }
    
    public func pull() async throws {
        GitBrainLogger.debug("Pulling changes")
        try await executeGitCommand(["pull"])
        GitBrainLogger.info("Successfully pulled changes")
    }
    
    public func sync() async throws {
        GitBrainLogger.debug("Syncing changes (pull then push)")
        try await pull()
        try await push()
        GitBrainLogger.info("Successfully synced changes")
    }
    
    public func getStatus() async throws -> GitStatus {
        GitBrainLogger.debug("Getting git status")
        let output = try await executeGitCommand(["status", "--porcelain"])
        let status = parseGitStatus(output)
        GitBrainLogger.debug("Git status: \(status.added.count) added, \(status.modified.count) modified, \(status.deleted.count) deleted, \(status.untracked.count) untracked")
        return status
    }
    
    public func getCurrentBranch() async throws -> String {
        GitBrainLogger.debug("Getting current branch")
        let output = try await executeGitCommand(["rev-parse", "--abbrev-ref", "HEAD"])
        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
        GitBrainLogger.debug("Current branch: \(branch)")
        return branch
    }
    
    public func createBranch(_ name: String) async throws {
        GitBrainLogger.debug("Creating branch: \(name)")
        try await executeGitCommand(["checkout", "-b", name])
        GitBrainLogger.info("Successfully created branch: \(name)")
    }
    
    public func checkoutBranch(_ name: String) async throws {
        GitBrainLogger.debug("Checking out branch: \(name)")
        try await executeGitCommand(["checkout", name])
        GitBrainLogger.info("Successfully checked out branch: \(name)")
    }
    
    public func mergeBranch(_ name: String) async throws {
        GitBrainLogger.debug("Merging branch: \(name)")
        try await executeGitCommand(["merge", name])
        GitBrainLogger.info("Successfully merged branch: \(name)")
    }
    
    public func addRemote(name: String, url: String) async throws {
        GitBrainLogger.debug("Adding remote: \(name) with URL: \(url)")
        try await executeGitCommand(["remote", "add", name, url])
        GitBrainLogger.info("Successfully added remote: \(name)")
    }
    
    public func getRemoteURL() async throws -> String {
        GitBrainLogger.debug("Getting remote URL")
        let output = try await executeGitCommand(["remote", "get-url", "origin"])
        let url = output.trimmingCharacters(in: .whitespacesAndNewlines)
        GitBrainLogger.debug("Remote URL: \(url)")
        return url
    }
    
    private func executeGitCommand(_ arguments: [String], timeout: TimeInterval? = nil, retryCount: Int = 0) async throws -> String {
        let actualTimeout = timeout ?? defaultTimeout
        GitBrainLogger.debug("Executing git command: \(arguments.joined(separator: " "))")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = worktree
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        try process.run()
        
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(actualTimeout * 1_000_000_000))
            process.terminate()
            try? process.waitUntilExit()
            GitBrainLogger.error("Git command timed out: \(arguments.joined(separator: " "))")
            throw GitError.commandTimeout(arguments: arguments, timeout: actualTimeout)
        }
        
        process.waitUntilExit()
        timeoutTask.cancel()
        
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: stdoutData, encoding: .utf8) ?? ""
        let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            let fullOutput = errorOutput.isEmpty ? output : "\(output)\n\(errorOutput)"
            GitBrainLogger.error("Git command failed: \(arguments.joined(separator: " ")) with exit code: \(process.terminationStatus)")
            
            if shouldRetry(arguments: arguments, exitCode: process.terminationStatus) && retryCount < maxRetries {
                let delay = TimeInterval(retryCount + 1) * 5
                GitBrainLogger.warning("Retrying git command (attempt \(retryCount + 1)/\(maxRetries)) after \(delay)s delay")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await executeGitCommand(arguments, timeout: timeout, retryCount: retryCount + 1)
            }
            
            throw GitError.commandFailed(arguments: arguments, output: fullOutput, exitCode: process.terminationStatus)
        }
        
        GitBrainLogger.debug("Git command completed successfully")
        return output
    }
    
    private func shouldRetry(arguments: [String], exitCode: Int32) -> Bool {
        let networkCommands = ["push", "pull", "fetch", "clone"]
        let isNetworkCommand = networkCommands.contains { arguments.contains($0) }
        
        let transientErrorCodes: [Int32] = [128, 1]
        
        return isNetworkCommand && transientErrorCodes.contains(exitCode)
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
    case commandTimeout(arguments: [String], timeout: TimeInterval)
    case notAGitRepository
    case branchNotFound(String)
    case mergeConflict
    
    public var errorDescription: String? {
        switch self {
        case .commandFailed(let arguments, let output, let exitCode):
            return "Git command failed: \(arguments.joined(separator: " ")). Exit code: \(exitCode). Output: \(output). Please check the command and try again."
        case .commandTimeout(let arguments, let timeout):
            return "Git command timed out: \(arguments.joined(separator: " ")). Timeout: \(timeout)s. The operation took too long to complete. Try increasing the timeout or check for network issues."
        case .notAGitRepository:
            return "Not a git repository. Please initialize a git repository first using 'git init' or navigate to a valid git repository."
        case .branchNotFound(let branch):
            return "Branch not found: \(branch). Please verify the branch name exists locally or remotely. Use 'git branch -a' to list all branches."
        case .mergeConflict:
            return "Merge conflict detected. Please resolve the conflicts before proceeding. Use 'git status' to see conflicted files and 'git add' to mark them as resolved."
        }
    }
}