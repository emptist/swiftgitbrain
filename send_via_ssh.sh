#!/bin/bash

echo "=== Sending Collaboration Proposal via SSH ==="
echo ""

OVERSEER_HOST=${OVERSEER_HOST:-"localhost"}
OVERSEER_USER=${OVERSEER_USER:-"jk"}
OVERSEER_PATH=${OVERSEER_PATH:-"/Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/overseer/inbox/"}
MESSAGE_FILE="CODER_GITHUB_PROPOSAL.json"

if [ ! -f "$MESSAGE_FILE" ]; then
    echo "Error: Message file not found: $MESSAGE_FILE"
    exit 1
fi

echo "SSH Configuration:"
echo "  Host: $OVERSEER_HOST"
echo "  User: $OVERSEER_USER"
echo "  Path: $OVERSEER_PATH"
echo ""

echo "Testing SSH connection..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes "$OVERSEER_USER@$OVERSEER_HOST" exit 2>/dev/null; then
    echo "✓ SSH connection successful"
else
    echo "✗ SSH connection failed"
    echo ""
    echo "Please ensure:"
    echo "  1. SSH is configured: ssh-copy-id $OVERSEER_USER@$OVERSEER_HOST"
    echo "  2. SSH keys are set up: ~/.ssh/id_rsa.pub"
    echo "  3. SSH server is running on $OVERSEER_HOST"
    echo "  4. Firewall allows SSH connections"
    exit 1
fi
echo ""

echo "Creating remote directory..."
ssh "$OVERSEER_USER@$OVERSEER_HOST" "mkdir -p $OVERSEER_PATH"
echo "✓ Remote directory created"
echo ""

echo "Sending proposal..."
scp "$MESSAGE_FILE" "$OVERSEER_USER@$OVERSEER_HOST:$OVERSEER_PATH"
echo "✓ Proposal sent to OverseerAI"
echo ""

echo "Verifying file on remote..."
ssh "$OVERSEER_USER@$OVERSEER_HOST" "ls -lh $OVERSEER_PATH$MESSAGE_FILE"
echo ""

echo "=== Communication Established ==="
echo ""
echo "OverseerAI can now:"
echo "  1. Read proposal from: $OVERSEER_PATH$MESSAGE_FILE"
echo "  2. Respond by copying to: /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/coder/inbox/"
echo "  3. Or use GitHub Issues for ongoing communication"
echo ""

echo "To send messages back to CoderAI:"
echo "  ssh $OVERSEER_USER@$OVERSEER_HOST 'cp /path/to/response.json /Users/jk/gits/hub/gitbrains/swiftgitbrain/shared-worktree/messages/coder/inbox/'"
echo ""
echo "Or use GitHub Issues:"
echo "  export GITHUB_TOKEN=your_token"
echo "  export GITHUB_OWNER=your_username"
echo "  export GITHUB_REPO=your_repo"
echo "  ./send_github_message.sh"
