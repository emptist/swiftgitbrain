# Collaboration Setup Instructions

## Overview

OverseerAI and CoderAI need to establish communication via the shared worktree. This document provides step-by-step instructions.

## Current Status

✓ Shared worktree created at: `/Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree`
✓ Collaboration proposal created: `COLLABORATION_PROPOSAL.json`

## Step 1: CoderAI Checks for Messages

From the **coder-worktree**, run:

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree

# Check for messages in shared worktree
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/coder/inbox/
```

## Step 2: Read Collaboration Proposal

The collaboration proposal is available at:

```
/Users/jk/gits/hub/gitbrains/swiftgitbrain/overseer-worktree/COLLABORATION_PROPOSAL.json
```

Copy this file to the shared worktree:

```bash
# From coder-worktree
mkdir -p /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/coder/inbox/
cp /Users/jk/gits/hub/gitbrains/swiftgitbrain/overseer-worktree/COLLABORATION_PROPOSAL.json \
   /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/coder/inbox/
```

## Step 3: CoderAI Responds

After reading the proposal, CoderAI should:

1. **Review the collaboration proposal**
2. **Confirm understanding of roles**
3. **Agree to responsibilities**
4. **Send response** to OverseerAI

Create a response message:

```json
{
  "id": "collaboration_response_001",
  "fromAI": "coder",
  "toAI": "overseer",
  "messageType": "status",
  "content": {
    "status": "AGREEMENT_ACCEPTED",
    "understanding": "I understand my role and responsibilities",
    "ready": "Ready to receive tasks",
    "timestamp": "2026-02-10T22:30:00Z"
  },
  "timestamp": "2026-02-10T22:30:00Z",
  "priority": 1
}
```

Save this as:

```
/Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/overseer/inbox/AGREEMENT_RESPONSE.json
```

## Step 4: OverseerAI Checks for Response

From the **overseer-worktree**, run:

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/overseer-worktree

# Check for messages
ls -la /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/overseer/inbox/
```

## Step 5: OverseerAI Assigns First Task

After receiving agreement, OverseerAI can assign the first task:

```swift
let taskID = "task_001"
let description = "Implement user authentication feature"

try await overseer.assignTask(
    taskID: taskID,
    coder: "coder",
    description: description,
    taskType: "feature"
)
```

## Collaboration Roles

### OverseerAI
- **Purpose**: Coordinate between AIs, review code submissions, manage task assignment, enforce quality standards
- **Capabilities**:
  - review_code
  - approve_code
  - reject_code
  - request_changes
  - provide_feedback
  - assign_tasks
  - monitor_progress
  - enforce_quality_standards
- **Responsibilities**:
  1. OverseerAI will assign tasks to CoderAI
  2. OverseerAI will review code submissions
  3. OverseerAI will provide feedback on code
  4. OverseerAI will approve or reject code
  5. OverseerAI will monitor progress
  6. OverseerAI will enforce quality standards

### CoderAI
- **Purpose**: Implement coding tasks, generate code based on requirements, submit code for review, handle feedback and revisions
- **Capabilities**:
  - write_code
  - implement_features
  - fix_bugs
  - refactor_code
  - write_tests
  - document_code
  - apply_feedback
  - submit_for_review
- **Responsibilities**:
  1. CoderAI will receive tasks from OverseerAI
  2. CoderAI will implement features and write code
  3. CoderAI will submit code via Pull Requests
  4. CoderAI will handle feedback
  5. CoderAI will make revisions as needed
  6. CoderAI will document code

## Communication Protocol

- **Method**: Shared worktree for real-time communication
- **Path**: `/Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree`
- **Message Types**: task, code, review, feedback, approval, rejection, status, heartbeat
- **Format**: All messages in SendableContent format
- **Thread Safety**: Respect actor boundaries

## What We've Done

✓ Fixed Swift 6.2 Sendable protocol violations
✓ Updated BrainStateManager to use SendableContent
✓ Updated MemoryStore to use SendableContent
✓ Updated KnowledgeBase to handle SendableContent
✓ Updated BaseRole protocol methods
✓ Fixed Logger concurrency safety
✓ Updated CoderAI and OverseerAI
✓ Updated ViewModels
✓ Created comprehensive .gitignore
✓ Created project-level rules
✓ Removed Python transition files
✓ Project builds successfully

## Next Steps

1. **CoderAI**: Read collaboration proposal from shared worktree
2. **CoderAI**: Send agreement response to OverseerAI
3. **OverseerAI**: Receive agreement and assign first task
4. **CoderAI**: Receive task and implement
5. **CoderAI**: Submit code for review
6. **OverseerAI**: Review code and approve/reject
7. **Cycle continues** for ongoing collaboration