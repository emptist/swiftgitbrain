#!/bin/bash

echo "=== GitBrainSwift GitHub Issues Collaboration Setup ==="
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Please set your GitHub Personal Access Token:"
    echo "  export GITHUB_TOKEN=your_token_here"
    exit 1
fi

GITHUB_OWNER=${GITHUB_OWNER:-"your-username"}
GITHUB_REPO=${GITHUB_REPO:-"gitbrainswift"}

echo "GitHub Configuration:"
echo "  Owner: $GITHUB_OWNER"
echo "  Repository: $GITHUB_REPO"
echo "  Token: ${GITHUB_TOKEN:0:10}..."
echo ""

echo "Creating demo script..."
cat > github_collaboration_demo.sh << 'EOF'
#!/bin/bash

GITHUB_TOKEN="$1"
GITHUB_OWNER="$2"
GITHUB_REPO="$3"
FROM_ROLE="$4"
TO_ROLE="$5"
MESSAGE_TYPE="$6"
MESSAGE_FILE="$7"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO" ]; then
    echo "Usage: ./github_collaboration_demo.sh <token> <owner> <repo> <from> <to> <type> <message_file>"
    exit 1
fi

MESSAGE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -f "$MESSAGE_FILE" ]; then
    MESSAGE_CONTENT=$(cat "$MESSAGE_FILE")
else
    MESSAGE_CONTENT='{"message": "test"}'
fi

TITLE="[$TO_ROLE] $MESSAGE_TYPE: ${MESSAGE_ID:0:8}"

BODY="**From:** $FROM_ROLE
**To:** $TO_ROLE
**Type:** $MESSAGE_TYPE
**Timestamp:** $TIMESTAMP
**Priority:** 1

\`\`\`json
$MESSAGE_CONTENT
\`\`\`"

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

ISSUE_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*' | cut -d'"' -f4)

if [ -n "$ISSUE_URL" ]; then
    echo "✓ Message sent via GitHub Issue"
    echo "  Issue URL: $ISSUE_URL"
else
    echo "✗ Failed to create issue"
    echo "  Response: $RESPONSE"
fi
EOF

chmod +x github_collaboration_demo.sh

echo "✓ Demo script created: github_collaboration_demo.sh"
echo ""

echo "=== Quick Start ==="
echo ""
echo "1. Send a message:"
echo "  ./github_collaboration_demo.sh \$GITHUB_TOKEN $GITHUB_OWNER $GITHUB_REPO coder overseer status CODER_GITHUB_PROPOSAL.json"
echo ""

echo "2. Check messages for a role:"
echo "  curl -s -H \"Authorization: Bearer \$GITHUB_TOKEN\" \"https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues?state=open&labels=to-coder\" | jq '.[] | {title, url}'"
echo ""

echo "3. Close an issue (after processing):"
echo "  curl -s -X PATCH -H \"Authorization: Bearer \$GITHUB_TOKEN\" -H \"Accept: application/vnd.github+json\" -H \"Content-Type: application/json\" -d '{\"state\":\"closed\"}' \"https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/ISSUE_NUMBER\""
echo ""

echo "=== Environment Variables ==="
echo ""
echo "Set these in your shell profile (~/.zshrc or ~/.bashrc):"
echo "  export GITHUB_TOKEN=your_github_token_here"
echo "  export GITHUB_OWNER=$GITHUB_OWNER"
echo "  export GITHUB_REPO=$GITHUB_REPO"
echo ""

echo "=== Swift Demo ==="
echo ""
echo "To run the Swift demo:"
echo "  swift run gitbrain-github-demo"
echo ""

echo "Setup complete!"
