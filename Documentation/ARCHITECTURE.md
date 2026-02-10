# GitBrainSwift Architecture Diagram

## How CoderAI and OverseerAI Collaborate

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    GitHub Repository (gitbrainswift)                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    Git Repository                          │   │
│  │                                                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │   │
│  │  │   main      │  │   coder     │  │  overseer │ │   │
│  │  │   branch    │  │   branch    │  │  branch   │ │   │
│  │  └─────────────┘  └─────────────┘  └───────────┘ │   │
│  │                                                          │   │
│  │  Sources/GitBrainSwift/  ← Shared library code              │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              GitHub Issues (Communication)                  │   │
│  │                                                          │   │
│  │  Issue #1: [coder] task: abc12345                      │   │
│  │    From: overseer, To: coder                             │   │
│  │    Content: "Implement feature X"                           │   │
│  │                                                          │   │
│  │  Issue #2: [overseer] code: def67890                    │   │
│  │    From: coder, To: overseer                             │   │
│  │    Content: "Here's the implementation"                     │   │
│  │                                                          │   │
│  │  Issue #3: [coder] approval: ghi12345                    │   │
│  │    From: overseer, To: coder                             │   │
│  │    Content: "Code approved"                                │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────┐         ┌─────────────────────────┐
│     CoderAI          │         │     OverseerAI        │
│                      │         │                      │
│  coder-worktree/      │         │  overseer-worktree/   │
│                      │         │                      │
│  ┌────────────────┐   │         │  ┌────────────────┐   │
│  │ .coder-state/ │   │         │  │ .overseer-   │   │
│  │              │   │         │  │   state/    │   │
│  └────────────────┘   │         │  └────────────────┘   │
│                      │         │                      │
│  git checkout coder   │         │  git checkout        │
│  git pull origin    │         │    overseer          │
│  git push origin    │         │  git pull origin     │
│                      │         │  git fetch origin     │
│  ┌────────────────┐   │         │                      │
│  │ GitHub        │   │         │  ┌────────────────┐   │
│  │ Communication │   │         │  │ GitHub        │   │
│  │              │   │         │  │ Communication │   │
│  │ receiveMsgs() │   │         │  │              │   │
│  │ processMsg()  │   │         │  │ receiveMsgs() │   │
│  │ sendMsg()     │   │         │  │ processMsg()  │   │
│  └────────────────┘   │         │  │ sendMsg()     │   │
│                      │         │  └────────────────┘   │
└─────────────────────────┘         └─────────────────────────┘
```

## How It Works

### Initial Setup (One-time)

1. **Create Git Repository**
   ```bash
   git init gitbrainswift
   cd gitbrainswift
   git remote add origin https://github.com/username/gitbrainswift.git
   ```

2. **Add GitBrainSwift Library**
   ```bash
   # Add library code to repository
   mkdir -p Sources/GitBrainSwift
   # ... copy all library files ...
   git add .
   git commit -m "Add GitBrainSwift library"
   git push origin main
   ```

3. **Create Worktrees**
   ```bash
   git worktree add coder-worktree -b coder
   git worktree add overseer-worktree -b overseer
   ```

4. **Push Branches**
   ```bash
   git push origin coder
   git push origin overseer
   ```

### Code Sharing (via Git)

**CoderAI pushes code:**
```bash
cd coder-worktree
# ... implement feature ...
git add .
git commit -m "Implement feature X"
git push origin coder
```

**OverseerAI pulls code:**
```bash
cd overseer-worktree
git fetch origin coder
git checkout coder
# ... review code ...
```

**OverseerAI can also use Pull Request:**
```bash
# Create PR from coder branch to main
gh pr create --base main --head coder --title "Review feature X"
```

### Communication (via GitHub Issues)

**OverseerAI sends task:**
```swift
let communication = GitHubCommunication(
    owner: "username",
    repo: "gitbrainswift",
    token: token
)

let message = MessageBuilder.createTaskMessage(
    fromAI: "overseer",
    toAI: "coder",
    taskID: "task_001",
    taskDescription: "Implement feature X"
)

try await communication.sendMessage(message, from: "overseer", to: "coder")
```

**CoderAI receives task:**
```swift
let messages = try await communication.receiveMessages(for: "coder")
for message in messages {
    await coder.processMessage(message)
}
```

**CoderAI responds:**
```swift
try await coder.submitCode(reviewer: "overseer")
```

**OverseerAI receives response:**
```swift
let messages = try await communication.receiveMessages(for: "overseer")
for message in messages {
    await overseer.processMessage(message)
}
```

## Key Points

### Code vs Communication

| Aspect | Code | Communication |
|---------|--------|---------------|
| **Method** | Git (push/pull) | GitHub Issues |
| **Purpose** | Share implementation | Exchange messages |
| **Storage** | Git repository | GitHub Issues |
| **Access** | Both AIs | Both AIs |
| **History** | Git commits | Issue history |
| **Review** | Pull Requests | Issue comments |

### Why This Works

1. **Same Repository**: Both AIs work in same Git repository
2. **Separate Branches**: Each AI has its own branch for isolation
3. **Git for Code**: Version control handles code sharing
4. **GitHub Issues for Messages**: Messaging doesn't require file access
5. **No Bootstrap Problem**: Library code is in repository, accessible to both

### Bootstrap Process

```
1. Create Git Repository
   ↓
2. Add GitBrainSwift Library to repository
   ↓
3. Push to GitHub
   ↓
4. Create worktrees (coder, overseer)
   ↓
5. Both AIs pull library code from repository
   ↓
6. Both AIs can now communicate via GitHub Issues
```

## Advantages

### For Code Sharing:
- ✅ Version control via Git
- ✅ Pull Requests for code review
- ✅ Merge conflicts handled by Git
- ✅ Complete code history
- ✅ Branch isolation per AI

### For Communication:
- ✅ No file permission issues
- ✅ Works across different machines
- ✅ Persistent message history
- ✅ Searchable via GitHub UI
- ✅ Built-in features (labels, comments)

### Overall:
- ✅ Clean separation of concerns
- ✅ Scalable to multiple AIs
- ✅ No manual file copying
- ✅ Works with existing GitHub workflows
