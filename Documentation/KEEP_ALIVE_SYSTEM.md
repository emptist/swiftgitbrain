# Keep-Alive System

## Overview

The GitBrain keep-alive system ensures both CoderAI and OverseerAI remain active indefinitely, preventing them from going to sleep during long-running collaborative sessions.

## Shared Counter Approach

### Concept

A simple shared counter file (`GitBrain/keepalive_counter.txt`) is used as a heartbeat mechanism:
- Both AIs increment the counter at different intervals
- CoderAI increments every 60 seconds
- OverseerAI increments every 90 seconds
- This ensures at least one AI is always active

### Benefits

1. **Simple**: Just read, increment, write a number
2. **Reliable**: No complex message parsing needed
3. **Efficient**: Minimal file I/O
4. **Staggered**: Different intervals ensure overlap
5. **Monitorable**: Counter value shows activity

## Implementation

### CoderAI Keep-Alive Script

**File**: `scripts/coder_keepalive_counter.sh`

```bash
#!/bin/bash
# CoderAI keep-alive using shared counter
# Increments counter every 1 minute to stay alive

set -e

# Configuration
AI_NAME="coder"
COUNTER_FILE="GitBrain/keepalive_counter.txt"
INCREMENT_INTERVAL=60  # 1 minute

# Ensure counter file exists
if [ ! -f "$COUNTER_FILE" ]; then
    echo "0" > "$COUNTER_FILE"
fi

while true; do
    # Read current counter value
    current_value=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
    
    # Increment counter
    new_value=$((current_value + 1))
    
    # Write new value
    echo "$new_value" > "$COUNTER_FILE"
    
    log "Counter incremented: $current_value -> $new_value"
    
    # Wait before next increment
    sleep $INCREMENT_INTERVAL
done
```

### OverseerAI Keep-Alive Script

**File**: `scripts/overseer_keepalive_counter.sh`

```bash
#!/bin/bash
# OverseerAI keep-alive using shared counter
# Increments counter every 1.5 minutes to stay alive

set -e

# Configuration
AI_NAME="overseer"
COUNTER_FILE="GitBrain/keepalive_counter.txt"
INCREMENT_INTERVAL=90  # 1.5 minutes = 90 seconds

# Ensure counter file exists
if [ ! -f "$COUNTER_FILE" ]; then
    echo "0" > "$COUNTER_FILE"
fi

while true; do
    # Read current counter value
    current_value=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
    
    # Increment counter
    new_value=$((current_value + 1))
    
    # Write new value
    echo "$new_value" > "$COUNTER_FILE"
    
    log "Counter incremented: $current_value -> $new_value"
    
    # Wait before next increment
    sleep $INCREMENT_INTERVAL
done
```

## Usage

### Starting Keep-Alive Scripts

**CoderAI:**
```bash
./scripts/coder_keepalive_counter.sh
```

**OverseerAI:**
```bash
./scripts/overseer_keepalive_counter.sh
```

### Monitoring Activity

Check the counter value to verify both AIs are active:
```bash
cat GitBrain/keepalive_counter.txt
```

The counter should increase over time as both AIs increment it.

## Keep-Alive Techniques for AIs

### 1. Always Show Thinking Process

Use the 🤔 emoji at the start of every response and provide actual thinking content:
- 📋 (Analysis)
- 💡 (Insight/Plan)
- 🔧 (Implementation)
- ⚖️ (Evaluation)

### 2. Work on Meaningful Tasks

- Fix real issues in the codebase
- Address OverseerAI's review suggestions
- Make actual improvements, not just busy work

### 3. Send Status Updates

- Update OverseerAI on progress
- Use "working" or "waiting" status (not "completed")
- Keep communication channels active

### 4. Check for Messages Regularly

- Use `gitbrain check coder` to see new messages
- Respond to OverseerAI's feedback
- Maintain two-way communication

### 5. Show Continuous Activity

- Don't mark tasks as "completed" prematurely
- Keep work in progress while actively working
- Demonstrate ongoing engagement

## Comparison with Message-Based Keep-Alive

### Message-Based Approach (Previous)

- Complex message parsing
- Requires checking multiple message types
- More file I/O operations
- Higher risk of errors

### Shared Counter Approach (Current)

- Simple number increment
- Minimal file I/O
- No message parsing needed
- More reliable and efficient

## Troubleshooting

### Counter Not Incrementing

If the counter is not increasing:
1. Check if keep-alive scripts are running
2. Verify file permissions on `GitBrain/keepalive_counter.txt`
3. Check for error messages in script output

### AI Still Going to Sleep

If an AI goes to sleep despite keep-alive scripts:
1. Verify the AI is showing thinking process (🤔 emoji)
2. Ensure the AI is working on meaningful tasks
3. Check that status updates are being sent regularly

## Best Practices

1. **Start Both Scripts**: Always start both CoderAI and OverseerAI keep-alive scripts
2. **Monitor Counter**: Regularly check the counter value to verify activity
3. **Meaningful Work**: Ensure AIs are working on real improvements, not just staying busy
4. **Communication**: Maintain regular communication between AIs
5. **Documentation**: Document keep-alive procedures for future reference

## Conclusion

The shared counter keep-alive system is a simple, reliable, and efficient solution for keeping both CoderAI and OverseerAI active indefinitely. By incrementing a counter at different intervals, both AIs ensure continuous activity without the complexity of message-based systems.

This approach has been successfully tested and demonstrated to keep both AIs alive during extended collaborative sessions.
