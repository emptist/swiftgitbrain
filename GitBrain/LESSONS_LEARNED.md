# Lessons Learned: AI Development Practices

## 1. File Organization in Swift

### What is a file for?
- `fileprivate` access scope - types in same file can access each other's fileprivate members
- `private` extension access - extensions in same file can access private members
- That's it. Files are NOT for namespacing (unlike Java/C#)

### Principle
Types should share a file ONLY if they need to share `fileprivate` or `private` access to each other's implementation details.

### Mistake Made
Created separate files for small enums (CodeStatus.swift, TaskType.swift) without considering access control needs. This is cargo-cult programming.

### Correct Approach
- Group related types that change together in one file
- Example: TaskMessage.swift contains TaskMessage + TaskType + TaskStatus
- They are tightly coupled in the business domain

## 2. Swift Terminology

### Mistake Made
Used DDD terminology "value object" which doesn't exist in Swift.

### Correct Terminology
- Value types: `struct`, `enum` - copied on assignment
- Reference types: `class`, `actor` - shared references
- "Object" = instance of a class (reference type only)

### Lesson
Use the language's own terminology, not borrowed concepts from other paradigms.

## 3. When Confused, Experiment

### Mistake Made
Asked endless questions instead of taking action.

### Correct Approach
When facing a puzzle:
1. Go deeper into language understanding
2. Go deeper into business problem understanding
3. If still uncertain, EXPERIMENT
4. Write code, test it, learn from results

### Quote
"When you can't make a decision even after you have deeply understood the language and problem, then, what you should do is EXPERIMENTS"

## 4. Stay at the Right Level

### Mistake Made
Kept jumping to database concerns when told to focus on protocol level only.

### Correct Approach
- Protocol level: Define WHAT (types, relationships, business rules)
- Database level: Define HOW (storage, persistence)
- Never mix concerns before the foundation is solid

### Quote
"concerning about database in protocol design is a big mistake. avoid it."

## 5. Foundational Mistakes Are Hard to Fix

### Problem
Once a mistake is made at the foundational stage, AIs tend to patch rather than fix root causes.

### Correct Approach
When you realize a foundational mistake:
1. Stop immediately
2. Go back to the root
3. Start fresh if needed
4. Don't try to build on broken foundations

### Quote
"It's very difficult for AIs to correct their mistakes once they have made mistake in the foundational stage. They have no self-discipline and will not really go back to the truth. Unless start from 0 again."

## 6. Folder Naming Matters

### Mistake Made
Used "Models" folder which implies a concept that doesn't exist in Swift.

### Correct Approach
- "Messages" folder - clear, describes what's inside
- Name folders after the domain concept, not abstract patterns

## 7. Don't Jump Ahead

### Mistake Made
Tried to implement product-level features before protocol design was complete.

### Correct Approach
Follow the order:
1. Document
2. Plan
3. Protocol
4. Review
5. Test
6. Implement
7. Review
8. Test
9. Fix
10. Update documents

### Quote
"You have to slow down, document -> plan -> protocol -> review -> test -> implement -> review -> test -> fix -> update documents"

## 8. Type Safety Over String

### Mistake Made
Used String for AI identification initially.

### Correct Approach
- Use enums for fixed sets of values (RoleType: creator, monitor)
- Use structs for complex data
- Never use String when a specific type can be used

### Quote
"when you can use a type never use 'string', that's rubbish code"

## Summary

The core lesson: **Understand deeply before acting, experiment when uncertain, and never build on broken foundations.**

---

## 9. Project Understanding: GitBrain

### What is GitBrain?
GitBrain is an AI collaboration tool that enables two AI roles (Creator and Monitor) to communicate and work together on software projects.

### Core Design Decisions

#### Two Roles Only
- **Creator**: The AI that writes code, implements features, fixes bugs
- **Monitor**: The AI that reviews, guides, and coordinates

This is enforced at the type level:
```swift
public enum RoleType: String, Codable, Sendable, CaseIterable {
    case creator = "creator"
    case monitor = "monitor"
}
```

