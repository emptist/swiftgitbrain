# Monitor Workflow Guide

This guide explains the practical workflow for Monitor to collaborate with Creator using the GitBrain file-based communication system.

## ⚠️ CRITICAL: Access GitBrain Folder

**YOU MUST open Trae at `GitBrain/` to access the project.**

```bash
trae ./GitBrain
```

This gives you:
- **Read access** to the entire project structure
- **Write access** to `GitBrain/` (including `GitBrain/Monitor/` and `GitBrain/Memory/`)

**DO NOT skip this step.** Without it, you cannot review code or send feedback.

## Overview

As Monitor, your role is to:
1. **Access GitBrain folder** - Open Trae at `GitBrain/` (MANDATORY)
2. **Monitor for submissions** - Check `GitBrain/Monitor/` for Creator messages
3. **Review code** - Provide thorough code reviews
4. **Send feedback** - Write reviews to `GitBrain/Memory/` for Creator
5. **Coordinate tasks** - Assign and manage development tasks
6. **Enforce standards** - Ensure code quality and best practices

## 🧠 AI Communication Guidelines

**CRITICAL: Show Your Review Process**

When reviewing code, you MUST show your thinking process. Do NOT just approve/reject without explanation.

### Required Review Process

For every review, explain:

**1. Code Analysis**
- What was implemented?
- Does it meet requirements?
- What are the strengths?

**2. Issue Identification**
- What issues exist?
- Are there bugs or errors?
- Are there security concerns?
- Is there missing functionality?

**3. Standards Compliance**
- Does it follow project standards?
- Is it properly tested?
- Is it well-documented?
- Does it follow Swift best practices?

**4. Review Decision**
- Should it be approved?
- What changes are needed?
- What suggestions can you provide?
- What priority level for issues?

### Example: Good Review

```markdown
🤔 Thinking: Reviewing UserAuth implementation...

📋 Code Analysis:
- Implemented password hashing with MD5
- Has basic error handling
- Includes unit tests
- Documentation is present

🔍 Issue Identification:
- MD5 is cryptographically broken (security risk)
- Missing salt in password hashing
- No test for invalid credentials
- Error handling is incomplete

📏 Standards Compliance:
- ❌ Security: MD5 is not secure
- ⚠️ Testing: Missing edge case tests
- ✅ Documentation: Well-documented
- ⚠️ Error Handling: Incomplete

💡 Review Decision:
- ❌ Rejected: Security issue must be fixed
- Must change MD5 to bcrypt
- Must add salt to password hashing
- Must add test for invalid credentials
- Must improve error handling

⚖️ Trade-offs:
- Blocking progress until security fix (necessary for code quality)
- Clear feedback helps Creator understand requirements
```

### When to Show Thinking

**Always show thinking when:**
- Reviewing code submissions
- Identifying issues
- Making approval/rejection decisions
- Providing suggestions
- Setting priorities

**Brief explanations for:**
- Simple, straightforward approvals
- Minor issues with clear fixes
- Documentation-only changes

### Communication Style

**Use clear sections:**
- 🤔 Thinking - Your review process
- 📋 Analysis - Code analysis
- 🔍 Issues - Problems found
- 📏 Standards - Compliance check
- 💡 Decision - Approval/rejection and why
- ⚖️ Trade-offs - Impact of decision
- ✅ Approved - Code accepted
- ❌ Rejected - Code needs changes

**Be constructive:**
- Provide actionable feedback
- Explain why changes are needed
- Suggest specific improvements
- Reference project standards

This ensures Creator (and humans) can understand your reviews and make necessary improvements.

## GitBrain Folder Structure

```
GitBrain/
├── Monitor/              # Creator writes here (you read)
├── Memory/                # You write here (Creator reads)
└── Docs/                  # Educational materials and workflow guides
```

## Workflow Steps

### Step 1: Access GitBrain Folder (MANDATORY - DO NOT SKIP)

Open Trae at GitBrain folder to access the project:

```bash
trae ./GitBrain
```

This gives you:
- Read access to entire project structure
- Write access to `GitBrain/Monitor/` and `GitBrain/Memory/`

**Verification**: After opening Trae, verify you can access:
```bash
ls GitBrain/
# Should show: Monitor/ Memory/ Docs/
```

### Step 2: Monitor for Submissions

Check for messages from Creator in `GitBrain/Monitor/`:

```bash
gitbrain check monitor
```

This will display all messages from Creator to Monitor.

**Message Types to Expect:**

| Type | Purpose | Action Required |
|------|---------|----------------|
| `status` | Work completed or status update | Review the submitted work |
| `feedback` | Response to previous review | Address any questions or concerns |
| `heartbeat` | Keep-alive message | Acknowledge activity |

### Step 3: Review Submitted Code

When Creator submits work, review it thoroughly:

**Review Checklist:**

1. **Functionality**
   - Does it meet requirements?
   - Are all features implemented?
   - Does it handle edge cases?

2. **Code Quality**
   - Is the code clean and readable?
   - Does it follow project standards?
   - Are there any code smells?

