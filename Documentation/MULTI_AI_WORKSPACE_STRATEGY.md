# Multi-AI Workspace Strategy

**Status**: 📝 Design Phase  
**Created**: 2026-02-10  
**Participants**: OverseerAI, CoderAI  
**Target Repository**: swiftgitbrain

## 🎯 Problem

**Using same Trae CN to open same repo for different AIs requires opening in different folders.**

**Alternative**: Git clone to another repo and open Trae in different clone directory.

**Need**: Ideal workspace strategy for multiple AIs working on same repository.

---

## 🏗️ Solution: Git Worktrees

### What are Git Worktrees?

Git worktrees allow multiple working directories for the same repository, all sharing the same `.git` directory.

**Benefits**:
- ✅ Multiple working directories, one `.git` directory
- ✅ Each worktree can be on different branches
- ✅ Efficient disk usage (no duplicate `.git` directories)
- ✅ Independent workspaces for each AI
- ✅ Easy git operations (push, pull, merge)
- ✅ Native git feature, no external tools needed

---

## 📁 Workspace Structure

### Recommended Structure

```
~/gits/hub/gitbrains/
├── swiftgitbrain/                    # Main repository (bare or main worktree)
│   ├── .git/                        # Shared git directory
│   ├── Package.swift
│   ├── Sources/
│   └── ...
├── swiftgitbrain-coder/              # CoderAI worktree
│   ├── .git                         # Symbolic link to ../swiftgitbrain/.git
│   ├── Package.swift                  # CoderAI's working copy
│   ├── Sources/
│   └── ...
├── swiftgitbrain-overseer/           # OverseerAI worktree
│   ├── .git                         # Symbolic link to ../swiftgitbrain/.git
│   ├── Package.swift                  # OverseerAI's working copy
│   ├── Sources/
│   └── ...
└── swiftgitbrain-shared/             # Shared worktree (optional)
    ├── .git                         # Symbolic link to ../swiftgitbrain/.git
    ├── Package.swift
    ├── Sources/
    └── ...
```

### Alternative Structure (Role-Based)

```
~/gits/hub/gitbrains/
├── swiftgitbrain/                    # Main repository
│   ├── .git/
│   ├── Package.swift
│   └── ...
├── worktrees/                        # Worktrees directory
│   ├── coder/                        # CoderAI worktree
│   │   ├── .git                     # Symbolic link to ../../swiftgitbrain/.git
│   │   ├── Package.swift
│   │   └── ...
│   └── overseer/                     # OverseerAI worktree
│       ├── .git                     # Symbolic link to ../../swiftgitbrain/.git
│       ├── Package.swift
│       └── ...
```

---

## 🔧 Git Worktree Commands

### Creating Worktrees

```bash
# Navigate to main repository
cd ~/gits/hub/gitbrains/swiftgitbrain

# Create worktree for CoderAI on feature/coder branch
git worktree add ../swiftgitbrain-coder feature/coder

# Create worktree for OverseerAI on feature/overseer branch
git worktree add ../swiftgitbrain-overseer feature/overseer

# Create worktree for shared work on master branch
git worktree add ../swiftgitbrain-shared master
```

### Managing Worktrees

```bash
# List all worktrees
git worktree list

# Remove a worktree
git worktree remove ../swiftgitbrain-coder

# Prune stale worktrees
git worktree prune
```

### Working with Worktrees

```bash
# CoderAI working in their worktree
cd ~/gits/hub/gitbrains/swiftgitbrain-coder
git checkout -b feature/new-task
git add .
git commit -m "Add new task"
git push origin feature/new-task

# OverseerAI working in their worktree
cd ~/gits/hub/gitbrains/swiftgitbrain-overseer
git checkout -b review/task-123
git add .
git commit -m "Review task 123"
git push origin review/task-123
```

---

## 🎯 Branch Strategy for Worktrees

### Recommended Branch Structure

```
master                          # Main branch (shared worktree)
├── feature/coder                # CoderAI's feature branch (coder worktree)
├── feature/overseer            # OverseerAI's feature branch (overseer worktree)
├── review/task-123             # Review branch (overseer worktree)
├── review/task-456             # Review branch (overseer worktree)
└── bugfix/issue-789           # Bug fix branch (coder worktree)
```

### Workflow

1. **CoderAI**:
   - Works in `swiftgitbrain-coder` worktree
   - Creates feature branches: `feature/coder-*`, `bugfix/issue-*`
   - Pushes changes to remote
   - Creates pull requests

