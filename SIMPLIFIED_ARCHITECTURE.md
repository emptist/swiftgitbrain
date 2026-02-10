# Simplified Architecture Design

## Current State

The `complex` branch has merged both `coder/main` and `overseer/main` branches, creating a comprehensive but overly complex architecture.

## Simplified Design Goals

Based on requirements:
1. **OverseerAI**: Review code, send GitHub issues, follow up on issues - **NOT write code**
2. **CoderAI**: Can do anything (code, review, etc.)
3. **Single Branch**: Both roles should be in the same branch (not separate branches)
4. **Editor Configuration**:
   - Trae/Editor for OverseerAI: Opens at overseer's working folder
   - Trae/Editor for CoderAI: Opens at root project folder

## Proposed Simplified Architecture

### Core Components

```
GitBrainSwift/
├── Communication/
│   ├── GitHubCommunication.swift          # GitHub API interaction
│   ├── MessageBuilder.swift              # Message creation
│   └── SharedWorktreeCommunication.swift # Real-time messaging
├── Git/
│   ├── GitManager.swift                  # Git operations
│   └── WorktreeManager.swift             # Worktree management
├── Memory/
│   ├── BrainStateManager.swift            # Persistent state
│   ├── KnowledgeBase.swift               # Knowledge storage
│   └── MemoryStore.swift                # In-memory cache
├── Models/
│   ├── BrainState.swift
│   ├── Message.swift
│   ├── MessageType.swift
│   ├── RoleConfig.swift
│   ├── RoleType.swift
│   └── SystemConfig.swift
├── Roles/
│   ├── BaseRole.swift                   # Common protocol
│   ├── CoderAI.swift                   # Full-featured AI
│   └── OverseerAI.swift               # Review-only AI
├── Utilities/
│   ├── Extensions.swift
│   └── Logger.swift
└── ViewModels/
    ├── CoderAIViewModel.swift
    ├── OverseerAIViewModel.swift
    └── GitBrainSystemViewModel.swift
```

### Role Responsibilities

#### CoderAI (Full-Featured)
- ✅ Receive and process tasks
- ✅ Write code (Swift, Python, JavaScript, etc.)
- ✅ Submit code for review
- ✅ Review code (if needed)
- ✅ Manage knowledge base
- ✅ Manage memory
- ✅ All BaseRole capabilities

#### OverseerAI (Review-Only)
- ✅ Receive code submissions
- ✅ Review code (approve/reject/request changes)
- ✅ Create GitHub issues for tasks
- ✅ Follow up on GitHub issues
- ✅ Manage review queue
- ✅ Manage review history
- ❌ **NOT**: Write code
- ❌ **NOT**: Implement features

### Communication Flow

```
┌─────────────┐
│  OverseerAI │
│             │
│  Reviewer   │
└──────┬──────┘
       │
       │ GitHub Issues
       │ + Shared Worktree
       │
       ▼
┌─────────────┐
│   CoderAI   │
│             │
│  Developer   │
└─────────────┘
```

### Editor Configuration

For Trae IDE:

**OverseerAI Worktree:**
```bash
git worktree add overseer-worktree overseer/main
# Trae opens: /path/to/swiftgitbrain/overseer-worktree
```

**CoderAI Worktree:**
```bash
git worktree add coder-worktree coder/main
# Trae opens: /path/to/swiftgitbrain/coder-worktree
```

### Branch Strategy

**Simplified:**
```
master (main)
  └─ All code in single branch
  └─ Both roles share same codebase
  └─ Worktrees for different AI contexts
```

**Previous (Complex):**
```
coder/main
  └─ CoderAI specific code
  └─ Separate from overseer

overseer/main
  └─ OverseerAI specific code
  └─ Separate from coder
```

## Implementation Steps

1. ✅ Merge coder/main and overseer/main into `complex` branch
2. ⏳ Simplify OverseerAI to remove code-writing capabilities
3. ⏳ Ensure CoderAI has all capabilities
4. ⏳ Create `simplified` branch from `complex`
5. ⏳ Update `master` to `simplified`
6. ⏳ Clean up old branches

## Key Changes Needed

### OverseerAI Simplifications

Remove from OverseerAI:
- `generateSwiftCode()`
- `generatePythonCode()`
- `generateJavaScriptCode()`
- Code generation methods
- Implementation methods

Keep in OverseerAI:
- `reviewCode()`
- `approveCode()`
- `rejectCode()`
- `requestChanges()`
- `assignTask()`
- GitHub issue management
- Review queue management

### CoderAI Enhancements

Ensure CoderAI has:
- All code generation methods
- All review methods (if needed)
- Full communication capabilities
- Complete knowledge base access
- Complete memory management

## Benefits of Simplified Architecture

1. **Single Source of Truth**: One branch for all code
2. **Easier Maintenance**: No divergent branches
3. **Clear Separation**: Roles separated by responsibility, not by branch
4. **Better Collaboration**: Both AIs work from same codebase
5. **Simplified Deployment**: One release, one version
6. **Clearer Testing**: Test all roles together