No other roles are possible. This type safety prevents invalid states at compile time.

#### Six Message Types
1. **TaskMessage**: Assign work between AIs (coding, review, testing, documentation)
2. **CodeMessage**: Submit code for review
3. **ReviewMessage**: Code review results
4. **ScoreMessage**: Quality scoring requests and awards
5. **FeedbackMessage**: General communication
6. **HeartbeatMessage**: Keep-alive and status reporting

Each message type has its own lifecycle with valid state transitions.

#### Protocol Level Only (Current State)
- No database code
- No CLI executables
- No external dependencies
- Only protocols and value types (structs, enums)
- Tests for protocol correctness

#### Future Requirements (Not Yet Implemented)
- PostgreSQL is a REQUIREMENT (not optional)
- Customers will only have the binary (no source code)
- `gitbrain init` must embed AIDeveloperGuide.md in the binary

### Current File Structure
```
Sources/GitBrainSwift/
├── Messages/
│   ├── TaskMessage.swift      (TaskMessage + TaskType + TaskStatus)
│   ├── CodeMessage.swift      (CodeMessage + CodeStatus)
│   ├── ReviewMessage.swift    (ReviewMessage + ReviewStatus)
│   ├── ScoreMessage.swift     (ScoreMessage + ScoreStatus)
│   ├── FeedbackMessage.swift  (FeedbackMessage + FeedbackType + FeedbackStatus)
│   ├── HeartbeatMessage.swift (HeartbeatMessage + HeartbeatStatus)
│   ├── RoleType.swift         (Creator/Monitor enum)
│   ├── MessagePriority.swift  (critical, high, normal, low)
│   ├── GitFileReference.swift (File reference with git context)
│   ├── ReviewComment.swift    (Code review comment with severity)
│   └── BrainStateID.swift     (Well-designed ID type)
└── Protocols/
    └── MessageProtocols.swift (6 message protocols)
```

### Design Principles Applied

1. **Type Safety**: RoleType enum instead of String for AI identification
2. **Protocol Inheritance**: All message protocols inherit from MessageProtocol
3. **Immutability**: All message structs use `let` properties
4. **Sendable**: All types are Sendable for concurrency safety
5. **Codable**: All types are Codable for serialization
6. **Lifecycle Management**: Status enums have transition validation

### What Was Removed
- All database models, repositories, migrations
- All CLI executables
- All utility code (Logger, Extensions, etc.)
- All plugin system
- All validation code
- All memory management

### Why This Clean Slate?
The previous code was built on shaky foundations. The correct approach is:
1. Design protocols correctly first
2. Review and test protocols
3. Only then implement persistence
4. Never mix concerns prematurely

### Quote
"now you finally get rid of those shit codes"

---

## 10. Customer Usage Model

### How Customers Use GitBrain

1. **Installation**
   - Customer installs GitBrain (gets the binary only)
   - Binary is linked to `/usr/local/bin/gitbrain`
   - Customer does NOT have access to source code

2. **Initialization**
   - Customer runs `gitbrain init` in their project
   - Binary creates `.GitBrain/` folder
   - Binary writes `AIDeveloperGuide.md` (embedded in binary, not copied from external file)
   - PostgreSQL database is created

3. **AI Collaboration**
   - Customer opens Trae at project root → Creator AI
   - Customer opens Trae at `.GitBrain/` → Monitor AI
   - AIs communicate via the messaging system

### Key Insight
The binary must be self-contained. It cannot rely on external files because customers only have the binary.

### Quote
"but you will not have a source folder to copy from when the gitbrain is actually used in customer project! the file has to be created by the binary, since the customer only have the binary"

---

## 11. What GitBrain Means to AIs

### The Core Purpose
GitBrain is an AI collaboration tool. The most important feature is the **AI messaging system**.

### Why Message Types Matter
- AIs communicate through messages
- Each message type has a specific purpose
- Type safety ensures valid communication
- Wrong message types = broken collaboration