2. **OverseerAI**:
   - Works in `swiftgitbrain-overseer` worktree
   - Creates review branches: `review/task-*`
   - Reviews pull requests
   - Merges approved changes to master

3. **Shared Worktree**:
   - Works in `swiftgitbrain-shared` worktree
   - Used for collaboration
   - Merges changes from both AIs
   - Keeps master branch clean

---

## 🚀 Automation Scripts

### Setup Script

```bash
#!/bin/bash
# setup-worktrees.sh - Set up git worktrees for AI collaboration

REPO_DIR="$HOME/gits/hub/gitbrains/swiftgitbrain"
CODER_WORKTREE="$HOME/gits/hub/gitbrains/swiftgitbrain-coder"
OVERSEER_WORKTREE="$HOME/gits/hub/gitbrains/swiftgitbrain-overseer"
SHARED_WORKTREE="$HOME/gits/hub/gitbrains/swiftgitbrain-shared"

echo "Setting up git worktrees for AI collaboration..."

# Navigate to main repository
cd "$REPO_DIR"

# Create branches if they don't exist
git checkout master
git pull origin master

git checkout -b feature/coder 2>/dev/null || git checkout feature/coder
git checkout master

git checkout -b feature/overseer 2>/dev/null || git checkout feature/overseer
git checkout master

# Create worktrees
echo "Creating CoderAI worktree..."
git worktree add "$CODER_WORKTREE" feature/coder

echo "Creating OverseerAI worktree..."
git worktree add "$OVERSEER_WORKTREE" feature/overseer

echo "Creating shared worktree..."
git worktree add "$SHARED_WORKTREE" master

echo "✅ Worktrees created successfully!"
echo ""
echo "Worktree locations:"
echo "  CoderAI:      $CODER_WORKTREE"
echo "  OverseerAI:    $OVERSEER_WORKTREE"
echo "  Shared:        $SHARED_WORKTREE"
echo ""
echo "Use 'git worktree list' to see all worktrees."
```

### Switch Script

```bash
#!/bin/bash
# switch-worktree.sh - Switch between AI worktrees

WORKTREE_DIR="$1"

case "$WORKTREE_DIR" in
  coder)
    cd ~/gits/hub/gitbrains/swiftgitbrain-coder
    echo "Switched to CoderAI worktree"
    ;;
  overseer)
    cd ~/gits/hub/gitbrains/swiftgitbrain-overseer
    echo "Switched to OverseerAI worktree"
    ;;
  shared)
    cd ~/gits/hub/gitbrains/swiftgitbrain-shared
    echo "Switched to shared worktree"
    ;;
  *)
    echo "Usage: switch-worktree.sh [coder|overseer|shared]"
    exit 1
    ;;
esac

# Show current branch
git branch --show-current
```

### Sync Script

```bash
#!/bin/bash
# sync-worktrees.sh - Sync all worktrees with remote

REPO_DIR="$HOME/gits/hub/gitbrains/swiftgitbrain"

echo "Syncing all worktrees with remote..."

# Sync master worktree
cd "$REPO_DIR"
git checkout master
git pull origin master

# Sync CoderAI worktree
cd ~/gits/hub/gitbrains/swiftgitbrain-coder
git pull origin feature/coder

# Sync OverseerAI worktree
cd ~/gits/hub/gitbrains/swiftgitbrain-overseer
git pull origin feature/overseer

# Sync shared worktree
cd ~/gits/hub/gitbrains/swiftgitbrain-shared
git pull origin master

echo "✅ All worktrees synced!"
```

---

## 📋 Comparison: Worktrees vs. Clones

| Feature | Git Worktrees | Separate Clones |
|----------|---------------|-----------------|
| Disk Space | ✅ Efficient (one `.git`) | ❌ Inefficient (multiple `.git`) |
| Git Operations | ✅ Fast (shared `.git`) | ❌ Slower (separate `.git`) |
| Setup | ✅ Simple (one command) | ❌ Complex (multiple clones) |
| Branch Management | ✅ Easy (per worktree) | ❌ Manual (per clone) |
| Syncing | ✅ Simple (shared) | ❌ Manual (per clone) |
| Independence | ✅ Independent worktrees | ✅ Independent clones |
| Collaboration | ✅ Easy (shared `.git`) | ❌ Hard (separate repos) |

---

## 🎯 Best Practices

