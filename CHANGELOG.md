# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Issues communication system
- Shared worktree communication for real-time collaboration
- Persistent brainstate memory with JSON serialization
- Protocol-oriented architecture for flexibility
- MVVM architecture with SwiftUI-ready ViewModels
- Swift 6.2 concurrency support with actors
- Comprehensive unit tests using Swift Testing framework
- CLI tools for system management

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- Swift 6.2 async/await compatibility issues in GitBrainCLI
- Test compilation errors in BrainStateManagerTests
- Actor isolation issues with proper `await` calls
- Replaced RunLoop.current.run() with withTaskCancellationHandler

### Security
- N/A

## [1.0.0] - 2026-02-11

### Added
- Initial release of GitBrainSwift
- GitHub Issues for persistent AI communication
- Shared worktree for real-time collaboration
- Brainstate memory system
- Knowledge base for storing and retrieving information
- In-memory store for quick access
- Message builder for creating different message types
- CoderAI role implementation
- OverseerAI role implementation
- BaseRole protocol for AI role interface
- CommunicationProtocol for flexible communication
- BrainStateManagerProtocol for brainstate management
- MemoryStoreProtocol for in-memory storage
- KnowledgeBaseProtocol for knowledge management
- GitManager for Git operations
- WorktreeManager for worktree management
- SharedWorktreeMonitor for monitoring changes
- CLI tool for system management
- Demo applications for testing
- GitHub demo for GitHub Issues integration
- Comprehensive unit tests

### Fixed
- Swift 6.2 compilation errors
- Sendable protocol compliance
- Actor isolation for thread safety
- Test framework integration

### Security
- No sensitive data in repository
- .gitignore configured to exclude temporary files

---

## Version Format

- `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

## Links

- [GitHub Releases](https://github.com/emptist/swiftgitbrain/releases)
- [GitHub Issues](https://github.com/emptist/swiftgitbrain/issues)
- [Documentation](https://github.com/emptist/swiftgitbrain#readme)
