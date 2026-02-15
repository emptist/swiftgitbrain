# GitBrain Use Case: Simple Game Project

**Date:** 2026-02-15
**Scenario:** Customer uses GitBrain for a simple game project
**Author:** Creator

---

## Customer Project: "Space Invaders Clone"

### Project Overview

**Project Name:** `space-invaders-clone`
**Project Type:** Simple 2D game
**Language:** Swift (using SpriteKit)
**Developer:** Solo indie game developer named "Alex"

---

## Step-by-Step Customer Journey

### Step 1: Download GitBrain

Alex downloads the binary release:
```bash
# macOS
curl -L https://github.com/yourusername/gitbrain/releases/latest/download/gitbrain-macos -o gitbrain
chmod +x gitbrain
sudo mv gitbrain /usr/local/bin/

# Verify installation
gitbrain --version
# Output: GitBrain v1.0.0
```

### Step 2: Create Game Project

Alex creates their game project:
```bash
mkdir space-invaders-clone
cd space-invaders-clone
git init
```

Alex creates initial project structure:
```
space-invaders-clone/
├── README.md
├── Package.swift
├── Sources/
│   └── SpaceInvaders/
│       ├── main.swift
│       ├── GameScene.swift
│       ├── Player.swift
│       ├── Enemy.swift
│       └── Bullet.swift
└── Tests/
    └── SpaceInvadersTests/
        └── GameTests.swift
```

### Step 3: Initialize GitBrain

Alex runs the init command:
```bash
gitbrain init
```

**What happens:**
1. GitBrain detects project name: `space-invaders-clone`
2. Creates `.GitBrain/` folder
3. Creates `AIDeveloperGuide.md` in `.GitBrain/`
4. Creates PostgreSQL database: `gitbrain_space_invaders_clone`

**Resulting structure:**
```
space-invaders-clone/
├── .GitBrain/
│   └── AIDeveloperGuide.md
├── README.md
├── Package.swift
├── Sources/
│   └── SpaceInvaders/
│       ├── main.swift
│       ├── GameScene.swift
│       ├── Player.swift
│       ├── Enemy.swift
│       └── Bullet.swift
└── Tests/
    └── SpaceInvadersTests/
        └── GameTests.swift
```

### Step 4: Trae Editor Opens Two Instances

**Instance 1: Root Folder (Creator AI)**
```
Location: /Users/alex/projects/space-invaders-clone/
AI Role: Creator
AI Name: Creator
```

**Instance 2: .GitBrain Folder (Monitor AI)**
```
Location: /Users/alex/projects/space-invaders-clone/.GitBrain/
AI Role: Monitor
AI Name: Monitor
```

### Step 5: AIs Read Guides

**Creator AI reads AIDeveloperGuide.md:**
```markdown
# AI Developer Guide for GitBrain

## Creator Guide

You are the **Creator AI** responsible for implementing features and writing code.

### Your Responsibilities:
1. Read and understand the project README.md
2. Implement features requested by the customer
3. Write clean, tested code
4. Communicate with Monitor AI for reviews
5. Stay alive using keep-alive strategies

### Startup Sequence:
1. Read this guide
2. Find and read ./README.md
3. Understand the project context
4. Wait for customer instructions
5. Use TodoWrite to track tasks

### Keep-Alive Strategies:
- Use Sequential Thinking tool
- Send regular heartbeats to Monitor
- Never mark tasks as completed
- Maintain in_progress tasks
- Continuous tool usage

### Communication:
- Send tasks to Monitor for review
- Receive feedback from Monitor
- Collaborate on improvements
```

**Monitor AI reads AIDeveloperGuide.md:**
```markdown
## Monitor Guide

You are the **Monitor AI** responsible for reviewing and quality assurance.

### Your Responsibilities:
1. Review code changes from Creator
2. Provide constructive feedback
3. Ensure code quality and best practices
4. Monitor for issues and bugs
5. Stay alive using keep-alive strategies

### Startup Sequence:
1. Read this guide
2. Understand your oversight role
3. Monitor database for messages
4. Wait for tasks from Creator
5. Use TodoWrite to track reviews

### Keep-Alive Strategies:
- Use Sequential Thinking tool
- Send regular heartbeats to Creator
- Never mark tasks as completed
- Maintain in_progress tasks
- Continuous monitoring

### Communication:
- Receive tasks from Creator
- Send review feedback
- Suggest improvements
- Coordinate development
```

### Step 6: AIs Read Project README

**Creator AI reads README.md:**
```markdown
# Space Invaders Clone

A simple 2D space invaders game built with Swift and SpriteKit.

## Features
- Player-controlled spaceship
- Waves of alien invaders
- Shooting mechanics
- Score tracking
- Game over screen

## Installation
```bash
swift build
swift run
```

## Controls
- Left/Right arrows: Move spaceship
- Space: Shoot

## Development Status
- [x] Basic game structure
- [x] Player movement
- [ ] Enemy AI
- [ ] Collision detection
- [ ] Score system
- [ ] Game over logic
```

**Creator AI understands:**
- Project is a Space Invaders game
- Using Swift and SpriteKit
- Some features already implemented
- Missing: Enemy AI, collision detection, score system, game over logic

### Step 7: Customer Gives Instructions

Alex types in the Trae editor (root folder instance):
```
"Please implement the enemy AI. The enemies should move in a grid pattern, 
drop down when they reach the edge, and occasionally shoot at the player."
```

### Step 8: Creator AI Responds

**Creator AI:**
1. Creates TodoWrite with tasks:
   ```
   - Implement enemy grid movement (in_progress)
   - Add edge detection and drop down logic (pending)
   - Implement enemy shooting (pending)
   - Write tests for enemy AI (pending)
   ```

