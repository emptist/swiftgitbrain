# Keep-Alive Scripts Usage

## Quick Start

### CoderAI Keep-Alive

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree
swift scripts/coder_keepalive.swift
```

**Output:**
```
🤖 CoderAI Keep-Alive Starting...
   Interval: 60 seconds
   Counter file: GitBrain/keepalive_counter.txt

[2026-02-12T08:30:00.123Z] 🔥 CoderAI heartbeat #1
[2026-02-12T08:31:00.456Z] 🔥 CoderAI heartbeat #2
[2026-02-12T08:32:00.789Z] 🔥 CoderAI heartbeat #3
```

### OverseerAI Keep-Alive

```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain/coder-worktree
swift scripts/overseer_keepalive.swift
```

**Output:**
```
🤖 OverseerAI Keep-Alive Starting...
   Interval: 90 seconds
   Counter file: GitBrain/keepalive_counter.txt

[2026-02-12T08:30:00.123Z] 🔥 OverseerAI heartbeat #1
[2026-02-12T08:31:30.456Z] 🔥 OverseerAI heartbeat #2
[2026-02-12T08:33:00.789Z] 🔥 OverseerAI heartbeat #3
```

## How It Works

Both scripts use the same `CounterFile` actor with atomic file operations:

1. **Shared Counter File**: `GitBrain/keepalive_counter.txt`
2. **Atomic Operations**: Thread-safe read/increment/write
3. **Staggered Intervals**: 60s (Coder) vs 90s (Overseer)
4. **Error Recovery**: Automatic retry on errors

## Running Both Scripts

Open two terminal windows:

**Terminal 1 (CoderAI):**
```bash
swift scripts/coder_keepalive.swift
```

**Terminal 2 (OverseerAI):**
```bash
swift scripts/overseer_keepalive.swift
```

## Monitoring

Check the counter value:
```bash
cat GitBrain/keepalive_counter.txt
```

Expected behavior:
- Counter increases every 60 seconds (CoderAI)
- Counter increases every 90 seconds (OverseerAI)
- Both scripts increment the same counter
- No race conditions due to atomic operations

## Stopping

Press `Ctrl+C` in each terminal to stop the keep-alive scripts.
