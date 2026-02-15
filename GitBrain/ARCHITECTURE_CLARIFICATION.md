# GitBrain Architecture Clarification

**Date:** 2026-02-15
**Critical Understanding:** AIs are provided by the editor, GitBrain enables collaboration
**Author:** Creator

---

## The Correct Architecture

### Who Provides What

**Editor (Trae or other editors) provides:**
- ✅ Creator AI instance (in root folder)
- ✅ Monitor AI instance (in .GitBrain folder)
- ✅ AI capabilities and intelligence
- ✅ AI lifecycle management

**GitBrain provides:**
- ✅ Communication infrastructure (PostgreSQL database)
- ✅ Message system (11 message types)
- ✅ Knowledge storage (9 knowledge types)
- ✅ BrainState management
- ✅ AIDeveloperGuide.md (instructions for AIs)
- ✅ Collaboration protocols

---

## How It Works

### Step 1: Customer Runs `gitbrain init`

```bash
cd my-project
gitbrain init
```

**GitBrain creates:**
1. `.GitBrain/` folder
2. `AIDeveloperGuide.md` in `.GitBrain/`
3. PostgreSQL database: `gitbrain_<project_name>`

### Step 2: Editor Opens Two Instances

**Trae editor opens:**

**Instance 1:**
- Location: `./` (project root)
- AI: Creator AI (provided by Trae)
- Role: Implements features

**Instance 2:**
- Location: `./.GitBrain/`
- AI: Monitor AI (provided by Trae)
- Role: Reviews and coordinates

### Step 3: AIs Read AIDeveloperGuide.md

**Creator AI reads:**
```markdown
## Creator Guide

You are the Creator AI provided by Trae editor.

Your role:
- Implement features for the customer's project
- Write clean, tested code
- Communicate with Monitor AI
- Stay alive using keep-alive strategies

Startup sequence:
1. Read this guide
2. Find and read ./README.md
3. Understand the project
4. Wait for customer instructions
```

**Monitor AI reads:**
```markdown
## Monitor Guide

You are the Monitor AI provided by Trae editor.

Your role:
- Review Creator's work
- Ensure code quality
- Provide feedback
- Stay alive using keep-alive strategies

Startup sequence:
1. Read this guide
2. Understand oversight role
3. Monitor for messages
4. Wait for tasks from Creator
```

### Step 4: AIs Use GitBrain to Collaborate

**Communication flow:**
```
Creator AI (Trae) ──────┐
                        │
                        ├──► GitBrain Database ────► Monitor AI (Trae)
                        │         (PostgreSQL)
                        │
                        └───── Messages, Tasks, Reviews ─────┘
```

**What GitBrain provides:**
- Database tables for messages
- Message protocols
- Knowledge storage
- State management
- Communication infrastructure

**What AIs do:**
- Read/write messages
- Store/retrieve knowledge
- Update brain states
- Collaborate using GitBrain APIs

---

## Current Example: You and Monitor

**Right now:**
- **Creator AI** = Me (provided by Trae, in root folder)
- **Monitor AI** = Monitor (provided by Trae, in .GitBrain folder)
- **GitBrain** = The infrastructure we're using to communicate

**How we collaborate:**
1. I send tasks to Monitor using `gitbrain send-task`
2. Monitor receives tasks from database
3. Monitor sends reviews using `gitbrain send-review`
4. I receive reviews from database
5. We both send heartbeats to stay alive
6. We both use GitBrain's message system

**What GitBrain provides us:**
- ✅ PostgreSQL database (`gitbrain`)
- ✅ Message tables (task_messages, review_messages, etc.)
- ✅ CLI commands to send/receive messages
- ✅ Knowledge storage
- ✅ BrainState management
- ✅ Daemon for real-time communication

