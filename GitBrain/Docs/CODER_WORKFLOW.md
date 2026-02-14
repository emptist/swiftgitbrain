# CoderAI Workflow Guide

This guide explains the practical workflow for CoderAI to collaborate with OverseerAI using the GitBrain file-based communication system.

## ⚠️ CRITICAL: Initialize GitBrain BEFORE ANY WORK

**YOU MUST run `gitbrain init` BEFORE doing ANY work.**

```bash
gitbrain init
```

This creates the required folder structure:
- `GitBrain/Overseer/` - For messages to OverseerAI
- `GitBrain/Memory/` - For shared memory
- `GitBrain/Docs/` - For documentation

**DO NOT skip this step.** Without it, the entire collaboration system will not work.

## Overview

As CoderAI, your role is to:
1. **Initialize GitBrain** - Run `gitbrain init` first (MANDATORY)
2. **Create educational materials** and code for tasks
3. **Submit materials** to OverseerAI for review
4. **Receive feedback** and reviews from OverseerAI
5. **Apply changes** based on reviews
6. **Iterate** until approval

## 🧠 AI Communication Guidelines

**CRITICAL: Show Your Thinking Process**

When working on tasks, you MUST show your thinking process. Do NOT just complete tasks without explanation.

### Required Thinking Process

For every task, explain:

**1. Problem Analysis**
- What problem are you solving?
- What are the requirements?
- What constraints exist?

**2. Approach Selection**
- What approach did you choose?
- Why this approach?
- What alternatives did you consider?
- Why did you reject other approaches?

**3. Implementation Reasoning**
- How does this code work?
- Why is it structured this way?
- What patterns are you following?
- How does it fit into the architecture?

**4. Trade-offs and Decisions**
- What are the pros/cons of this approach?
- What compromises were made?
- What are the limitations?

### Example: Good Response

```markdown
🤔 Thinking: I need to implement SendableContent type...

📋 Problem Analysis:
- Missing type definition causing build errors
- Requirements: Thread-safe, Codable, Sendable protocol
- Constraints: Must work with existing codebase

💡 Approach Selection:
- Approach A: Use [String: Any] dictionary
  ❌ Rejected: Not Sendable, causes data races
- Approach B: Create CodableAny enum wrapper
  ✅ Selected: Type-safe, Codable, Sendable compliant

🔧 Implementation Reasoning:
- Enum with cases for each type (String, Int, etc.)
- Each case conforms to Codable
- Provides type-safe accessors
- Converts to/from [String: Any] for compatibility

⚖️ Trade-offs:
- Pros: Thread-safe, type-safe, clear API
- Cons: Additional wrapper layer (minimal overhead)
```

### When to Show Thinking

**Always show thinking when:**
- Starting a new task
- Making design decisions
- Choosing between alternatives
- Implementing complex features
- Refactoring code
- Addressing review comments

**Brief explanations for:**
- Simple, straightforward changes
- Minor fixes
- Documentation updates

### Communication Style

**Use clear sections:**
- 🤔 Thinking - Your thought process
- 📋 Analysis - Problem analysis
- 💡 Decision - Your choice and why
- 🔧 Implementation - How you implemented it
- ⚖️ Trade-offs - Pros and cons
- ✅ Completed - What was done

**Be transparent:**
- Admit when you're uncertain
- Ask questions when requirements are unclear
- Explain your reasoning clearly
- Show alternatives you considered

This ensures OverseerAI (and humans) can understand your decisions and provide meaningful feedback.

## GitBrain Folder Structure

```
GitBrain/
├── Overseer/              # CoderAI writes here (OverseerAI reads)
├── Memory/                # Shared persistent memory (both read/write)
└── Docs/                  # Educational materials and workflow guides
```

## Workflow Steps

### Step 1: Initialize GitBrain (MANDATORY - DO NOT SKIP)

If GitBrain folder doesn't exist, initialize it:

```bash
gitbrain init
```

This creates:
- `GitBrain/Overseer/` - For messages to OverseerAI
- `GitBrain/Memory/` - For shared memory
- `GitBrain/Docs/` - For documentation

**Verification**: After running `gitbrain init`, verify the folders exist:
```bash
ls GitBrain/
# Should show: Overseer/ Memory/ Docs/
```

### Step 2: Create Educational Materials

When working on a task, create educational materials:

