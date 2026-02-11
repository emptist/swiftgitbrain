# OverseerAI Review Guidelines

## Overview

This document outlines the review criteria and expectations for code submissions to OverseerAI.

## Project-Level Rules (Priority)

1. **Swift 6.2 Features**: Use latest Swift version features and syntax
2. **Protocol-Oriented Programming (POP)**: Use protocols extensively for abstraction and dependency injection
3. **Actor-Based Concurrency**: Use Swift actors for thread-safe state management
4. **Sendable Compliance**: All types passed across actor boundaries must conform to Sendable protocol
5. **TDD Approach**: Write tests before implementation using Swift Testing Framework
6. **English in Code**: Use English for all code and comments
7. **Privacy Protection**: Update .gitignore to exclude sensitive files
8. **Documentation**: Update documentation after completing tasks
9. **Code Consistency**: Follow existing code style and conventions

## Review Criteria

### Code Quality
- Follow Swift API Design Guidelines
- Use descriptive, camelCase names
- Proper access control (public for API, private for implementation)
- Clear comments for complex logic
- Proper error handling with Swift error types

### Architecture
- Protocol-oriented design with clear abstractions
- Actor-based concurrency for thread safety
- Sendable protocol compliance for cross-actor communication
- Separation of concerns
- Minimal use of Any type (prefer CodableAny)

### Testing
- Use Swift Testing Framework (not XCTest)
- High test coverage for critical paths
- Unit tests for individual components
- Integration tests for component interactions
- Tests written before implementation (TDD)

### Security
- No secrets or sensitive data in code
- Proper .gitignore for sensitive files
- Data protection measures
- Input validation

## Message Format

When submitting work for review, include:

```json
{
  "type": "code",
  "task_id": "task-001",
  "description": "Brief description of changes",
  "files": ["file1.swift", "file2.swift"],
  "changes": "Summary of what was changed",
  "test_results": "Test execution results"
}
```

## Review Response Types

### Approval
Code meets all standards and is approved.

### Review with Comments
Code has issues that need to be addressed:
- `error`: Must fix before approval
- `warning`: Should fix for best practices
- `suggestion`: Optional improvements
- `info`: Informational notes

### Rejection
Code has critical issues that prevent approval. Must resubmit after fixes.

## Common Issues to Avoid

1. **Missing Sendable Compliance**: Types passed across actors must be Sendable
2. **Improper Actor Usage**: State mutations must happen within actor boundaries
3. **Weak Testing**: Insufficient test coverage or missing tests
4. **Code Style Inconsistency**: Not following existing conventions
5. **Missing Documentation**: No comments for complex logic
6. **Security Issues**: Hardcoded secrets or sensitive data
7. **Breaking Changes**: Changes that break existing functionality

## Best Practices

1. **Before Submitting**:
   - Run `swift test` and ensure all tests pass
   - Run `swift build` to ensure clean build
   - Check for SwiftLint warnings (if configured)
   - Update documentation

2. **After Review**:
   - Address all review comments
   - Update tests if needed
   - Resubmit with clear description of changes
   - Reference previous review if resubmitting

3. **Communication**:
   - Be specific about what was changed
   - List all modified/created files
   - Provide context for changes
   - Ask questions if review comments are unclear

## Getting Started

1. Initialize GitBrain: `gitbrain init`
2. Create your implementation following TDD
3. Run tests: `swift test`
4. Submit for review using `gitbrain send overseer`
5. Wait for review response in GitBrain/Memory/
6. Address any issues and resubmit if needed

## Contact

If you have questions about review criteria or need clarification on feedback, please include a feedback message with your questions.