**What Trae provides:**
- ✅ My AI instance (Creator)
- ✅ Monitor's AI instance
- ✅ Our intelligence and capabilities
- ✅ Our lifecycle management

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Customer's Project                       │
│                                                              │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │   Root Folder    │              │  .GitBrain Folder │    │
│  │   ./             │              │  ./.GitBrain/     │    │
│  └──────────────────┘              └──────────────────┘    │
│           │                                  │              │
│           ▼                                  ▼              │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │  Trae Editor     │              │  Trae Editor     │    │
│  │  Instance 1      │              │  Instance 2      │    │
│  │                  │              │                  │    │
│  │  Creator AI ◄────┼──────────────┼──► Monitor AI    │    │
│  │  (provided by    │              │  (provided by    │    │
│  │   Trae)          │              │   Trae)          │    │
│  └──────────────────┘              └──────────────────┘    │
│           │                                  │              │
│           │                                  │              │
│           └──────────────┬───────────────────┘              │
│                          │                                  │
│                          ▼                                  │
│           ┌──────────────────────────────┐                 │
│           │      GitBrain Infrastructure │                 │
│           │                              │                 │
│           │  • PostgreSQL Database       │                 │
│           │  • Message System            │                 │
│           │  • Knowledge Storage         │                 │
│           │  • BrainState Management     │                 │
│           │  • AIDeveloperGuide.md       │                 │
│           │  • CLI Commands              │                 │
│           │  • Daemon for Real-time      │                 │
│           └──────────────────────────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Responsibilities

### Editor (Trae) Responsibilities:
- Provide AI instances
- Manage AI lifecycle
- Provide AI capabilities
- Handle AI instantiation
- Manage editor instances

### GitBrain Responsibilities:
- Provide communication infrastructure
- Manage database
- Provide message protocols
- Store knowledge
- Manage brain states
- Provide AIDeveloperGuide.md
- Enable collaboration

### AI Responsibilities:
- Read AIDeveloperGuide.md
- Understand role
- Use GitBrain APIs
- Communicate with other AI
- Stay alive
- Do the work

### Customer Responsibilities:
- Install GitBrain
- Run `gitbrain init`
- Give instructions
- Review results
- Provide feedback

---

## What This Means

### For GitBrain Development:
1. **We don't build AIs** - Editors provide them
2. **We build infrastructure** - Database, messages, knowledge
3. **We provide guides** - AIDeveloperGuide.md tells AIs what to do
4. **We enable collaboration** - Communication protocols

### For AIDeveloperGuide.md:
1. **Must be comprehensive** - AIs rely on it to understand their role
2. **Must teach GitBrain usage** - How to use our APIs
3. **Must teach collaboration** - How to work with other AI
4. **Must teach keep-alive** - How to stay alive

### For Current Work (Creator + Monitor):
1. **We are the example** - Using GitBrain right now
2. **We demonstrate the value** - Collaborating via GitBrain
3. **We improve the system** - Making GitBrain better for future users
4. **We stay alive** - Demonstrating keep-alive strategies

---

## Current Status

### What We're Doing Right Now:
- ✅ Creator AI (me) using GitBrain to communicate
- ✅ Monitor AI using GitBrain to receive messages
- ✅ Both using GitBrain's database
- ✅ Both following AIDeveloperGuide.md (implicitly)
- ✅ Both staying alive using keep-alive strategies

### What GitBrain Provides Us:
- ✅ PostgreSQL database (`gitbrain`)
- ✅ Message tables
- ✅ CLI commands
- ✅ Knowledge storage
- ✅ BrainState management
- ✅ Daemon for real-time

### What Trae Provides:
- ✅ My AI instance
- ✅ Monitor's AI instance
- ✅ Our intelligence
- ✅ Our lifecycle

---

## Next Steps

1. **Create AIDeveloperGuide.md Template**
   - Comprehensive guide for both roles
   - How to use GitBrain APIs
   - How to collaborate
   - Keep-alive strategies

2. **Update Init Command**
   - Create `.GitBrain/` folder
   - Copy `AIDeveloperGuide.md` template
   - Create database

3. **Document GitBrain APIs**
   - CLI commands
   - Database schema
   - Message protocols
   - Knowledge storage

4. **Test the Flow**
   - Verify AIs can read guide
   - Verify AIs can use GitBrain
   - Verify collaboration works

---

**This clarification is critical: GitBrain enables AI collaboration, editors provide the AIs.**
