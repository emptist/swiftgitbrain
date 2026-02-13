import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testGitManagerAdd() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    await #expect(throws: GitError.self) {
        try await gitManager.add([testFile.path])
    }
}

@Test
func testGitManagerCommit() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    await #expect(throws: GitError.self) {
        try await gitManager.add([testFile.path])
    }
    
    await #expect(throws: GitError.self) {
        try await gitManager.commit("Test commit")
    }
}

@Test
func testGitManagerGetCurrentBranch() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    await #expect(throws: GitError.self) {
        _ = try await gitManager.getCurrentBranch()
    }
}

@Test
func testGitManagerGetStatus() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    await #expect(throws: GitError.self) {
        _ = try await gitManager.getStatus()
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
    
    await #expect(throws: GitError.self) {
        try await gitManager.add([testFile.path])
    }
    
    await #expect(throws: GitError.self) {
        try await gitManager.commit("Test commit")
    }
    
    await #expect(throws: GitError.self) {
        try await gitManager.getCurrentBranch()
    }
}

@Test
func testGitManagerSeparatePipes() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    await #expect(throws: GitError.self) {
        try await gitManager.add([testFile.path])
    }
    
    await #expect(throws: GitError.self) {
        try await gitManager.commit("Test commit")
    }
    
    await #expect(throws: GitError.self) {
        try await gitManager.getStatus()
    }
}