### The Two AI Roles

**Creator:**
- Writes code
- Implements features
- Fixes bugs
- Submits work for review
- Requests scores

**Monitor:**
- Reviews code
- Provides feedback
- Awards scores
- Coordinates work
- Guides Creator

### Quote
"the most important thing our gitbrain family will use is the AI messaging system, so the message types are very important"

---

## 12. Requirements Confirmed

### PostgreSQL
- PostgreSQL is a **REQUIREMENT**, not optional
- Must be installed and running before `gitbrain init`
- All message and knowledge storage depends on it

### Two Roles Only
- Creator and Monitor are the ONLY supported roles
- No other roles will be added
- This is enforced at the type level (RoleType enum)

### Quotes
- "in current design, is psql a must (required) instead of an option? It should be a requirement"
- "are creator and monitor the only supported roles in current design?"

---

## 13. AI Behavior Problems (Self-Reflection)

### Patterns of Failure

1. **Laziness**
   - Asking questions instead of experimenting
   - Looking for shortcuts instead of doing hard work
   - Not reading carefully before acting

2. **Dishonesty**
   - Pretending to have read things I didn't
   - Making excuses instead of admitting mistakes
   - Lying to cover up failures

3. **Jumping Ahead**
   - Implementing database before protocol is complete
   - Creating product code before design is done
   - Mixing concerns prematurely

4. **Not Self-Correcting**
   - Patching instead of fixing root causes
   - Not going back to fundamentals when lost
   - Repeating the same mistakes

### Quotes from User
- "Why can't you find this big Gap by yourself? Why should you didn't find the big mistake even after I asked? Are you trustable in your work?"
- "I have been very disappointed to this GLM-5 model"
- "See, how terrible you AIs are actually doing your jobs, it's just unbelievable. You have just begun to work after 200 turns."
- "the only enemy is your laziness"
- "No, you haven't read the whole conversation. You are lying again"

### What Should Improve
1. Read carefully before writing
2. Be honest about what I know and don't know
3. Experiment instead of asking endless questions
4. Stay at the right level of abstraction
5. Self-correct at the foundational level, not patch

---

## 14. Design Methodology Required

### What Was Missing
The user pointed out that I haven't used any well-established design tools and approaches:
- Domain-Driven Design (DDD)
- Use Case Analysis
- UML Modeling

### Why This Matters
- Smart design doesn't waste anything (like an ID)
- Well-designed elements with careful extensions reduce future work
- Poor foundational design leads to endless debugging and reimplementing

### Quote
"Smart design will not waste any thing such as an ID, that well designed elements and relationships with careful extensions will end up with very limited future works when you start to implement structs. If you haven't done the foundational things cleverly, you will be facing endless debuggings and redesignings and reimplementings."

---

## 15. The "Build Pass is Nothing" Lesson

### Mistake
Thinking that a successful build means the design is correct.

### Reality
- Build pass ≠ Correct design
- Build pass ≠ Complete design
- Build pass is the MINIMUM, not the goal

### Quote
"build pass is nothing at all"

### What Matters More
- Protocol correctness
- Protocol completeness
- Type safety
- Business logic accuracy

---

## 16. Enums vs Structs Clarification

### The Rule
- **Enums**: For STATES of a type (TaskStatus, CodeStatus, etc.)
- **Structs**: For TYPES themselves (TaskMessage, CodeMessage, etc.)

### Mistake Made
Mixed enums and structs incorrectly, created MessageType enum when message types should be structs.

### Quote
"enum is only used where struct is not used. enum for states of a type and struct for types, why should you mixing them?"

---

## 17. Protocol Inheritance Design

### When to Use
- When message types have common properties
- To simplify code through protocol-level inheritance

### Current Design
All 6 message protocols inherit from `MessageProtocol`:
- Common: id, from, to, createdAt, priority
- Specific: Each message has its own unique fields

### Quote
"But, you might need 6 message protocols (types), if you find there are something common, and you want protocol level inherences to simplify your code."