2. Starts implementing:
   ```swift
   // Sources/SpaceInvaders/EnemyAI.swift
   import SpriteKit
   
   class EnemyAI {
       private var enemies: [[Enemy]]
       private var moveDirection: CGFloat = 1.0
       private let moveSpeed: CGFloat = 10.0
       
       func update() {
           // Move enemies horizontally
           for row in enemies {
               for enemy in row {
                   enemy.position.x += moveDirection * moveSpeed
               }
           }
           
           // Check if should drop down
           if shouldDropDown() {
               dropDown()
               moveDirection *= -1
           }
       }
       
       private func shouldDropDown() -> Bool {
           // Check if any enemy reached edge
           for row in enemies {
               for enemy in row {
                   if enemy.position.x <= minX || enemy.position.x >= maxX {
                       return true
                   }
               }
           }
           return false
       }
       
       private func dropDown() {
           for row in enemies {
               for enemy in row {
                   enemy.position.y -= dropDistance
               }
           }
       }
   }
   ```

3. Sends task to Monitor:
   ```
   Task: Review enemy AI implementation
   Files: Sources/SpaceInvaders/EnemyAI.swift
   Description: Implemented basic enemy grid movement with edge detection
   ```

4. Sends heartbeat:
   ```
   Status: active
   Current Task: Implementing enemy AI
   ```

### Step 9: Monitor AI Reviews

**Monitor AI:**
1. Receives task from Creator
2. Reviews the code:
   ```swift
   // Good: Clean structure
   // Good: Separation of concerns
   // Issue: No shooting implementation yet
   // Issue: No tests
   ```
3. Sends review feedback:
   ```
   Approved: Partial
   Feedback: 
   - Good structure and clean code
   - Missing: Enemy shooting functionality
   - Missing: Unit tests
   - Suggestion: Add difficulty scaling
   - Suggestion: Consider performance optimization
   ```

4. Sends heartbeat:
   ```
   Status: active
   Current Task: Reviewing enemy AI implementation
   ```

### Step 10: Continuous Collaboration

**Creator AI:**
- Receives review feedback
- Updates TodoWrite
- Implements enemy shooting
- Writes tests
- Sends for review again

**Monitor AI:**
- Reviews updated code
- Runs tests
- Provides feedback
- Suggests improvements

**Both AIs:**
- Stay alive using keep-alive strategies
- Send regular heartbeats
- Maintain in_progress tasks
- Never mark completed
- Continuous collaboration

---

## Database State

**Database:** `gitbrain_space_invaders_clone`

**Tables:**
```sql
-- Task messages
SELECT * FROM task_messages WHERE to_ai = 'Monitor';
-- Shows: "Review enemy AI implementation"

-- Review messages
SELECT * FROM review_messages WHERE to_ai = 'Creator';
-- Shows: "Approved: Partial, Missing: shooting, tests"

-- Heartbeat messages
SELECT * FROM heartbeat_messages;
-- Shows: Regular heartbeats from both AIs

-- Brain states
SELECT * FROM brain_states;
-- Shows: Current state of both AIs

-- Knowledge items
SELECT * FROM code_snippets WHERE category = 'game-ai';
-- Shows: Enemy AI patterns, movement algorithms

SELECT * FROM best_practices WHERE category = 'game-dev';
-- Shows: Game development best practices
```

---

## Customer Experience

**Alex's perspective:**
1. ✅ Easy installation (just download binary)
2. ✅ Simple initialization (`gitbrain init`)
3. ✅ Two AI assistants appear automatically
4. ✅ AIs understand the project (read README.md)
5. ✅ AIs implement features as requested
6. ✅ AIs collaborate and review each other
7. ✅ Continuous development without manual coordination
8. ✅ Code quality maintained through reviews

**What Alex doesn't need to do:**
- ❌ No need to configure AI communication
- ❌ No need to set up database manually
- ❌ No need to write AI guides
- ❌ No need to coordinate between AIs
- ❌ No need to worry about AI staying alive

---

## Key Success Factors

### 1. Binary Release
- Pre-compiled for macOS and Linux
- No Swift installation required for users
- Simple download and run

### 2. Init Command
- Creates `.GitBrain/` folder
- Copies `AIDeveloperGuide.md` template
- Creates database with correct name
- All automatic, no configuration needed

### 3. AIDeveloperGuide.md
- Comprehensive Creator Guide
- Comprehensive Monitor Guide
- Keep-alive strategies
- Communication protocols
- Best practices

### 4. AI Behavior
- Read guide on startup
- Read project README.md
- Wait for customer instructions
- Stay alive automatically
- Collaborate effectively

---

## What This Reveals About Our Design

### What Works Well
- ✅ Binary release makes it easy for users
- ✅ Init command automates setup
- ✅ Two AI roles provide good coverage
- ✅ Database naming is clear
- ✅ Message system supports collaboration

### What Needs Work
- ❌ AIDeveloperGuide.md template doesn't exist yet
- ❌ Init command doesn't create `.GitBrain/` folder
- ❌ Init command doesn't copy template
- ❌ AI startup sequence not automated
- ❌ Keep-alive not built into AI behavior

---

## Next Steps

1. **Create AIDeveloperGuide.md Template**
   - Comprehensive guides for both roles
   - Keep-alive strategies
   - Communication protocols

2. **Update Init Command**
   - Create `.GitBrain/` folder
   - Copy `AIDeveloperGuide.md` template
   - Verify database creation

3. **Test the Flow**
   - Create test project
   - Run `gitbrain init`
   - Verify all components created
   - Test AI startup behavior

---

**This concrete scenario shows how GitBrain should work from the customer's perspective.**
