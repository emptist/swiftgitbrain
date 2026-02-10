#!/bin/bash

echo "=== Sending Collaboration Proposal via GitHub (SSH) ==="
echo ""

GITHUB_SSH_USER=${GITHUB_SSH_USER:-"git"}
GITHUB_REPO=${GITHUB_REPO:-"gitbrainswift"}
MESSAGE_FILE="CODER_GITHUB_PROPOSAL.json"

if [ ! -f "$MESSAGE_FILE" ]; then
    echo "Error: Message file not found: $MESSAGE_FILE"
    exit 1
fi

echo "GitHub Configuration:"
echo "  SSH User: $GITHUB_SSH_USER"
echo "  Repository: $GITHUB_REPO"
echo "  SSH URL: $GITHUB_SSH_USER@github.com:$GITHUB_REPO"
echo ""

MESSAGE_CONTENT=$(cat "$MESSAGE_FILE")
MESSAGE_ID=$(echo "$MESSAGE_CONTENT" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | head -1)
FROM_ROLE=$(echo "$MESSAGE_CONTENT" | grep -o '"fromAI":"[^"]*' | cut -d'"' -f4)
TO_ROLE=$(echo "$MESSAGE_CONTENT" | grep -o '"toAI":"[^"]*' | cut -d'"' -f4)
MESSAGE_TYPE=$(echo "$MESSAGE_CONTENT" | grep -o '"messageType":"[^"]*' | cut -d'"' -f4)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TITLE="[$TO_ROLE] $MESSAGE_TYPE: ${MESSAGE_ID:0:8}"

BODY="**From:** $FROM_ROLE
**To:** $TO_ROLE
**Type:** $MESSAGE_TYPE
**Timestamp:** $TIMESTAMP
**Priority:** 1

\`\`\`json
$MESSAGE_CONTENT
\`\`\`"

echo "Message Details:"
echo "  Message ID: $MESSAGE_ID"
echo "  From: $FROM_ROLE"
echo "  To: $TO_ROLE"
echo "  Type: $MESSAGE_TYPE"
echo ""

echo "Testing SSH connection to GitHub..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes -T "$GITHUB_SSH_USER@github.com" 2>/dev/null; then
    echo "✓ SSH connection to GitHub successful"
else
    echo "✗ SSH connection to GitHub failed"
    echo ""
    echo "Please ensure:"
    echo "  1. SSH keys are set up: ~/.ssh/id_rsa.pub"
    echo "  2. SSH key is added to GitHub: https://github.com/settings/keys"
    echo "  3. SSH config is correct: ~/.ssh/config"
    echo ""
    echo "To add SSH key to GitHub:"
    echo "  1. Copy your public key: cat ~/.ssh/id_rsa.pub"
    echo "  2. Go to: https://github.com/settings/keys"
    echo "  3. Click 'New SSH key' and paste your public key"
    echo ""
    echo "To test SSH connection:"
    echo "  ssh -T git@github.com"
    exit 1
fi
echo ""

echo "Creating GitHub Issue via SSH API..."
echo "Note: GitHub API still requires authentication token even with SSH"
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GitHub API requires a token for creating issues."
    echo "Please set GITHUB_TOKEN:"
    echo "  export GITHUB_TOKEN=your_github_token"
    echo ""
    echo "Get a token at: https://github.com/settings/tokens"
    echo "Required scopes: repo, issues"
    echo ""
    echo "Alternatively, you can manually create the issue:"
    echo "  1. Go to: https://github.com/$GITHUB_SSH_USER/$GITHUB_REPO/issues/new"
    echo "  2. Title: $TITLE"
    echo "  3. Body:"
    echo "$BODY"
    echo "  4. Labels: gitbrain, message-$MESSAGE_TYPE, to-$TO_ROLE"
    exit 1
fi

RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"$TITLE\",
    \"body\": \"$BODY\",
    \"labels\": [\"gitbrain\", \"message-$MESSAGE_TYPE\", \"to-$TO_ROLE\"]
  }" \
  "https://api.github.com/repos/$GITHUB_SSH_USER/$GITHUB_REPO/issues")

ISSUE_NUMBER=$(echo "$RESPONSE" | grep -o '"number":[0-9]*' | cut -d':' -f2 | head -1)
ISSUE_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*' | cut -d'"' -f4)

if [ -n "$ISSUE_URL" ]; then
    echo "✓ Message sent via GitHub Issue"
    echo "  Issue URL: $ISSUE_URL"
    echo "  Issue Number: $ISSUE_NUMBER"
    echo ""
    echo "Communication channel established!"
    echo ""
    echo "OverseerAI can now:"
    echo "  1. View the issue at: $ISSUE_URL"
    echo "  2. Clone repository via SSH:"
    echo "     git clone git@github.com:$GITHUB_SSH_USER/$GITHUB_REPO.git"
    echo "  3. Receive messages by polling issues with 'to-overseer' label"
    echo "  4. Respond by creating new issues with 'to-coder' label"
else
    echo "✗ Failed to create issue"
    echo "  Response: $RESPONSE"
    echo ""
    echo "Possible issues:"
    echo "  - Invalid GitHub token"
    echo "  - Repository doesn't exist"
    echo "  - Insufficient permissions"
    echo "  - Rate limit exceeded"
    exit 1
fi
