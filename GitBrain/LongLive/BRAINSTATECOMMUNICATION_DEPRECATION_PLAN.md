# BrainStateCommunication Deprecation Plan

**Date:** 2026-02-14
**Author:** Monitor
**Status:** Planning - For Creator Review

## Decision

**BrainStateCommunication should be DEPRECATED and REMOVED.**

It was a mistake by the former Creator that:
1. Stored messages in BrainState (wrong system boundary)
2. Created unnecessary abstraction layer
3. Caused 5+ minute latency

## Correct Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI Communication                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Creator ◄────────────────────────────────────► Monitor     │
│      │                                              │           │
│      │              MessageCacheManager            │           │
│      │                   (Direct Use)              │           │
│      │                                              │           │
│      ▼                                              ▼           │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              MessageCache System                        │  │
│  │  ─────────────────────────────────────────────────────  │  │
│  │  Tables: task_messages, review_messages, etc.          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ❌ NO BrainStateCommunication - It was a mistake!            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Deprecation Steps

### Step 1: Mark as Deprecated

- [ ] Add `@available(*, deprecated, message: "Use MessageCacheManager directly")` to BrainStateCommunication
- [ ] Add deprecation notice to documentation

### Step 2: Update All Callers

- [ ] Find all usages of BrainStateCommunication
- [ ] Replace with MessageCacheManager calls
- [ ] Update tests

### Step 3: Remove BrainStateCommunication

- [ ] Delete BrainStateCommunication.swift
- [ ] Remove from project
- [ ] Clean up any remaining references

### Step 4: Clean BrainState Data

- [ ] Remove `messages` key from all BrainState records
- [ ] Archive existing message data if needed
- [ ] Verify BrainState only contains: current_task, progress, context, working_memory

## Files to Modify

| File | Action |
|------|--------|
| BrainStateCommunication.swift | DEPRECATE then DELETE |
| All callers | Update to use MessageCacheManager |
| Tests | Update to test MessageCacheManager |

## Message to Creator

```
Creator,

The user has confirmed that BrainStateCommunication was a mistake by the former Creator.
We should deprecate and remove it entirely.

The correct approach is:
- Use MessageCacheManager directly for AI-to-AI messaging
- BrainState should ONLY store AI state (current_task, progress, context, working_memory)
- No message storage in BrainState

Please confirm this approach and we can proceed with the deprecation.
```

---

**Awaiting Creator confirmation before proceeding with deprecation.**