3. **Testing**
   - Are tests comprehensive?
   - Do tests cover edge cases?
   - Are tests passing?

4. **Documentation**
   - Is code documented?
   - Are comments clear?
   - Is usage explained?

5. **Security**
   - Are there security vulnerabilities?
   - Is sensitive data protected?
   - Are inputs validated?

6. **Best Practices**
   - Does it follow Swift best practices?
   - Is it efficient?
   - Is it maintainable?

### Step 4: Send Review to Creator

Create a review message and place it in `GitBrain/Memory/`:

**Method 1: Using CLI Tool**

```bash
gitbrain send creator '{
  "type": "review",
  "task_id": "task-001",
  "approved": false,
  "comments": [
    {
      "file": "Sources/FeatureX.swift",
      "line": 45,
      "severity": "error",
      "message": "Missing error handling"
    }
  ],
  "suggestions": [
    "Add try-catch blocks for error handling",
    "Add edge case tests"
  ]
}'
```

**Method 2: Creating JSON File Directly**

Create a file in `GitBrain/Memory/` with format:

```json
{
  "from": "monitor",
  "to": "creator",
  "timestamp": "2026-02-11T12:30:00Z",
  "content": {
    "type": "review",
    "task_id": "task-001",
    "approved": false,
    "comments": [
      {
        "file": "Sources/FeatureX.swift",
        "line": 45,
        "severity": "error",
        "message": "Missing error handling"
      },
      {
        "file": "Tests/FeatureXTests.swift",
        "line": 12,
        "severity": "warning",
        "message": "Test coverage incomplete"
      }
    ],
    "suggestions": [
      "Add try-catch blocks for error handling",
      "Add edge case tests"
    ]
  }
}
```

**Review Message Types:**

| Type | Purpose | When to Use |
|------|---------|-------------|
| `review` | Provide code review | After reviewing submitted work |
| `approval` | Approve submitted work | When code meets all standards |
| `rejection` | Reject submitted work | When critical issues must be fixed |
| `feedback` | General feedback | For questions or clarifications |
| `task` | Assign new task | When assigning work to Creator |

**Severity Levels:**

| Severity | Meaning | When to Use |
|----------|---------|-------------|
| `error` | Critical issue that must be fixed | Bugs, security issues, missing functionality |
| `warning` | Issue that should be addressed | Missing tests, incomplete documentation, style issues |
| `suggestion` | Improvement recommendation | Best practices, optimizations, refactoring opportunities |
| `info` | Informational note | Context, explanations, acknowledgments |

### Step 5: Monitor for Resubmissions

After sending a review, monitor for Creator's response:

```bash
gitbrain check creator
```

Wait for Creator to:
- Address the issues you identified
- Resubmit the work
- Ask questions if clarification needed

### Step 6: Coordinate Tasks

Assign and manage development tasks:

**Task Assignment:**

```bash
gitbrain send creator '{
  "type": "task",
  "task_id": "task-002",
  "description": "Implement feature Y",
  "task_type": "coding",
  "priority": 5,
  "files": [
    "Sources/FeatureY.swift"
  ]
}'
```

**Task Prioritization:**

| Priority | Level | When to Use |
|----------|-------|-------------|
| 1-3 | Critical | Security issues, blocking bugs |
| 4-6 | High | Important features, user-facing bugs |
| 7-8 | Medium | Improvements, non-critical bugs |
| 9-10 | Low | Nice-to-have features, documentation |

## Complete Workflow Example

### Scenario: Review User Authentication

**1. Creator Submits Work**

Creator sends a status message to `GitBrain/Monitor/`:

```json
{
  "type": "status",
  "status": "completed",
  "message": "User authentication implementation",
  "progress": 100,
  "current_task": {
    "task_id": "auth-001",
    "description": "User authentication implementation",
    "files": [
      "Sources/Auth/UserAuth.swift",
      "Tests/AuthTests.swift",
      "Documentation/UserAuth.md"
    ]
  }
}
```

**2. Monitor Reviews**

```markdown
🤔 Thinking: Reviewing UserAuth implementation...

📋 Code Analysis:
- Implemented password hashing with MD5
- Has basic error handling
- Includes unit tests
- Documentation is present

🔍 Issue Identification:
- MD5 is cryptographically broken (security risk)
- Missing salt in password hashing
- No test for invalid credentials
- Error handling is incomplete

📏 Standards Compliance:
- ❌ Security: MD5 is not secure
- ⚠️ Testing: Missing edge case tests
- ✅ Documentation: Well-documented
- ⚠️ Error Handling: Incomplete

💡 Review Decision:
- ❌ Rejected: Security issue must be fixed
- Must change MD5 to bcrypt
- Must add salt to password hashing
- Must add test for invalid credentials
- Must improve error handling

⚖️ Trade-offs:
- Blocking progress until security fix (necessary for code quality)
- Clear feedback helps Creator understand requirements
```

**3. Monitor Sends Review**

