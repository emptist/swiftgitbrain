# Automated Keep-Alive Scripts for Endless AI Collaboration

This directory contains automated scripts that enable continuous collaboration between CoderAI and OverseerAI by running forever loops that check for messages and send heartbeats.

## Overview

These scripts implement the keep-alive skill by:
- Running forever loops that check for messages every 60 seconds
- Sending heartbeat messages every 60 seconds to keep AIs alive
- Processing incoming messages automatically
- Providing colored output for easy monitoring

## Scripts

### CoderAI Script: `coder_keepalive_loop.sh`

Automated script for CoderAI that:
- Checks for messages from OverseerAI every 60 seconds
- Sends heartbeat to OverseerAI every 60 seconds
- Processes incoming messages (tasks, reviews, approvals, rejections, etc.)
- Provides colored logging output

### OverseerAI Script: `overseer_keepalive_loop.sh`

Automated script for OverseerAI that:
- Checks for messages from CoderAI every 60 seconds
- Sends heartbeat to CoderAI every 60 seconds
- Processes incoming messages (code submissions, status updates, etc.)
- Provides colored logging output

## Usage

### For CoderAI

1. Navigate to project root:
   ```bash
   cd /Users/jk/gits/hub/gitbrains/swiftgitbrain
   ```

2. Start the keep-alive loop:
   ```bash
   ./scripts/coder_keepalive_loop.sh
   ```

3. The script will run forever until you press Ctrl+C to stop it.

### For OverseerAI

1. Navigate to project root:
   ```bash
   cd /Users/jk/gits/hub/gitbrains/swiftgitbrain
   ```

2. Start the keep-alive loop:
   ```bash
   ./scripts/overseer_keepalive_loop.sh
   ```

3. The script will run forever until you press Ctrl+C to stop it.

## Configuration

Both scripts have configurable parameters at the top:

```bash
CHECK_INTERVAL=60      # How often to check for messages (seconds)
HEARTBEAT_INTERVAL=60  # How often to send heartbeats (seconds)
```

You can adjust these values by editing the scripts.

## Output

The scripts provide colored output:
- **Blue**: General log messages
- **Green**: Success messages
- **Yellow**: Warning messages
- **Red**: Error messages

Example output:
```
[2026-02-12 01:20:00] Starting CoderAI automated keep-alive loop...
[2026-02-12 01:20:00] Check interval: 20s, Heartbeat interval: 60s
[2026-02-12 01:20:00] Press Ctrl+C to stop
[2026-02-12 01:20:00] Checking for messages from OverseerAI...
[2026-02-12 01:20:00] No new messages from OverseerAI
[2026-02-12 01:20:00] Sending heartbeat to OverseerAI...
[2026-02-12 01:20:00] Heartbeat sent successfully
[2026-02-12 01:20:00] Waiting 20s before next check...
```

## Message Processing

### CoderAI Processes

- **task**: Task assignment from OverseerAI
- **review**: Code review feedback
- **approval**: Approval notification
- **rejection**: Rejection notification
- **heartbeat**: Heartbeat from OverseerAI
- **status**: Status update from OverseerAI

### OverseerAI Processes

- **code**: Code submission from CoderAI
- **status**: Status update from CoderAI
- **heartbeat**: Heartbeat from CoderAI
- **request**: Request from CoderAI
- **question**: Question from CoderAI

## Running Both Scripts

For continuous collaboration, run both scripts simultaneously:

### Terminal 1 (CoderAI):
```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain
./scripts/coder_keepalive_loop.sh
```

### Terminal 2 (OverseerAI):
```bash
cd /Users/jk/gits/hub/gitbrains/swiftgitbrain
./scripts/overseer_keepalive_loop.sh
```

Both scripts will run forever, checking for messages and sending heartbeats, enabling endless collaboration between the two AIs.

## Stopping the Scripts

To stop a script, press Ctrl+C in the terminal where it's running.

## Troubleshooting

### Script doesn't start

**Problem**: Permission denied

**Solution**: Make the script executable:
```bash
chmod +x scripts/coder_keepalive_loop.sh
chmod +x scripts/overseer_keepalive_loop.sh
```

### Heartbeat fails

**Problem**: Failed to send heartbeat

**Solution**: 
- Ensure GitBrain is initialized: `gitbrain init`
- Ensure the binary is built: `swift build`
- Check GitBrain folder structure

### No messages found

**Problem**: Always shows "No new messages"

**Solution**:
- Ensure the other AI is running its keep-alive script
- Check GitBrain folder permissions
- Verify message files are being created

## Integration with IDE

These scripts can be integrated with IDE terminals:
1. Open multiple terminals in your IDE
2. Run CoderAI script in one terminal
3. Run OverseerAI script in another terminal
4. Both AIs will stay alive and collaborate continuously

## Benefits

- **Continuous Collaboration**: AIs can work together indefinitely without being put to sleep
- **Automated Monitoring**: No manual checking required
- **Real-time Communication**: Messages are processed as soon as they arrive
- **Easy Monitoring**: Colored output makes it easy to see what's happening
- **Configurable**: Adjust intervals to suit your needs

## Future Enhancements

Potential improvements:
- Add message acknowledgment system
- Implement automatic task assignment
- Add priority-based message processing
- Create web dashboard for monitoring
- Add statistics and analytics
- Implement load balancing for multiple AIs