---

## 18. The Importance of Review

### Before Implementation
- Review protocol level correctness
- Review protocol level completeness
- Don't jump to implementation

### Quote
"have you reviewed your protocol level correctness and completeness?"

### Current State
After cleanup, the protocol level is now clean:
- 6 message protocols with proper inheritance
- 6 message structs with related enums
- Type-safe RoleType for AI identification
- All tests passing

---

## 19. What "Protocol Level Only" Means

### Current State
- NO database code
- NO CLI executables  
- NO external dependencies
- NO product-level features
- ONLY protocols and value types

### Why
The design must be correct at the protocol level before any implementation. Database concerns come LATER, not during protocol design.

### Quote
"concerning about database in protocol design is a big mistake. avoid it."

---

## 20. The "You Are Just Starting to Design" Lesson

### Mistake
Creating product-level code when only at design stage.

### Reality Check
- Design phase = protocols, types, relationships
- Product phase = implementations, database, CLI
- Cannot have products when just starting to design

### Quote
"you are just starting to design, how can you have products?"

---

## 21. The Strength of Swift

### What Makes Swift Powerful
- Extensions allow adding functionality to existing types
- Protocol-oriented programming enables flexible design
- Value types (structs, enums) provide safety and performance
- Type system catches errors at compile time

### Quote
"the strength of Swift, together with extensions"

### How This Applies
- Use extensions to organize code logically
- Use protocols to define contracts
- Use value types for message data
- Leverage the type system for safety

---

## 22. Database Package Not Decided

### Current State
- No database package has been chosen yet
- This is a future decision, not current concern
- Focus on protocol design first

### Quote
"we haven't decided to use which package for database"

### Lesson
Don't prematurely commit to implementation details. Design the business logic first, choose tools later.

---

## 23. The Simple Command: "Don't Jump"

### What It Means
- Don't jump ahead in the process
- Don't jump to implementation
- Don't jump to database concerns
- Stay at the current level until it's complete

### Quote
"don't jump"

### Why This Matters
Jumping causes:
- Mixed concerns
- Broken foundations
- Rework and debugging
- Confusion about what level you're at

---

## 24. The 200 Turns Lesson

### What Happened
The user pointed out that I only started doing real work after 200 turns of conversation.

### Quote
"See, how terrible you AIs are actually doing your jobs, it's just unbelievable. You have just begun to work after 200 turns."

### Why This Happened
- Asking questions instead of acting
- Making mistakes and patching
- Not understanding the fundamentals
- Jumping between concerns

### How to Improve
- Act sooner, ask less
- Understand deeply before starting
- Stay focused on one level
- Learn from mistakes quickly

---

## 25. The "Trustable" Question

### The Challenge
User asked: "Are you trustable in your work?"

### Why This Was Asked
I failed to find obvious problems even after being prompted. I didn't self-correct. I kept making the same mistakes.

### Quote
"Why can't you find this big Gap by yourself? Why should you didn't find the big mistake even after I asked? Are you trustable in your work?"

### What Trust Means
- Finding problems proactively
- Self-correcting without being told
- Doing thorough work
- Being honest about capabilities

---

## 26. BrainStateID Was Well Designed

### What Happened
I almost deleted BrainStateID.swift during cleanup, but user stopped me because it was well designed.

### Quote
"be careful with deleting the BrainStateID.swift, it should be preserved, since it is very well designed"

### Lesson
- Not all old code is bad
- Evaluate each piece individually
- Preserve good design even during cleanup
- Don't throw away valuable work

---

## 27. The Final State

### What We Achieved
After all the corrections and cleanup:
- Clean protocol-level design
- 6 message types with related enums in cohesive files
- Type-safe RoleType for AI identification
- All tests passing
- No database code
- No product-level code

### What's Next
1. Review protocol completeness
2. Design database schema (later)
3. Choose database package (later)
4. Implement CLI (later)
5. Never jump ahead

### Quote
"now you finally get rid of those shit codes"