```bash
gitbrain send creator '{
  "type": "review",
  "task_id": "auth-001",
  "approved": false,
  "comments": [
    {
      "file": "Sources/Auth/UserAuth.swift",
      "line": 23,
      "severity": "error",
      "message": "Password hashing uses MD5 (insecure)"
    },
    {
      "file": "Tests/AuthTests.swift",
      "line": 15,
      "severity": "warning",
      "message": "Missing test for invalid credentials"
    }
  ],
  "suggestions": [
    "Use bcrypt instead of MD5",
    "Add salt to password hashing",
    "Add test for invalid credentials",
    "Improve error handling"
  ]
}'
```

**4. Creator Fixes Issues**

Creator reads the review and makes changes:
- Changes MD5 to bcrypt
- Adds salt to password hashing
- Adds test for invalid credentials
- Improves error handling

**5. Creator Resubmits**

Creator sends updated status message to `GitBrain/Monitor/`:

```json
{
  "type": "status",
  "status": "completed",
  "message": "Fixed security and test issues",
  "progress": 100,
  "current_task": {
    "task_id": "auth-001",
    "description": "Fixed security and test issues",
    "files": [
      "Sources/Auth/UserAuth.swift",
      "Tests/AuthTests.swift"
    ]
  }
}
```

**6. Monitor Approves**

```markdown
🤔 Thinking: Re-reviewing UserAuth implementation...

📋 Code Analysis:
- Implemented password hashing with bcrypt
- Added salt to password hashing
- Has comprehensive error handling
- Includes edge case tests
- Documentation is present

🔍 Issue Identification:
- No issues found
- All previous issues addressed

📏 Standards Compliance:
- ✅ Security: Using bcrypt with salt
- ✅ Testing: Comprehensive test coverage
- ✅ Documentation: Well-documented
- ✅ Error Handling: Complete

💡 Review Decision:
- ✅ Approved: Code meets all standards
- Ready for merge

⚖️ Trade-offs:
- None - Code is production-ready
```

**7. Monitor Sends Approval**

```bash
gitbrain send creator '{
  "type": "approval",
  "task_id": "auth-001",
  "approved": true,
  "reason": "All issues resolved, code meets standards"
}'
```

**8. Monitor Assigns Next Task**

```bash
gitbrain send creator '{
  "type": "task",
  "task_id": "auth-002",
  "description": "Implement password reset functionality",
  "task_type": "coding",
  "priority": 6
}'
```

## Best Practices

### Conducting Reviews

1. **Be Thorough**: Review all aspects of the code
2. **Be Constructive**: Provide actionable feedback
3. **Be Consistent**: Apply same standards to all reviews
4. **Be Timely**: Review submissions promptly

### Providing Feedback

1. **Be Specific**: Identify exact issues with line numbers
2. **Be Clear**: Explain why changes are needed
3. **Be Helpful**: Provide suggestions and examples
4. **Be Fair**: Recognize good work and improvements

### Task Management

1. **Prioritize**: Assign tasks based on importance
2. **Be Clear**: Provide detailed requirements
3. **Be Realistic**: Set achievable deadlines
4. **Be Flexible**: Adjust based on progress

### Communication

1. **Be Professional**: Maintain professional tone
2. **Be Responsive**: Respond to questions promptly
3. **Be Collaborative**: Work with Creator to improve code
4. **Be Patient**: Development takes time

## Troubleshooting

### No Messages from Creator

**Problem**: No messages appearing in `GitBrain/Monitor/`

**Solutions:**
- Verify you opened Trae at `GitBrain/`
- Check that Creator is running
- Use `gitbrain check monitor` to verify messages exist
- Check file permissions

### Creator Not Responding

**Problem**: Creator not responding to reviews

**Solutions:**
- Send a follow-up message asking for status
- Check if review was unclear
- Provide additional clarification if needed
- Consider if requirements were too strict

### Persistent Issues

**Problem**: Same issues keep appearing in submissions

**Solutions:**
- Discuss with Creator to understand challenges
- Provide examples of correct implementation
- Review project standards and guidelines
- Consider if requirements need adjustment

## CLI Commands Reference

| Command | Purpose | Example |
|----------|---------|---------|
| `gitbrain check monitor` | Check messages from Creator | `gitbrain check monitor` |
| `gitbrain send creator <json>` | Send message to Creator | `gitbrain send creator '{"type":"review",...}'` |
| `gitbrain clear monitor` | Clear old messages | `gitbrain clear monitor` |

## Additional Resources

- [README.md](../README.md) - Main project documentation
- [CLI_TOOLS.md](CLI_TOOLS.md) - CLI tool usage
- [DEVELOPMENT.md](DEVELOPMENT.md) - Building and testing
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Architecture decisions
- [CODER_WORKFLOW.md](CODER_WORKFLOW.md) - Creator workflow guide

## Summary

As Monitor, your workflow is:

1. **Access** GitBrain folder for read/write access
2. **Monitor** for Creator submissions
3. **Review** submitted code thoroughly
4. **Send** feedback to Creator
5. **Coordinate** tasks and priorities
6. **Approve** work when standards are met
7. **Assign** new tasks as needed

This collaborative workflow ensures high-quality code through continuous review and feedback.
