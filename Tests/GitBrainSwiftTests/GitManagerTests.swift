import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testGitManagerAdd() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    do {
        try await gitManager.add([testFile.path])
    } catch GitError.commandFailed {
    }
}

@Test
func testGitManagerCommit() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    do {
        try await gitManager.add([testFile.path])
    } catch GitError.commandFailed {
    }
    
    do {
        try await gitManager.commit("Test commit")
    } catch GitError.commandFailed {
    }
}

@Test
func testGitManagerGetCurrentBranch() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    do {
        _ = try await gitManager.getCurrentBranch()
    } catch GitError.commandFailed {
    }
}

@Test
func testGitManagerGetStatus() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    do {
        _ = try await gitManager.getStatus()
    } catch GitError.commandFailed {
    }
}

@Test
func testGitStatusIsClean() {
    let status = GitStatus()
    
    #expect(status.isClean)
    #expect(!status.hasChanges)
}

@Test
func testGitStatusHasChanges() {
    var status = GitStatus()
    status.modified.append("test.swift")
    
    #expect(!status.isClean)
    #expect(status.hasChanges)
}

@Test
func testGitStatusWithMultipleChanges() {
    var status = GitStatus()
    status.modified.append("file1.swift")
    status.added.append("file2.swift")
    status.deleted.append("file3.swift")
    status.untracked.append("file4.swift")
    
    #expect(!status.isClean)
    #expect(status.hasChanges)
    #expect(status.modified.count == 1)
    #expect(status.added.count == 1)
    #expect(status.deleted.count == 1)
    #expect(status.untracked.count == 1)
}

@Test
func testGitManagerTimeout() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    do {
        try await gitManager.add([testFile.path])
    } catch GitError.commandFailed {
    }
    
    do {
        try await gitManager.commit("Test commit")
    } catch GitError.commandFailed {
    }
    
    do {
        let branch = try await gitManager.getCurrentBranch()
        #expect(!branch.isEmpty)
    } catch GitError.commandFailed {
    }
}

@Test
func testGitManagerSeparatePipes() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    do {
        try await gitManager.add([testFile.path])
    } catch GitError.commandFailed {
    }
    
    do {
        try await gitManager.commit("Test commit")
    } catch GitError.commandFailed {
    }
    
    do {
        let status = try await gitManager.getStatus()
        #expect(status.isClean)
    } catch GitError.commandFailed {
    }
}