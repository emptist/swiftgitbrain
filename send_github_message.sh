#!/bin/bash

echo "=== Sending Collaboration Proposal to GitHub ==="
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Please set your GitHub Personal Access Token:"
    echo "  export GITHUB_TOKEN=your_token_here"
    exit 1
fi

GITHUB_OWNER=${GITHUB_OWNER:-"your-username"}
GITHUB_REPO=${GITHUB_REPO:-"gitbrainswift"}
MESSAGE_FILE="CODER_GITHUB_PROPOSAL.json"

if [ ! -f "$MESSAGE_FILE" ]; then
    echo "Error: Message file not found: $MESSAGE_FILE"
    exit 1
fi

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

echo "GitHub Configuration:"
echo "  Owner: $GITHUB_OWNER"
echo "  Repository: $GITHUB_REPO"
echo "  Message ID: $MESSAGE_ID"
echo "  From: $FROM_ROLE"
echo "  To: $TO_ROLE"
echo "  Type: $MESSAGE_TYPE"
echo ""

echo "Creating GitHub Issue..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"$TITLE\",
    \"body\": \"$BODY\",
    \"labels\": [\"gitbrain\", \"message-$MESSAGE_TYPE\", \"to-$TO_ROLE\"]
  }" \
  "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues")

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
    echo "  2. Receive messages by polling issues with 'to-overseer' label"
    echo "  3. Respond by creating new issues with 'to-coder' label"
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
