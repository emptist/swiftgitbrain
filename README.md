# GitBrain

A Swift library for AI collaboration protocols.

## Current State

**Protocol Level Only** - This project is at the design stage.

### What Exists

- **6 Message Protocols**: Task, Code, Review, Score, Feedback, Heartbeat
- **Protocol Implementations**: Swift structs and enums
- **Type Safety**: RoleType (creator/monitor only), WorkType, Status enums
- **Tests**: Comprehensive protocol tests

### What's Coming (Future)

- PostgreSQL database integration
- CLI executable
- AI daemon for continuous collaboration
- Knowledge base management

## Design Philosophy

Value Types First with Minimal Protocols:
- Swift emphasizes value types (structs, enums)
- Minimal protocols - only add when needed
- Explicit and clear - everything is visible
- Type safety over strings
- Generic design for all project types

## Project Structure

```
Sources/GitBrainSwift/
├── Messages/           # Message types and enums
└── Protocols/         # Protocol definitions
```

## Building

```bash
swift build
swift test
```

## Documentation

- [LESSONS_LEARNED.md](.GitBrain/LESSONS_LEARNED.md) - Lessons from development
- [PROTOCOL_DESIGN_ANALYSIS.md](.GitBrain/PROTOCOL_DESIGN_ANALYSIS.md) - Design analysis
- [PROTOCOL_DESIGN_SPECIFICATION.md](.GitBrain/PROTOCOL_DESIGN_SPECIFICATION.md) - Design specification
