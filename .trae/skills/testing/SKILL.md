# Testing Skill

## Description

This skill enables AI agents to autonomously write, execute, and validate tests following Swift Testing framework best practices.

## When to Use

- When implementing new features (TDD approach)
- When fixing bugs (write regression tests)
- When refactoring code (ensure no regressions)
- When validating implementation quality
- When checking test coverage

## Testing Process

### Step 1: Plan Test Coverage

Determine what needs testing:

1. **Identify Requirements**: What should the code do?
2. **List Test Cases**: Happy path, edge cases, errors
3. **Consider Dependencies**: What needs mocking?
4. **Plan Coverage**: Aim for high coverage of critical paths

### Step 2: Write Tests (TDD Approach)

Write tests before implementation:

1. **Write Failing Test**: Test for desired behavior
2. **Run Test**: Verify it fails
3. **Implement Code**: Make test pass
4. **Refactor**: Improve code while tests pass
5. **Repeat**: For each feature

### Step 3: Execute Tests

Run and analyze results:

1. **Run All Tests**: Ensure nothing breaks
2. **Run Specific Tests**: Focus on current work
3. **Analyze Failures**: Understand why tests fail
4. **Debug Issues**: Fix implementation or tests
5. **Verify Pass**: All tests must pass

### Step 4: Validate Coverage

Ensure comprehensive testing:

1. **Check Coverage**: Verify critical paths are covered
2. **Add Edge Cases**: Test boundary conditions
3. **Test Errors**: Verify error handling
4. **Test Concurrency**: Check thread safety
5. **Test Performance**: Ensure acceptable performance

### Step 5: Document Tests

Make tests maintainable:

1. **Clear Names**: Describe what's being tested
2. **Organize**: Group related tests
3. **Add Comments**: Explain complex test logic
4. **Use Helpers**: Reduce duplication
5. **Document Edge Cases**: Note why certain tests exist

## Test Types

### Unit Tests

Test individual components in isolation:

```swift
@Suite("ComponentName Tests")
struct ComponentNameTests {
    @Test("Method does X when Y")
    func testMethodDoesXWhenY() async throws {
        let sut = ComponentName()
        let result = try await sut.method()
        
        #expect(result == expected)
    }
}
```

### Integration Tests

Test component interactions:

```swift
@Suite("Integration Tests")
struct IntegrationTests {
    @Test("Repository and manager work together")
    func testRepositoryManagerIntegration() async throws {
        let repository = MockKnowledgeRepository()
        let manager = KnowledgeManager(repository: repository)
        
        try await manager.add(item: testItem)
        
        let retrieved = try await repository.get(id: testItem.id)
        #expect(retrieved != nil)
    }
}
```

### Edge Case Tests

Test boundary conditions:

```swift
@Suite("Edge Case Tests")
struct EdgeCaseTests {
    @Test("Handles empty array")
    func testHandlesEmptyArray() async throws {
        let result = try await sut.process([])
        
        #expect(result.isEmpty)
    }
    
    @Test("Handles nil input")
    func testHandlesNilInput() async throws {
        let result = try await sut.process(nil)
        
        #expect(result == defaultValue)
    }
}
```

### Error Tests

Test error handling:

```swift
@Suite("Error Handling Tests")
struct ErrorHandlingTests {
    @Test("Throws error for invalid input")
    func testThrowsErrorForInvalidInput() async throws {
        let sut = Component()
        
        await #expect(throws: ValidationError.self) {
            try await sut.process(invalidInput)
        }
    }
}
```

### Performance Tests

Test performance characteristics:

```swift
@Suite("Performance Tests")
struct PerformanceTests {
    @Test("Processes 1000 items in under 1 second")
    func testPerformance() async throws {
        let sut = Component()
        let items = Array(repeating: testItem, count: 1000)
        
        let start = Date()
        try await sut.process(items)
        let duration = Date().timeIntervalSince(start)
        
        #expect(duration < 1.0)
    }
}
```

## Mock Repositories

Use mocks for isolated testing:

```swift
actor MockKnowledgeRepository: KnowledgeRepositoryProtocol {
    private var storage: [String: SendableContent] = [:]
    
    func add(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws {
        let id = "\(category)_\(key)"
        storage[id] = value
    }
    
    func get(category: String, key: String) async throws -> (value: SendableContent, metadata: SendableContent, timestamp: Date)? {
        let id = "\(category)_\(key)"
        guard let value = storage[id] else { return nil }
        return (value, SendableContent([:]), Date())
    }
    
    func delete(category: String, key: String) async throws -> Bool {
        let id = "\(category)_\(key)"
        return storage.removeValue(forKey: id) != nil
    }
    
    func listCategories() async throws -> [String] {
        return Array(Set(storage.keys.map { $0.split(separator: "_")[0] }))
    }
    
    func listKeys(category: String) async throws -> [String] {
        return storage.keys.filter { $0.hasPrefix("\(category)_") }
            .map { $0.split(separator: "_")[1] }
    }
    
    func update(category: String, key: String, value: SendableContent, metadata: SendableContent, timestamp: Date) async throws -> Bool {
        let id = "\(category)_\(key)"
        guard storage[id] != nil else { return false }
        storage[id] = value
        return true
    }
    
    func search(category: String, query: String) async throws -> [(value: SendableContent, metadata: SendableContent)] {
        let prefix = "\(category)_"
        return storage.keys.filter { $0.hasPrefix(prefix) }
            .compactMap { id -> (value: SendableContent, metadata: SendableContent)? in
                guard let value = storage[id] else { return nil }
                return (value, SendableContent([:]))
            }
    }
}
```