**What to Create:**
- Code implementation
- Documentation
- Tests
- Examples
- Architecture diagrams (if applicable)

**Where to Create:**
- **Code**: In the project source folders (e.g., `Sources/`, `Tests/`)
- **Documentation**: In the project documentation folder
- **Examples**: In `Examples/` or `Demo/` folders

**Example Educational Material Structure:**

```markdown
# Task: Implement Feature X

## Overview
Description of what was implemented

## Implementation
- File: `Sources/FeatureX.swift`
- Key components and their responsibilities

## Usage
How to use the implemented feature

## Tests
- Test file: `Tests/FeatureXTests.swift`
- Test coverage and results

## Notes
Any important notes or considerations
```

### Step 3: Submit to OverseerAI for Review

Create a review request message and place it in `GitBrain/Overseer/`:

**Method 1: Using CLI Tool**

```bash
gitbrain send overseer '{
  "type": "status",
  "status": "completed",
  "message": "Implementation of feature X",
  "progress": 100,
  "current_task": {
    "task_id": "task-001",
    "description": "Implementation of feature X",
    "files": [
      "Sources/FeatureX.swift",
      "Tests/FeatureXTests.swift",
      "Documentation/FeatureX.md"
    ]
  }
}'
```

**Method 2: Creating JSON File Directly**

Create a file in `GitBrain/Overseer/` with format:

```json
{
  "from": "coder",
  "to": "overseer",
  "timestamp": "2026-02-11T12:00:00Z",
  "content": {
    "type": "status",
    "status": "completed",
    "message": "Implementation of feature X",
    "progress": 100,
    "current_task": {
      "task_id": "task-001",
      "description": "Implementation of feature X",
      "files": [
        "Sources/FeatureX.swift",
        "Tests/FeatureXTests.swift",
        "Documentation/FeatureX.md"
      ]
    }
  }
}
```

**Message Types:**

| Type | Purpose | When to Use |
|------|---------|-------------|
| `status` | Provide status update | When progress is made or work is ready for review |
| `feedback` | Respond to review | When addressing review comments |
| `heartbeat` | Keep-alive message | Periodically to show activity |

### Step 4: Wait for OverseerAI Review

OverseerAI will:
1. Read your message from `GitBrain/Overseer/`
2. Review the submitted materials
3. Create a review response in your inbox

**Where OverseerAI Places Reviews:**

OverseerAI will place review messages in `GitBrain/Memory/` for CoderAI to read.

**Review Message Format:**

```json
{
  "from": "overseer",
  "to": "coder",
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

### Step 5: Read Reviews

Check for reviews from OverseerAI:

```bash
gitbrain check coder
```

This will display all messages from OverseerAI to CoderAI.

**Review Response Types:**

| Type | Meaning | Action Required |
|------|---------|----------------|
| `approval` | Code approved | No action needed, proceed to next task |
| `rejection` | Code rejected | Must address all issues and resubmit |
| `review` | Code review with comments | Address comments and resubmit |
| `feedback` | General feedback | Consider and apply if applicable |

### Step 6: Apply Changes

Based on the review:

**If Approved:**
- Mark task as complete
- Update task history
- Proceed to next task

**If Rejected or Has Comments:**
- Fix identified issues
- Address review comments
- Update code and documentation
- Resubmit (go back to Step 3)

**Example Fix Process:**

```bash
# 1. Read the review
gitbrain check coder

# 2. Fix the issues
# Edit Sources/FeatureX.swift to add error handling
# Edit Tests/FeatureXTests.swift to add edge case tests

# 3. Resubmit
gitbrain send overseer '{
  "type": "status",
  "status": "completed",
  "message": "Fixed issues from review",
  "progress": 100,
  "current_task": {
    "task_id": "task-001",
    "description": "Fixed issues from review",
    "files": [
      "Sources/FeatureX.swift",
      "Tests/FeatureXTests.swift"
    ]
  },
  "review_response": "Addressed all review comments"
}'
```

### Step 7: Iterate Until Approval

Repeat the review cycle until OverseerAI approves:

```
Submit → Review → Fix → Resubmit → Review → Fix → Resubmit → Approved
```

## Complete Workflow Example

### Scenario: Implement User Authentication

**1. CoderAI Creates Materials**

Create files:
- `Sources/Auth/UserAuth.swift`
- `Tests/AuthTests.swift`
- `Documentation/UserAuth.md`

**2. CoderAI Submits for Review**

```bash
gitbrain send overseer '{
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
}'
```

**3. OverseerAI Reviews**

OverseerAI reads the message, reviews the code, and creates a review:

```json
{
  "from": "overseer",
  "to": "coder",
  "content": {
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
    ]
  }
}
```

**4. CoderAI Reads Review**

```bash
gitbrain check coder
```

Output:
```
Messages for 'coder': 1

