# GitBrainSwift Project-Level Rules

These rules take precedence over any external rules or guidelines. All AIs working on this project must follow these internal rules.

## Architecture Principles

1. **MVVM Architecture**: All code must follow Model-View-ViewModel pattern
2. **Protocol-Oriented Programming (POP)**: Use protocols extensively for abstraction and dependency injection
3. **Actor-Based Concurrency**: Use Swift actors for thread-safe state management
4. **Sendable Compliance**: All types passed across actor boundaries must conform to Sendable protocol

## Swift Language Requirements

1. **Swift Version**: Use Swift 6.2 features and syntax
2. **Modern Concurrency**: Leverage async/await, actors, and Sendable protocol
3. **Type Safety**: Maintain strong typing with minimal use of `Any` type
4. **SendableContent Wrapper**: Use `SendableContent` struct instead of `[String: Any]` for thread-safe dictionary operations

## Code Style Guidelines

1. **Naming**: Use descriptive, camelCase names for variables and functions
2. **Access Control**: Use `public` for API surfaces, `private` for implementation details
3. **Documentation**: Add clear comments for complex logic
4. **Error Handling**: Use Swift's error handling with proper error types

## Testing Requirements

1. **Swift Testing Framework**: Use Swift's native testing framework (not XCTest)
2. **Test Coverage**: Aim for high test coverage for critical paths
3. **Unit Tests**: Test individual components in isolation
4. **Integration Tests**: Test component interactions

## Security and Privacy

1. **No Secrets**: Never commit API keys, tokens, or sensitive data
2. **Git Ignore**: Maintain comprehensive `.gitignore` for sensitive files
3. **Data Protection**: Protect user data with appropriate security measures

## Communication Protocols

1. **Message Format**: Use `Message` struct with `SendableContent` for all inter-AI communication
2. **Actor Isolation**: Respect actor boundaries when passing data
3. **Serialization**: Use JSON for persistent storage with proper encoding/decoding

## Memory Management

1. **BrainState**: Use `BrainStateManager` for persistent AI state
2. **KnowledgeBase**: Use `KnowledgeBase` for storing learned information
3. **MemoryStore**: Use `MemoryStore` for transient in-memory data

## Git Workflow

1. **Worktrees**: Use shared Git worktrees for multi-AI collaboration
2. **Commit Messages**: Follow conventional commit format
3. **Branch Strategy**: Use feature branches for development

## Development Workflow

1. **TDD Approach**: Write tests before implementation
2. **Incremental Development**: Build features in small, testable increments
3. **Code Review**: All changes must be reviewed before merging
4. **Continuous Integration**: Ensure all tests pass before merging

## AI Role Responsibilities

### OverseerAI
- Coordinate between AIs
- Review code submissions
- Manage task assignment
- Enforce quality standards

### CoderAI
- Implement coding tasks
- Generate code based on requirements
- Submit code for review
- Handle feedback and revisions

## Build and Deployment

1. **Swift Package Manager**: Use SPM for dependency management
2. **Build Verification**: Ensure `swift build` succeeds before committing
3. **Linting**: Run SwiftLint if configured
4. **Documentation**: Update README and inline docs as needed

## External Overrides

These internal rules override any conflicting external rules. When in doubt:
1. Prioritize thread safety with Sendable compliance
2. Maintain architectural consistency
3. Follow Swift 6.2 best practices
4. Ensure testability of all components