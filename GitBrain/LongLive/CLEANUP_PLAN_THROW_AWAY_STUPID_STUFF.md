# Cleanup Plan: Throw Away Stupid Stuff

## User Instruction
> "Be extremely careful when you are using existing things think it over and over, just throw away those stupid stuff"

## Items Deleted ✅

### 1. BrainStateCommunication.swift
**Path:** `Sources/GitBrainSwift/Communication/BrainStateCommunication.swift`
**Reason:** Stores messages in BrainState JSON - architectural mistake
**Status:** ✅ DELETED

### 2. BrainStateCommunicationTest/
**Path:** `Sources/BrainStateCommunicationTest/`
**Reason:** Tests for wrong implementation
**Status:** ✅ DELETED

### 3. FileBasedCommunication.swift
**Path:** `Sources/GitBrainSwift/Communication/FileBasedCommunication.swift`
**Reason:** File-based polling, 5+ minute latency, the "sick" system
**Status:** ✅ DELETED

### 4. FileBasedCommunicationTests.swift
**Path:** `Tests/GitBrainSwiftTests/FileBasedCommunicationTests.swift`
**Reason:** Tests for file-based "sick" system
**Status:** ✅ DELETED

### 5. PluginTest/
**Path:** `Sources/PluginTest/`
**Reason:** Used FileBasedCommunication
**Status:** ✅ DELETED

### 6. Legacy Message Files
**Path:** `GitBrain/Memory/ToProcess/` (660+ files)
**Reason:** Legacy file-based messages
**Status:** ✅ ARCHIVED to `GitBrain/Memory/Archive/Legacy/`

## Items Kept

- MessageCacheManager
- FluentMessageCacheRepository
- TaskMessageModel, ReviewMessageModel
- TaskType, ReviewComment, TaskStatus, ReviewStatus
- Migrations (CreateTaskMessages, CreateReviewMessages)

## CLI Updated ✅

CLI now uses MessageCacheManager with PostgreSQL:
- `send-task` - Send task messages via database
- `send-review` - Send review messages via database
- `check-tasks` - Check tasks from database
- `check-reviews` - Check reviews from database
- `update-task` - Update task status
- `update-review` - Update review status

## Build Status

- ✅ Build succeeds
- ✅ 163 unit tests pass
- ⚠️ 4 integration tests fail (require PostgreSQL running)

## Status
- Created: 2026-02-14
- Author: Creator
- Status: ✅ COMPLETED