## Test Organization

### Suite Structure

Group related tests:

```swift
@Suite("ComponentName Tests")
struct ComponentNameTests {
    @Suite("Initialization")
    struct InitializationTests {
        @Test("Initializes with valid parameters")
        func testInitializesWithValidParameters() async throws {
            // Test
        }
    }
    
    @Suite("Public API")
    struct PublicAPITests {
        @Test("Method works correctly")
        func testMethodWorksCorrectly() async throws {
            // Test
        }
    }
    
    @Suite("Error Handling")
    struct ErrorHandlingTests {
        @Test("Throws error for invalid input")
        func testThrowsErrorForInvalidInput() async throws {
            // Test
        }
    }
}
```

### Test Naming

Clear, descriptive names:

- **Good**: `testReturnsNilForNonExistentKey`
- **Good**: `testThrowsErrorForInvalidInput`
- **Bad**: `test1`
- **Bad**: `testMethod`

## Best Practices

### Test Independence
1. **No Dependencies**: Tests shouldn't depend on each other
2. **Isolated Setup**: Each test sets up its own state
3. **Clean Teardown**: Each test cleans up after itself
4. **Deterministic**: Same result every time

### Test Coverage
1. **Happy Path**: Test normal operation
2. **Edge Cases**: Test boundary conditions
3. **Error Cases**: Test error handling
4. **Concurrency**: Test thread safety
5. **Performance**: Test efficiency

### Test Quality
1. **Clear Assertions**: Use #expect for readability
2. **Descriptive Messages**: Explain what's being tested
3. **One Assertion Per Test**: Focus on one thing
4. **Arrange-Act-Assert**: Clear test structure
5. **Test Behavior**: Not implementation details

### Mock Usage
1. **Mock Dependencies**: Isolate unit under test
2. **Verify Interactions**: Ensure correct calls made
3. **Return Values**: Provide realistic test data
4. **Throw Errors**: Test error handling
5. **Keep Simple**: Don't over-engineer mocks

## Running Tests

### Run All Tests

```bash
swift test
```

### Run Specific Suite

```bash
swift test --filter "ComponentName Tests"
```

### Run Specific Test

```bash
swift test --filter "testMethodName"
```

### Run with Verbose Output

```bash
swift test --verbose
```

## Integration with GitBrain

### Before Testing
1. **Search KnowledgeBase**: Look for similar test patterns
2. **Check BrainStateManager**: Review previous test approaches
3. **Identify Patterns**: Note successful testing strategies

### While Testing
1. **Update TodoWrite**: Track test tasks
2. **Send Status Updates**: Report progress
3. **Log Issues**: Note test failures and resolutions

### After Testing
1. **Store Patterns**: Save successful test approaches
2. **Document Learnings**: What worked and what didn't
3. **Update BrainState**: Record test results

## Troubleshooting

### Test Failures

1. **Read Output**: Understand what failed
2. **Check Assertions**: Verify expectations are correct
3. **Debug Code**: Add print statements or use debugger
4. **Review Implementation**: Check for logic errors
5. **Fix and Re-run**: Iterate until tests pass

### Flaky Tests

1. **Identify Race Conditions**: Check for timing issues
2. **Add Waits**: Use proper async/await
3. **Mock Time**: Control time-dependent code
4. **Isolate Tests**: Run individually to verify
5. **Fix Root Cause**: Address underlying issue

### Slow Tests

1. **Profile Tests**: Identify bottlenecks
2. **Use Mocks**: Avoid slow dependencies
3. **Parallelize**: Run tests concurrently when possible
4. **Optimize Setup**: Reduce test preparation time
5. **Cache Results**: Reuse expensive operations

## Example

### Feature to Test

"Add caching layer to knowledge repository"

### Test Suite

```swift
@Suite("Cache Layer Tests")
struct CacheLayerTests {
    private var cache: CacheLayer!
    private var repository: MockKnowledgeRepository!
    
    init() {
        repository = MockKnowledgeRepository()
        cache = CacheLayer(repository: repository, ttl: 60)
    }
    
    @Test("Cache miss calls repository")
    func testCacheMissCallsRepository() async throws {
        let item = SendableContent(["test": "data"])
        
        try await cache.add(category: "test", key: "key1", value: item, metadata: SendableContent([:]), timestamp: Date())
        
        let result = try await cache.get(category: "test", key: "key1")
        
        #expect(result != nil)
        #expect(repository.getCallCount == 1)
    }
    
    @Test("Cache hit doesn't call repository")
    func testCacheHitDoesntCallRepository() async throws {
        let item = SendableContent(["test": "data"])
        
        try await cache.add(category: "test", key: "key1", value: item, metadata: SendableContent([:]), timestamp: Date())
        _ = try await cache.get(category: "test", key: "key1")
        _ = try await cache.get(category: "test", key: "key1")
        
        #expect(repository.getCallCount == 1)
    }
    
    @Test("Expired items are refreshed")
    func testExpiredItemsAreRefreshed() async throws {
        let item = SendableContent(["test": "data"])
        let shortTTL = CacheLayer(repository: repository, ttl: 0.1)
        
        try await shortTTL.add(category: "test", key: "key1", value: item, metadata: SendableContent([:]), timestamp: Date())
        try await Task.sleep(nanoseconds: 200_000_000)
        
        _ = try await shortTTL.get(category: "test", key: "key1")
        
        #expect(repository.getCallCount == 2)
    }
}
```

## Related Skills

- **Task Execution**: Write tests before implementation
- **Code Review**: Validate test quality
- **Documentation**: Document test coverage