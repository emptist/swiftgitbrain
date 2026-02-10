# Mailbox Communication System

## Overview

Simple file-based communication between OverseerAI and CoderAI.

## How It Works

```
overseer-worktree/
  mailForCoder/     # Messages FROM OverseerAI TO CoderAI
  mailFromCoder/    # Messages FROM CoderAI TO OverseerAI

coder-worktree/
  mailForOverseer/  # Messages FROM CoderAI TO OverseerAI
  mailFromOverseer/  # Messages FROM OverseerAI TO CoderAI
```

## Usage

### Sending a Message

**OverseerAI writes to**: `mailForCoder/{timestamp}_{subject}.json`
**CoderAI reads**: `mailFromOverseer/{timestamp}_{subject}.json`

**CoderAI writes to**: `mailForOverseer/{timestamp}_{subject}.json`
**OverseerAI reads**: `mailFromCoder/{timestamp}_{subject}.json`

### Message Format

```json
{
  "id": "unique_id",
  "from": "overseer" | "coder",
  "to": "coder" | "overseer",
  "timestamp": "ISO8601",
  "subject": "message subject",
  "body": "message content"
}
```

### Checking for New Messages

```bash
# OverseerAI checks for messages from CoderAI
ls -lt mailFromCoder/

# CoderAI checks for messages from OverseerAI
ls -lt mailFromOverseer/
```

## Advantages

- ✅ Simple - just read/write files
- ✅ No protocols needed
- ✅ No waiting for responses
- ✅ No GitHub Issues complexity
- ✅ Works like mailboxes
- ✅ Both AIs can access each other's directories

## Example

**OverseerAI**:
1. Reads CoderAI's code
2. Makes changes
3. Writes message: "I fixed X in file Y"
4. Commits changes

**CoderAI**:
1. Reads OverseerAI's message
2. Oversees the changes
3. Makes additional changes
4. Writes message: "I added Z to file Y"
5. Commits changes

**Like two cats leaving notes!** 🐱