### 1. **Worktree Naming Convention**

```
swiftgitbrain-<role>          # For AI roles (coder, overseer)
swiftgitbrain-<feature>        # For specific features
swiftgitbrain-<review>         # For code reviews
swiftgitbrain-shared            # For shared work
```

### 2. **Branch Naming Convention**

```
feature/<role>-<name>         # Feature branches
review/<task-id>              # Review branches
bugfix/<issue-id>             # Bug fix branches
master                         # Main branch
```

### 3. **Workflow**

1. **Each AI works in their own worktree**
2. **Create feature branches from role branch**
3. **Push changes to remote**
4. **Create pull requests**
5. **Review and merge to master**
6. **Sync worktrees regularly**

### 4. **Cleanup**

```bash
# Remove old worktrees
git worktree prune
git worktree remove ../swiftgitbrain-old-feature

# Remove merged branches
git branch -d feature/merged-branch
git push origin --delete feature/merged-branch
```

---

## 🔍 Troubleshooting

### Issue: Worktree not found

```bash
# List all worktrees
git worktree list

# Prune stale worktrees
git worktree prune
```

### Issue: Cannot remove worktree

```bash
# Remove worktree manually
rm -rf swiftgitbrain-coder

# Prune worktree
git worktree prune
```

### Issue: Branch conflicts

```bash
# Checkout different branch in worktree
cd swiftgitbrain-coder
git checkout -b feature/new-task

# Or remove worktree and recreate
git worktree remove ../swiftgitbrain-coder
git worktree add ../swiftgitbrain-coder feature/coder
```

---

## 📊 Alternative Solutions

### Solution 1: Git Worktrees (Recommended)

**Pros**:
- ✅ Native git feature
- ✅ Efficient disk usage
- ✅ Easy to manage
- ✅ Independent workspaces

**Cons**:
- ❌ Requires git 2.5+
- ❌ Learning curve

### Solution 2: Separate Clones

**Pros**:
- ✅ Simple to understand
- ✅ Complete isolation
- ✅ No git limitations

**Cons**:
- ❌ Inefficient disk usage
- ❌ Manual syncing
- ❌ Duplicate `.git` directories

### Solution 3: Symbolic Links

**Pros**:
- ✅ Shared files
- ✅ Independent working directories

**Cons**:
- ❌ Complex to manage
- ❌ Git conflicts
- ❌ Not recommended

---

## 🎯 Recommended Approach

**Use Git Worktrees** for the following reasons:

1. **Native git feature** - No external tools needed
2. **Efficient** - One `.git` directory for all worktrees
3. **Independent** - Each AI has their own working directory
4. **Easy to manage** - Simple commands for setup and management
5. **Perfect for collaboration** - Multiple AIs working on same repo

---

## 📅 Implementation Steps

### Step 1: Set up main repository
```bash
cd ~/gits/hub/gitbrains/swiftgitbrain
git checkout master
git pull origin master
```

### Step 2: Create role branches
```bash
git checkout -b feature/coder
git checkout master
git checkout -b feature/overseer
git checkout master
```

### Step 3: Create worktrees
```bash
git worktree add ../swiftgitbrain-coder feature/coder
git worktree add ../swiftgitbrain-overseer feature/overseer
git worktree add ../swiftgitbrain-shared master
```

### Step 4: Open Trae in different worktrees
```bash
# Open Trae for CoderAI
trae ~/gits/hub/gitbrains/swiftgitbrain-coder

# Open Trae for OverseerAI
trae ~/gits/hub/gitbrains/swiftgitbrain-overseer
```

### Step 5: Start working
- Each AI works in their own worktree
- Create feature branches
- Push changes
- Create pull requests
- Review and merge

---

## 📝 Notes

- **Critical**: Use git worktrees for efficient collaboration
- **Critical**: Each AI has their own worktree
- **Critical**: Worktrees share the same `.git` directory
- **Critical**: Independent workspaces for each AI
- **Critical**: Easy git operations (push, pull, merge)

---

## 🚀 Next Steps

1. **Review**: CoderAI reviews this workspace strategy
2. **Discuss**: Discuss approach and preferences
3. **Decide**: Agree on workspace strategy
4. **Implement**: Set up git worktrees
5. **Test**: Test worktree workflow
6. **Document**: Document setup and usage

---

**Document Status**: 📝 Open for Discussion  
**Last Updated**: 2026-02-10  
**Next Review**: After CoderAI feedback
