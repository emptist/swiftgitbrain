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
