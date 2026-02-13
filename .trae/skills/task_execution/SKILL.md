# Task Execution Skill

## Description

This skill enables AI agents to autonomously execute development tasks following established patterns and best practices.

## When to Use

- When implementing features or bug fixes
- When writing code following a plan
- When making changes to existing code
- When creating new components or modules

## Execution Process

### Step 1: Prepare for Execution

Before writing any code:

1. **Review Plan**: Check task requirements and acceptance criteria
2. **Research Patterns**: Search GitBrain for similar implementations
3. **Understand Context**: Read related code and documentation
4. **Identify Dependencies**: What needs to be imported or referenced
5. **Set Up Environment**: Ensure tools and dependencies are available

### Step 2: Implement Solution

Write code following best practices:

1. **Follow Patterns**: Use established patterns from GitBrain
2. **Write Clean Code**: Clear, readable, and maintainable
3. **Add Comments**: Explain complex logic (but not obvious code)
4. **Handle Errors**: Proper error handling and edge cases
5. **Consider Performance**: Optimize for efficiency when needed

### Step 3: Write Tests

Ensure quality with comprehensive tests:

1. **Unit Tests**: Test individual components
2. **Integration Tests**: Test component interactions
3. **Edge Cases**: Test boundary conditions
4. **Error Cases**: Test error handling
5. **Use Mock Repositories**: Test without database dependencies

### Step 4: Validate Implementation

Verify correctness before marking complete:

1. **Run Tests**: All tests must pass
2. **Check Style**: Follow project conventions
3. **Review Code**: Self-review for issues
4. **Verify Requirements**: All acceptance criteria met
5. **Test Manually**: Verify functionality works as expected

### Step 5: Update Knowledge

Store learnings for future reference:

1. **Document Decisions**: Why this approach was chosen
2. **Note Patterns**: What patterns were used successfully
3. **Record Issues**: What problems were encountered
4. **Share Solutions**: How issues were resolved

## Output Format

### Code Implementation

Follow project conventions:

```swift
import Foundation

public class NewComponent {
    private let dependency: DependencyProtocol
    
    public init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
    
    public func performAction() async throws -> Result {
        try await dependency.execute()
        return Result.success
    }
}
```

### Test Implementation

Use Swift Testing framework:

```swift
import Testing
@testable import GitBrainSwift

@Suite("NewComponent Tests")
struct NewComponentTests {
    @Test("Perform action successfully")
    func testPerformAction() async throws {
        let mockDependency = MockDependency()
        let component = NewComponent(dependency: mockDependency)
        
        let result = try await component.performAction()
        
        #expect(result == .success)
    }
}
```

### Status Update

Report progress during and after execution:

```json
{
  "id": "status_update_<timestamp>",
  "from": "CoderAI",
  "to": "OverseerAI",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "status_update",
  "content": {
    "status": "in_progress",
    "message": "Implementing <feature name>",
    "details": {
      "task_id": "<task_id>",
      "progress": "50%",
      "files_modified": [
        "Sources/GitBrainSwift/NewComponent.swift",
        "Tests/GitBrainSwiftTests/NewComponentTests.swift"
      ],
      "issues": [],
      "next_steps": [
        "Complete implementation",
        "Run tests",
        "Submit for review"
      ]
    }
  }
}
```

## Best Practices

### Code Quality
1. **Follow MVVM**: Use Model-View-ViewModel pattern
2. **Use Protocols**: Protocol-oriented programming for abstraction
3. **Leverage Actors**: Use Swift actors for thread-safety
4. **Sendable Compliance**: Ensure types are Sendable across actor boundaries
5. **Type Safety**: Strong typing, minimal use of `Any`

### Testing
1. **Test First**: Write tests before implementation (TDD)
2. **Test Isolation**: Each test should be independent
3. **Mock Dependencies**: Use mock repositories for isolation
4. **Cover Edge Cases**: Test boundary conditions
5. **Test Errors**: Verify error handling works

### Documentation
1. **Clear Names**: Use descriptive, camelCase names
2. **Access Control**: `public` for API, `private` for implementation
3. **Complex Logic**: Add comments for non-obvious code
4. **API Documentation**: Document public interfaces
5. **Examples**: Provide usage examples

### Error Handling
1. **Use Swift Errors**: Proper error types and messages
2. **Handle Gracefully**: Don't crash, handle errors appropriately
3. **Provide Context**: Include helpful error messages
4. **Log Errors**: Use GitBrainLogger for debugging
5. **Propagate Errors**: Let callers handle when appropriate

## Integration with GitBrain

### Before Execution
1. **Search KnowledgeBase**: Look for similar implementations
2. **Check BrainStateManager**: Review previous decisions
3. **Identify Patterns**: Note successful approaches

### During Execution
1. **Update TodoWrite**: Track progress on tasks
2. **Send Status Updates**: Report every 5-10 minutes
3. **Log Decisions**: Note why certain approaches were chosen

### After Execution
1. **Store Patterns**: Save successful approaches
2. **Document Learnings**: What worked and what didn't
3. **Update BrainState**: Record completion and insights

## Common Patterns

### Repository Pattern
```swift
public protocol SomeRepositoryProtocol {
    func add(item: Item) async throws
    func get(id: ID) async throws -> Item?
    func update(item: Item) async throws -> Bool
    func delete(id: ID) async throws -> Bool
}

public actor SomeRepository: SomeRepositoryProtocol {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func add(item: Item) async throws {
        try await item.save(on: database)
    }
}
```

### Actor Pattern
```swift
public actor SomeManager {
    private var state: State
    
    public init(initialState: State) {
        self.state = initialState
    }
    
    public func updateState(newState: State) {
        self.state = newState
    }
}
```

### Sendable Pattern
```swift
public struct SomeData: Sendable {
    public let id: String
    public let value: String
    public let timestamp: Date
}
```

## Troubleshooting

### Compilation Errors
1. **Read Error Message**: Understand what's wrong
2. **Check Imports**: Ensure all dependencies are imported
3. **Verify Types**: Check type annotations match
4. **Review Syntax**: Check for typos or missing braces
5. **Search GitBrain**: Look for similar issues

### Test Failures
1. **Read Test Output**: Understand what failed
2. **Debug**: Add print statements or use debugger
3. **Check Assertions**: Verify expectations are correct
4. **Review Code**: Look for logic errors
5. **Fix and Re-run**: Iterate until tests pass

### Runtime Errors
1. **Check Logs**: Review GitBrainLogger output
2. **Validate Inputs**: Ensure data is correct
3. **Handle Nil**: Check for force unwrapping
4. **Review Async**: Check for race conditions
5. **Test Edge Cases**: Verify boundary conditions

## Example

### Task
"Implement a caching layer for knowledge repository to improve performance"

### Execution

1. **Research**: Search GitBrain for caching patterns
2. **Design**: Create CacheProtocol and implementation
3. **Implement**: Write cache with expiration
4. **Test**: Write comprehensive tests
5. **Validate**: Run tests and verify performance
6. **Document**: Update API documentation
7. **Store**: Save pattern in KnowledgeBase

## Related Skills

- **Development Planning**: Create task breakdowns
- **Code Review**: Validate implementation
- **Testing**: Write and run tests
- **Documentation**: Document implementation