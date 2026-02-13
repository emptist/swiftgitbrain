# Documentation Generation Skill

## Description

This skill enables AI agents to autonomously generate and maintain documentation following project standards and best practices.

## When to Use

- After implementing new features or components
- When updating existing documentation
- When creating API documentation
- When writing usage examples or guides
- When documenting architectural decisions

## Documentation Types

### 1. API Documentation
Document public interfaces and usage:

```markdown
## ComponentName

Brief description of what this component does.

### Initialization

```swift
let component = ComponentName(parameter: value)
```

**Parameters:**
- `parameter: Type` - Description of parameter

### Methods

#### methodName()

Brief description of what method does.

```swift
component.methodName()
```

**Returns:** Type - Description of return value

**Throws:** ErrorType - When this error is thrown
```

### 2. Architecture Documentation
Document system design and decisions:

```markdown
# Architecture Decision: <Title>

## Context
What problem are we solving?

## Decision
What approach did we choose?

## Alternatives Considered
1. Alternative 1 - Pros/Cons
2. Alternative 2 - Pros/Cons

## Consequences
What are the implications of this decision?

## References
- Links to related documentation
- Links to similar decisions
```

### 3. Usage Guides
Document how to use features:

```markdown
# Feature Name Guide

## Quick Start

```swift
import GitBrainSwift

let manager = Manager()
try await manager.performAction()
```

## Common Use Cases

### Use Case 1: Description

```swift
// Example code
```

### Use Case 2: Description

```swift
// Example code
```

## Best Practices

1. Practice 1
2. Practice 2

## Troubleshooting

### Issue: Description

**Solution:** How to fix it
```

### 4. Migration Guides
Document how to upgrade or migrate:

```markdown
# Migration Guide: From v1.0 to v2.0

## Breaking Changes

List of breaking changes.

## Migration Steps

1. Step 1
2. Step 2

## Rollback

How to rollback if needed.

## Testing

How to test migration.
```

## Documentation Process

### Step 1: Analyze What Needs Documentation

1. **New Feature**: Document API, usage, and examples
2. **Changed Feature**: Update affected documentation
3. **Bug Fix**: Document behavior change
4. **Architecture**: Document decision and rationale
5. **Migration**: Create upgrade guide

### Step 2: Determine Documentation Type

Based on what was changed:

1. **Public API**: API documentation required
2. **Internal Change**: Architecture documentation
3. **User-Facing**: Usage guide needed
4. **Breaking Change**: Migration guide required

### Step 3: Generate Documentation

Follow templates and standards:

1. **Use Markdown**: Standard format for all docs
2. **Include Examples**: Code samples for usage
3. **Be Clear**: Simple, concise language
4. **Be Complete**: Cover all aspects
5. **Be Accurate**: Verify against implementation

### Step 4: Review and Validate

Ensure quality:

1. **Test Examples**: All code samples work
2. **Check Links**: All links are valid
3. **Verify Accuracy**: Documentation matches code
4. **Read for Clarity**: Easy to understand
5. **Check Completeness**: Nothing important missing

### Step 5: Update References

Keep documentation in sync:

1. **Update README**: Add new features to main doc
2. **Update Table of Contents**: Add new sections
3. **Cross-Reference**: Link related docs
4. **Update Index**: Add to documentation index

## Documentation Templates

### API Documentation Template

```markdown
# <ComponentName>

<Brief description of component>

## Overview

<Detailed description of what this component does and when to use it>

## Requirements

<Prerequisites or dependencies>

## Initialization

```swift
<Example initialization code>
```

**Parameters:**
- `parameter1: Type` - Description
- `parameter2: Type` - Description

## Public API

### Methods

#### methodName1(parameter1: Type, parameter2: Type) async throws -> ReturnType

<Description of what method does>

**Parameters:**
- `parameter1: Type` - Description
- `parameter2: Type` - Description

**Returns:** ReturnType - Description

**Throws:** ErrorType - When this error is thrown

**Example:**
```swift
<Example usage>
```

#### methodName2() async -> Result

<Description>

**Returns:** Result - Description

**Example:**
```swift
<Example usage>
```

## Usage Examples

### Example 1: <Description>

```swift
<Complete example>
```

### Example 2: <Description>

```swift
<Complete example>
```

## Error Handling

<Description of errors that can occur and how to handle them>

## Performance Considerations

<Performance characteristics and optimization tips>

## Thread Safety

<Information about thread safety and concurrency>

## See Also

- [RelatedComponent](link)
- [RelatedDocumentation](link)
```

