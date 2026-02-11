#!/bin/bash

# Cross-Language Integration Test for GitBrain
# This script tests GitBrain CLI with messages from different programming languages

set -e

echo "=== GitBrain Cross-Language Integration Test ==="
echo ""

# Setup
GITBRAIN_PATH="/tmp/test_cross_language"
export GITBRAIN_PATH

# Clean up previous test
rm -rf "$GITBRAIN_PATH"
mkdir -p "$GITBRAIN_PATH"

# Initialize GitBrain
echo "1. Initializing GitBrain..."
./.build/debug/gitbrain init
echo ""

# Test 1: Python-style task message
echo "2. Testing Python-style task message..."
python3 << 'EOF'
import json
import subprocess

message = {
    "type": "task",
    "task_id": "py-task-001",
    "description": "Implement Python function",
    "task_type": "coding",
    "priority": 7,
    "files": ["src/main.py", "tests/test_main.py"]
}

with open("/tmp/py_task.json", "w") as f:
    json.dump(message, f)

result = subprocess.run(["./.build/debug/gitbrain", "send", "overseer", "/tmp/py_task.json"], 
                       capture_output=True, text=True)
print(result.stdout)
if result.returncode != 0:
    print(f"Error: {result.stderr}")
    exit(1)
EOF
echo ""

# Test 2: JavaScript-style review message
echo "3. Testing JavaScript-style review message..."
node << 'EOF'
const fs = require('fs');
const { execSync } = require('child_process');

const message = {
    type: "review",
    task_id: "js-review-001",
    approved: true,
    reviewer: "JavaScriptAI",
    comments: [
        {
            line: 42,
            type: "suggestion",
            message: "Consider using const instead of let"
        }
    ],
    files_reviewed: ["index.js", "utils.js"]
};

fs.writeFileSync('/tmp/js_review.json', JSON.stringify(message));

try {
    const output = execSync('./.build/debug/gitbrain send overseer /tmp/js_review.json', 
                          { encoding: 'utf8' });
    console.log(output);
} catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
}
EOF
echo ""

# Test 3: Rust-style status message
echo "4. Testing Rust-style status message..."
python3 << 'EOF'
import json
import subprocess

message = {
    "type": "status",
    "status": "working",
    "message": "Compiling Rust code",
    "progress": 45,
    "current_task": {
        "task_id": "rust-build-001",
        "target": "release"
    },
    "timestamp": "2026-02-11T02:00:00Z"
}

with open("/tmp/rust_status.json", "w") as f:
    json.dump(message, f)

result = subprocess.run(["./.build/debug/gitbrain", "send", "overseer", "/tmp/rust_status.json"], 
                       capture_output=True, text=True)
print(result.stdout)
if result.returncode != 0:
    print(f"Error: {result.stderr}")
    exit(1)
EOF
echo ""

# Test 4: Go-style feedback message
echo "5. Testing Go-style feedback message..."
python3 << 'EOF'
import json
import subprocess

message = {
    "type": "feedback",
    "task_id": "go-task-001",
    "message": "Code review completed successfully",
    "severity": "info",
    "suggestions": [
        "Add error handling",
        "Improve documentation",
        "Add unit tests"
    ],
    "files": ["main.go", "handler.go"]
}

with open("/tmp/go_feedback.json", "w") as f:
    json.dump(message, f)

result = subprocess.run(["./.build/debug/gitbrain", "send", "overseer", "/tmp/go_feedback.json"], 
                       capture_output=True, text=True)
print(result.stdout)
if result.returncode != 0:
    print(f"Error: {result.stderr}")
    exit(1)
EOF
echo ""

# Verify messages
echo "6. Verifying all messages..."
./.build/debug/gitbrain check overseer
echo ""

# Test invalid message (should fail validation)
echo "7. Testing message validation (should fail)..."
python3 << 'EOF'
import json
import subprocess

message = {
    "type": "task",
    "task_id": "invalid-001",
    "description": "This should fail",
    "task_type": "invalid_type",  # Invalid task type
    "priority": 15  # Invalid priority (should be 1-10)
}

with open("/tmp/invalid.json", "w") as f:
    json.dump(message, f)

result = subprocess.run(["./.build/debug/gitbrain", "send", "overseer", "/tmp/invalid.json"], 
                       capture_output=True, text=True)
if result.returncode != 0:
    print("✓ Validation correctly rejected invalid message:")
    print(f"  {result.stdout}")
else:
    print("✗ Validation should have failed but didn't")
    exit(1)
EOF
echo ""

# Cleanup
echo "8. Cleaning up test messages..."
./.build/debug/gitbrain clear overseer
echo ""

echo "=== Cross-Language Integration Test Complete ==="
echo "✓ All tests passed!"