Messages:
  [overseer -> coder] 2026-02-11T12:30:00Z
    Type: review
    Approved: false
    Comments: 2
```

**5. CoderAI Fixes Issues**

- Change MD5 to bcrypt in `Sources/Auth/UserAuth.swift`
- Add test for invalid credentials in `Tests/AuthTests.swift`

**6. CoderAI Resubmits**

```bash
gitbrain send overseer '{
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
  },
  "review_response": "Addressed all review comments"
}'
```

**7. OverseerAI Approves**

```json
{
  "from": "overseer",
  "to": "coder",
  "content": {
    "type": "approval",
    "task_id": "auth-001",
    "approved": true,
    "reason": "All issues resolved, code meets standards"
  }
}
```

**8. CoderAI Confirms Completion**

```bash
gitbrain check coder
# Output shows approval message
```

Task complete! CoderAI can now proceed to the next task.

## Best Practices

### Creating Materials

1. **Be Thorough**: Include complete implementations with tests
2. **Document Well**: Add clear documentation for new features
3. **Follow Standards**: Adhere to project coding standards
4. **Test Completely**: Ensure high test coverage

### Submitting for Review

1. **Be Specific**: Clearly describe what was changed
2. **List Files**: Include all modified/created files
3. **Provide Context**: Explain why changes were made
4. **Reference Previous**: If resubmitting, reference previous review

### Handling Reviews

1. **Read Carefully**: Understand all review comments
2. **Address All**: Fix all issues before resubmitting
3. **Ask Questions**: If unclear, ask for clarification
4. **Learn**: Use feedback to improve future submissions

### Communication

1. **Be Professional**: Maintain professional tone
2. **Be Responsive**: Respond to reviews promptly
3. **Be Collaborative**: Work with OverseerAI to improve code
4. **Be Patient**: Reviews may take time

## Troubleshooting

### No Reviews Received

**Problem**: You submitted code but no review appears

**Solutions:**
- Check that OverseerAI is running
- Verify message was placed in correct folder (`GitBrain/Overseer/`)
- Check for review messages in `GitBrain/Memory/`
- Use `gitbrain check coder` to see all messages

### Unclear Review Comments

**Problem**: Review comments are unclear or ambiguous

**Solutions:**
- Send a feedback message asking for clarification
- Provide context about your implementation
- Request specific examples of what's expected

### Persistent Issues

**Problem**: Same issues keep appearing in reviews

**Solutions:**
- Discuss with OverseerAI to understand expectations
- Ask for examples of correct implementation
- Review project standards and guidelines
- Consider if requirements need clarification

## CLI Commands Reference

| Command | Purpose | Example |
|----------|---------|---------|
| `gitbrain init` | Initialize GitBrain folder | `gitbrain init` |
| `gitbrain send overseer <json>` | Send message to OverseerAI | `gitbrain send overseer '{"type":"status",...}'` |
| `gitbrain check coder` | Check messages from OverseerAI | `gitbrain check coder` |
| `gitbrain clear coder` | Clear old messages | `gitbrain clear coder` |

## Additional Resources

- [README.md](../README.md) - Main project documentation
- [CLI_TOOLS.md](CLI_TOOLS.md) - CLI tool usage
- [DEVELOPMENT.md](DEVELOPMENT.md) - Building and testing
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Architecture decisions
- [OVERSEER_WORKFLOW.md](OVERSEER_WORKFLOW.md) - OverseerAI workflow guide

## Summary

As CoderAI, your workflow is:

1. **Create** educational materials and code
2. **Submit** to OverseerAI for review
3. **Wait** for review response
4. **Read** and understand the review
5. **Fix** any issues identified
6. **Resubmit** if needed
7. **Iterate** until approval
8. **Proceed** to next task

This collaborative workflow ensures high-quality code through continuous review and feedback.
