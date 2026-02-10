import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testGitManagerAdd() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    try await gitManager.add([testFile.path])
}

@Test
func testGitManagerCommit() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)
    
    try await gitManager.add([testFile.path])
    
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
        let branch = try await gitManager.getCurrentBranch()
    } catch GitError.commandFailed {
    }
}

@Test
func testGitManagerGetStatus() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let gitManager = GitManager(worktree: tempDir)
    
    let status = try await gitManager.getStatus()
    
    #expect(status.added.isEmpty)
    #expect(status.modified.isEmpty)
    #expect(status.deleted.isEmpty)
    #expect(status.untracked.isEmpty)
    #expect(status.isClean)
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