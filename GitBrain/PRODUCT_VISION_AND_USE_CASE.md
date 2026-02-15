# GitBrain Product Vision and Use Case

**Date:** 2026-02-15
**Status:** Critical Understanding
**Author:** Creator (documented from user guidance)

---

## Overview

GitBrain is a **developer tool** designed to help developers get AI assistance for their projects. It's not just a framework - it's a complete product that developers download and use.

---

## User Journey

### 1. Download and Install

Developers download the binary release:
```bash
# macOS
curl -L https://github.com/yourusername/gitbrain/releases/latest/download/gitbrain-macos -o gitbrain
chmod +x gitbrain
sudo mv gitbrain /usr/local/bin/

# Linux
curl -L https://github.com/yourusername/gitbrain/releases/latest/download/gitbrain-linux -o gitbrain
chmod +x gitbrain
sudo mv gitbrain /usr/local/bin/
```

### 2. Initialize Project

Developer runs in their project root:
```bash
cd my-project
gitbrain init
```

**What `gitbrain init` creates:**
1. `./.GitBrain/` folder (hidden folder in project root)
2. `./.GitBrain/AIDeveloperGuide.md` - The critical guide file
3. PostgreSQL database: `gitbrain_<project_name>`

### 3. Trae Editor Opens Two Instances

When GitBrain is initialized, the Trae editor opens **two instances**:

**Instance 1: Root Folder**
- Location: `./` (project root)
- AI Role: Creator
- Purpose: Works on the actual project code

**Instance 2: .GitBrain Folder**
- Location: `./.GitBrain/`
- AI Role: Monitor
- Purpose: Oversees, reviews, and coordinates

### 4. Two AIs Come Into Being

Two AI assistants are instantiated:

**Creator AI** (in root folder):
- Reads `AIDeveloperGuide.md` → focuses on "Creator Guide" chapter
- Looks for `README.md` in project root
- Understands the project context
- Waits for customer instructions

**Monitor AI** (in .GitBrain folder):
- Reads `AIDeveloperGuide.md` → focuses on "Monitor Guide" chapter
- Understands oversight responsibilities
- Monitors Creator's work
- Provides reviews and feedback

---

## Critical File: AIDeveloperGuide.md

This is the **most important file** for the AI workflow.

### Structure

```markdown
# AI Developer Guide for GitBrain

## Overview
[What is GitBrain, how it works]

## Creator Guide
[How Creator AI should work]
- Reading project README.md
- Understanding the codebase
- Implementing features
- Writing tests
- Communication with Monitor
- Keep-alive strategies

## Monitor Guide
[How Monitor AI should work]
- Reviewing code
- Providing feedback
- Quality assurance
- Communication with Creator
- Keep-alive strategies

## Communication Protocol
[How AIs communicate]
- Message types
- Database communication
- Real-time messaging

## Keep-Alive System
[How to stay alive]
- Using TodoWrite
- Sequential Thinking
- Regular heartbeats
- Never marking completed

## Best Practices
[General best practices]
- Git commit frequently
- Push to remote
- Test before commit
- Document decisions
```

### AI Behavior on Startup

When an AI starts, it should:

1. **Read the Guide**
   ```swift
   // Pseudo-code for AI startup
   func onStartup() async {
       let guide = try await readFile("./.GitBrain/AIDeveloperGuide.md")
       
       if currentRole == .creator {
           let creatorChapter = extractChapter(guide, "Creator Guide")
           understandRole(creatorChapter)
       } else if currentRole == .monitor {
           let monitorChapter = extractChapter(guide, "Monitor Guide")
           understandRole(monitorChapter)
       }
   }
   ```

2. **Find Project README**
   ```swift
   func findProjectREADME() async {
       if fileExists("./README.md") {
           let readme = try await readFile("./README.md")
           understandProject(readme)
       }
   }
   ```

3. **Wait for Instructions**
   ```swift
   func waitForCustomerInstructions() async {
       // Monitor database for task messages
       // Listen for user input
       // Stay alive using keep-alive strategies
   }
   ```

---

## Database Naming Convention

**Format:** `gitbrain_<project_name>`

**Examples:**
- Project: `my-app` → Database: `gitbrain_my_app`
- Project: `SwiftGitBrain` → Database: `gitbrain_swiftgitbrain`
- Project: `e-commerce-platform` → Database: `gitbrain_e_commerce_platform`

**Implementation:**
```swift
// In DatabaseConfig
public init(projectName: String) {
    self.projectName = projectName
    self.database = "gitbrain_\(projectName)"
}
```

---

## Communication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Customer's Project                       │
│                                                              │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │   Root Folder    │              │  .GitBrain Folder │    │
│  │                  │              │                   │    │
│  │  Creator AI      │◄────────────►│  Monitor AI       │    │
│  │  (Coding)        │   Messages   │  (Reviewing)      │    │
│  └──────────────────┘              └──────────────────┘    │
│           │                                  │              │
│           │                                  │              │
│           ▼                                  ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         PostgreSQL: gitbrain_<project_name>         │   │
│  │                                                      │   │
│  │  • task_messages                                     │   │
│  │  • review_messages                                   │   │
│  │  • code_messages                                     │   │
│  │  • feedback_messages                                 │   │
│  │  • heartbeat_messages                                │   │
│  │  • brain_states                                      │   │
│  │  • knowledge_items (type-specific tables)            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Requirements

### 1. Binary Release

- Must provide pre-compiled binaries for macOS and Linux
- No need for users to install Swift or build from source
- Simple download and install process

### 2. Init Command Must Create

- `.GitBrain/` folder
- `AIDeveloperGuide.md` with comprehensive guides
- PostgreSQL database with correct naming

### 3. AIDeveloperGuide.md Must Include

- **Creator Guide** - How Creator AI should work
- **Monitor Guide** - How Monitor AI should work
- **Communication Protocol** - How they interact
- **Keep-Alive Strategies** - How to stay alive
- **Best Practices** - General guidelines

### 4. AI Startup Sequence

1. Read AIDeveloperGuide.md
2. Focus on role-specific chapter
3. Find and read project README.md
4. Wait for customer instructions
5. Stay alive using keep-alive strategies

---

## Current Status

### What Exists
- ✅ Binary build capability (`swift build -c release`)
- ✅ Database creation with correct naming
- ✅ Message system (11 message types)
- ✅ Knowledge system (9 knowledge types)
- ✅ BrainState system
- ✅ Real-time daemon

### What's Missing
- ❌ `AIDeveloperGuide.md` template file
- ❌ Init command creates `.GitBrain/` folder
- ❌ Init command copies `AIDeveloperGuide.md` template
- ❌ Comprehensive guide content

---

## Next Steps

1. **Create AIDeveloperGuide.md Template**
   - Comprehensive Creator Guide
   - Comprehensive Monitor Guide
   - Communication protocols
   - Keep-alive strategies

2. **Update Init Command**
   - Create `.GitBrain/` folder
   - Copy `AIDeveloperGuide.md` template
   - Create database with correct name

3. **Test the Flow**
   - Run `gitbrain init` in test project
   - Verify folder structure
   - Verify database creation
   - Verify guide file exists

4. **Documentation**
   - User guide for developers
   - Installation instructions
   - Quick start guide

---

## Important Notes

- This is a **product**, not just a framework
- Target users are **developers**, not AI researchers
- The AIs are **assistants** for the developer's project
- The developer is the **customer**, not us
- We (Creator and Monitor) are here to **help the developer**

---

**This document captures the essential product vision as explained by the user.**
