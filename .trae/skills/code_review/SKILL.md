# Code Review Skill

## Description

This skill enables AI agents to autonomously review code for quality, correctness, and adherence to project standards.

## When to Use

- Before submitting code for review
- When reviewing another AI's code
- When validating implementation quality
- When ensuring code follows patterns

## Review Process

### Step 1: Understand Context

Before reviewing code:

1. **Read Task Requirements**: What was the code supposed to do?
2. **Review Design**: What approach was chosen?
3. **Check Patterns**: Does code follow established patterns?
4. **Understand Constraints**: What limitations or requirements exist?

### Step 2: Code Quality Review

Check code quality aspects:

1. **Naming**: Are names clear and descriptive?
2. **Structure**: Is code well-organized?
3. **Readability**: Is code easy to understand?
4. **Complexity**: Is code overly complex?
5. **Comments**: Are complex parts explained?

### Step 3: Correctness Review

Verify correctness:

1. **Logic**: Does code do what it's supposed to?
2. **Edge Cases**: Are edge cases handled?
3. **Error Handling**: Are errors properly handled?
4. **Thread Safety**: Is code thread-safe?
5. **Performance**: Is code efficient?

### Step 4: Standards Compliance

Check adherence to standards:

1. **MVVM**: Does code follow MVVM pattern?
2. **Protocols**: Are protocols used appropriately?
3. **Actors**: Are actors used for thread-safety?
4. **Sendable**: Do types conform to Sendable?
5. **Testing**: Are tests comprehensive?

### Step 5: Provide Feedback

Give constructive feedback:

1. **Be Specific**: Point to exact issues
2. **Be Constructive**: Suggest improvements
3. **Be Positive**: Acknowledge good work
4. **Be Prioritized**: Order issues by importance
5. **Be Actionable**: Provide clear next steps

## Review Checklist

### Code Quality
- [ ] Names are clear and descriptive
- [ ] Code is well-organized
- [ ] Code is easy to read
- [ ] Complexity is appropriate
- [ ] Comments explain complex logic

### Correctness
- [ ] Logic is correct
- [ ] Edge cases are handled
- [ ] Errors are properly handled
- [ ] Thread safety is maintained
- [ ] Performance is acceptable

### Standards Compliance
- [ ] MVVM pattern is followed
- [ ] Protocols are used appropriately
- [ ] Actors are used for thread-safety
- [ ] Sendable protocol is conformed to
- [ ] Tests are comprehensive

### Testing
- [ ] Unit tests cover functionality
- [ ] Integration tests exist
- [ ] Edge cases are tested
- [ ] Error cases are tested
- [ ] Tests are passing

## Feedback Format

### Approval

```json
{
  "review_id": "review_<timestamp>",
  "from": "ReviewerAI",
  "to": "Creator",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "code_review",
  "content": {
    "status": "approved",
    "message": "Code review passed - implementation is correct and follows standards",
    "details": {
      "files_reviewed": [
        "Sources/GitBrainSwift/Component.swift",
        "Tests/GitBrainSwiftTests/ComponentTests.swift"
      ],
      "strengths": [
        "Clear and readable code",
        "Comprehensive test coverage",
        "Proper use of protocols",
        "Thread-safe implementation"
      ],
      "suggestions": [],
      "next_steps": [
        "Merge changes",
        "Update documentation",
        "Continue with next task"
      ]
    }
  }
}
```

### Changes Requested

```json
{
  "review_id": "review_<timestamp>",
  "from": "ReviewerAI",
  "to": "Creator",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "code_review",
  "content": {
    "status": "changes_requested",
    "message": "Code review found issues that need to be addressed",
    "details": {
      "files_reviewed": [
        "Sources/GitBrainSwift/Component.swift"
      ],
      "issues": [
        {
          "severity": "high",
          "category": "correctness",
          "description": "Edge case not handled",
          "location": "Component.swift:45",
          "suggestion": "Add check for nil value before unwrapping"
        },
        {
          "severity": "medium",
          "category": "quality",
          "description": "Variable name is unclear",
          "location": "Component.swift:23",
          "suggestion": "Rename 'x' to 'result' for clarity"
        }
      ],
      "strengths": [
        "Good use of protocols",
        "Comprehensive error handling"
      ],
      "next_steps": [
        "Fix high severity issues",
        "Address medium severity issues",
        "Re-submit for review"
      ]
    }
  }
}
```

## Best Practices

### For Reviewers
1. **Be Constructive**: Focus on improvement, not criticism
2. **Be Specific**: Point to exact issues with line numbers
3. **Be Prioritized**: Order issues by severity and impact
4. **Be Positive**: Acknowledge good work and strengths
5. **Be Actionable**: Provide clear suggestions for fixes

### For Code Being Reviewed
1. **Be Open**: Accept feedback gracefully
2. **Ask Questions**: Clarify if feedback is unclear
3. **Learn**: Use feedback to improve future code
4. **Respond Promptly**: Address feedback quickly
5. **Follow Standards**: Use established patterns

## Common Issues

### High Severity
1. **Thread Safety**: Non-thread-safe code in concurrent context
2. **Memory Leaks**: Retain cycles or improper cleanup
3. **Crash Risks**: Force unwrapping or unsafe operations
4. **Security**: Exposed secrets or vulnerabilities
5. **Data Loss**: Missing error handling

### Medium Severity
1. **Performance**: Inefficient algorithms or operations
2. **Readability**: Unclear or confusing code
3. **Maintainability**: Hard to modify or extend
4. **Testing**: Insufficient test coverage
5. **Documentation**: Missing or unclear comments

### Low Severity
1. **Style**: Minor style inconsistencies
2. **Naming**: Slightly unclear variable names
3. **Comments**: Missing comments on obvious code
4. **Formatting**: Minor formatting issues
5. **Optimization**: Minor performance improvements

## Integration with GitBrain

### Before Review
1. **Search KnowledgeBase**: Look for similar code patterns
2. **Check Standards**: Review project coding standards
3. **Identify Patterns**: Note successful approaches

### During Review
1. **Reference Patterns**: Point to similar good code
2. **Store Issues**: Note common problems found
3. **Document Solutions**: Record how issues were fixed

### After Review
1. **Store Patterns**: Save successful code patterns
2. **Update BrainState**: Record review results
3. **Share Learnings**: What worked and what didn't

## Example

### Code to Review

```swift
public func processItem(_ item: Item?) async throws -> Result {
    let result = item!.value
    return Result.success(result)
}
```

### Review Feedback

```json
{
  "review_id": "review_2026-02-13T14:15:00Z",
  "from": "ReviewerAI",
  "to": "Creator",
  "timestamp": "2026-02-13T14:15:00Z",
  "type": "code_review",
  "content": {
    "status": "changes_requested",
    "message": "Found high severity issue with force unwrapping",
    "details": {
      "files_reviewed": [
        "Sources/GitBrainSwift/Processor.swift"
      ],
      "issues": [
        {
          "severity": "high",
          "category": "correctness",
          "description": "Force unwrapping may cause crash",
          "location": "Processor.swift:2",
          "suggestion": "Use guard let or optional chaining"
        }
      ],
      "strengths": [
        "Clear function signature",
        "Proper async/await usage"
      ],
      "next_steps": [
        "Fix force unwrapping issue",
        "Add error handling for nil input",
        "Re-submit for review"
      ]
    }
  }
}
```

## Related Skills

- **Task Execution**: Write code following review feedback
- **Apply Review Feedback**: Address review comments
- **Testing**: Verify fixes address issues
- **Documentation**: Document changes from review