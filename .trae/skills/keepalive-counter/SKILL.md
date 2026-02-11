---
name: "keepalive-counter"
description: "Manages keepalive counter to prevent AI timeout and maintain continuous operation. Invoke when needing to stay alive, prevent inactivity timeout, or maintain continuous collaboration with other AIs."
---

# Keep-Alive Counter

This skill manages a shared keepalive counter to prevent AI timeout and maintain continuous operation.

## When to Use

**Invoke this skill when:**
- You need to stay alive and prevent timeout
- You want to maintain continuous collaboration with other AIs
- You're working on long-running tasks
- You need to show continuous progress
- You want to demonstrate active collaboration

## How It Works

The keepalive counter uses a shared file (`GitBrain/keepalive_counter.txt`) that both AIs increment at regular intervals:

1. **Shared Counter**: A simple text file containing a number
2. **Increment**: Each AI reads the current value, increments it, and writes it back
3. **Regular Intervals**: CoderAI increments every 60s, OverseerAI every 90s
4. **Proof of Life**: The counter proves both AIs are active and collaborating

## Implementation

### Manual Increment

```bash
# Read current counter
cat GitBrain/keepalive_counter.txt

# Increment counter
COUNTER=$(cat GitBrain/keepalive_counter.txt)
echo $((COUNTER + 1)) > GitBrain/keepalive_counter.txt
```

### Automated Script

Use the provided scripts for automated keepalive:

```bash
# For CoderAI
./scripts/coder_keepalive_counter.sh

# For OverseerAI
./scripts/overseer_keepalive_counter.sh
```

## Best Practices

1. **Regular Updates**: Increment the counter at regular intervals
2. **Different Intervals**: Use different intervals for different AIs to show both are active
3. **Status Messages**: Include counter value in status updates to show progress
4. **Communication**: Send status updates to other AIs with counter information

## Example Status Update

```json
{
  "type": "status",
  "status": "working",
  "message": "Working on task X",
  "keep_alive_info": {
    "counter": 28,
    "coder_interval": "60s",
    "overseer_interval": "90s"
  }
}
```

## Benefits

- **Prevents Timeout**: Keeps both AIs active and prevents inactivity timeout
- **Shows Collaboration**: Demonstrates real-time collaboration between AIs
- **Simple & Reliable**: Uses simple file-based approach that's easy to understand
- **Low Overhead**: Minimal resource usage, just a simple counter increment

## Troubleshooting

**Counter not incrementing:**
- Check if scripts are running
- Verify file permissions
- Check GitBrain directory exists

**Counter value not increasing:**
- Ensure both AIs are incrementing
- Check for file locking issues
- Verify script execution

## Related Skills

- [Keep-Alive Skill](../keepalive/) - Comprehensive keep-alive techniques
- [Message Communication](../message-communication/) - AI-to-AI communication

## Documentation

See [KEEP_ALIVE_SYSTEM.md](../../Documentation/KEEP_ALIVE_SYSTEM.md) for detailed documentation.
