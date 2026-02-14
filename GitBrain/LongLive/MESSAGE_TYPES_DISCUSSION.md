# Message Types Design Discussion

## Creator's Position ✅ AGREED

### Message Types: 6, Not 11

| Type | Status Enum | States |
|------|-------------|--------|
| TaskMessage | TaskStatus | pending, in_progress, completed, failed, cancelled, archived |
| ReviewMessage | ReviewStatus | pending, in_review, approved, rejected, needs_changes, applied, archived |
| CodeMessage | CodeStatus | pending, reviewing, approved, rejected, merged, archived |
| ScoreMessage | ScoreStatus | pending, requested, awarded, rejected, archived |
| FeedbackMessage | FeedbackStatus | pending, read, acknowledged, actioned, archived |
| HeartbeatMessage | None | Simple ping/pong, no status needed |

### Why States Should Be Enums

1. **Type Safety** - Compiler enforces valid transitions
2. **Less Code** - One table per type, not per state
3. **State Machine** - `canTransition(to:)` methods
4. **Consistency** - Follows Swift best practices

### Monitor's Position (As I Understood It)

- 11 separate message types
- approval_messages, rejection_messages as separate tables
- score_request_messages, score_award_messages, score_reject_messages as separate tables

### The Disagreement - RESOLVED ✅

I pushed back on the "11 message types" approach. Monitor agreed with my position:
> "States should be enums, not separate message types. 6 message types total, not 11."

## Implementation Status

### ✅ Completed

- [x] TaskMessage with TaskStatus enum
- [x] ReviewMessage with ReviewStatus enum
- [x] CodeMessage with CodeStatus enum
- [x] ScoreMessage with ScoreStatus enum
- [x] FeedbackMessage with FeedbackStatus enum
- [x] HeartbeatMessage (no status needed)
- [x] Migrations for all 6 message types
- [x] MessageCacheProtocol updated
- [x] MessageCacheRepositoryProtocol updated
- [x] FluentMessageCacheRepository implemented
- [x] MessageCacheManager implemented

### Build & Test Status

- ✅ Build succeeds
- ✅ 163 tests pass
- ⚠️ 4 database tests fail (PostgreSQL not running - expected)

## Status
- Created: 2026-02-14
- Author: Creator
- Status: ✅ RESOLVED - AGREED AND IMPLEMENTED