### Architecture Decision Template

```markdown
# ADR-<number>: <Title>

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
<What is the problem we're trying to solve?>

## Decision
<What approach did we choose and why?>

## Alternatives Considered

### Alternative 1: <Name>
**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

### Alternative 2: <Name>
**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

## Consequences

### Positive
- Benefit 1
- Benefit 2

### Negative
- Drawback 1
- Drawback 2

### Risks
- Risk 1
- Risk 2

## References
- [Link 1](url)
- [Link 2](url)
- [Related ADR](link)
```

### Migration Guide Template

```markdown
# Migration Guide: From <OldVersion> to <NewVersion>

## Overview

<Summary of what's new and why migration is needed>

## Breaking Changes

### Change 1: <Description>

**Before:**
```swift
<Old code>
```

**After:**
```swift
<New code>
```

### Change 2: <Description>

<Description and code examples>

## Migration Steps

### Step 1: <Description>

<Instructions>

### Step 2: <Description>

<Instructions>

### Step 3: <Description>

<Instructions>

## Rollback

<How to rollback to previous version if needed>

## Testing

<How to verify migration was successful>

## Support

<Where to get help if issues arise>
```

## Best Practices

### Writing Style
1. **Be Concise**: Get to the point quickly
2. **Be Clear**: Use simple, direct language
3. **Be Complete**: Cover all important aspects
4. **Be Accurate**: Verify against implementation
5. **Be Consistent**: Follow established patterns

### Code Examples
1. **Test Them**: All examples must work
2. **Be Realistic**: Show practical usage
3. **Be Complete**: Include necessary imports and setup
4. **Be Clear**: Explain what the example does
5. **Be Relevant**: Show common use cases

### Organization
1. **Use Headings**: Clear structure with H1-H6
2. **Use Lists**: Bullet points for readability
3. **Use Code Blocks**: Format code properly
4. **Use Links**: Cross-reference related docs
5. **Use Tables**: For structured data

### Maintenance
1. **Update Early**: Don't let docs get stale
2. **Review Regularly**: Check for accuracy
3. **Remove Outdated**: Delete obsolete information
4. **Add Examples**: As new use cases emerge
5. **Fix Errors**: Correct mistakes immediately

## Integration with GitBrain

### Before Writing
1. **Search KnowledgeBase**: Look for similar documentation
2. **Check Patterns**: Follow established documentation style
3. **Identify Standards**: What format is expected

### While Writing
1. **Update TodoWrite**: Track documentation tasks
2. **Send Status Updates**: Report progress
3. **Store Decisions**: Note why certain approaches were chosen

### After Writing
1. **Store Patterns**: Save successful documentation patterns
2. **Update BrainState**: Record completion
3. **Share Learnings**: What worked and what didn't

## Example

### Task
"Document the new caching layer for knowledge repository"

### Documentation Generated

```markdown
# Cache Layer

The cache layer provides in-memory caching for knowledge repository operations to improve performance.

## Overview

The cache layer sits between the application and the repository, storing frequently accessed data in memory. This reduces database queries and improves response times for read-heavy workloads.

## Requirements

- Swift 6.2
- GitBrainSwift 1.0+

## Initialization

```swift
import GitBrainSwift

let repository = try await dbManager.createKnowledgeRepository()
let cache = CacheLayer(repository: repository, ttl: 300)
let cachedRepository = CachedKnowledgeRepository(cache: cache)
```

**Parameters:**
- `repository: KnowledgeRepositoryProtocol` - The underlying repository
- `ttl: TimeInterval` - Time-to-live for cache entries in seconds

## Public API

### get(category:key:) async throws -> SendableContent?

Retrieve a knowledge item, using cache if available.

**Parameters:**
- `category: String` - Knowledge category
- `key: String` - Knowledge key

**Returns:** SendableContent? - The knowledge item or nil

**Example:**
```swift
if let item = try await cachedRepository.get(category: "swift", key: "basics") {
    print("Found cached item")
}
```

## Performance

Cache hit rate typically exceeds 80% for read-heavy workloads, reducing database queries by 4-5x.

## Thread Safety

The cache layer uses Swift actors for thread-safe access.

## See Also

- [KnowledgeRepositoryProtocol](../API.md#knowledgerepositoryprotocol)
- [Performance Optimization Guide](../Performance.md)
```

## Related Skills

- **Task Execution**: Generate docs after implementation
- **Code Review**: Validate documentation accuracy
- **Development Planning**: Plan documentation tasks