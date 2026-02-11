# Cross-Language Deployment Guide

This guide explains how to use GitBrainSwift CLI in projects of any programming language.

## Overview

GitBrainSwift provides a standalone CLI executable that can be used in projects written in any language (Python, JavaScript, Rust, Go, Java, etc.). The CLI handles file-based communication between AIs, making it language-agnostic.

## Quick Start

### Option 1: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/gitbrainswift.git
cd gitbrainswift

# Build the CLI
swift build -c release --product gitbrain

# The executable is at: .build/release/gitbrain
```

### Option 2: Download Pre-built Binary (Future)

```bash
# Download for your architecture
curl -L https://github.com/yourusername/gitbrainswift/releases/latest/download/gitbrain-macos-arm64 -o gitbrain

# Make it executable
chmod +x gitbrain
```

## Installation Methods

### System-Wide Installation (Recommended)

```bash
# Build release version
swift build -c release --product gitbrain

# Install to /usr/local/bin
sudo cp .build/release/gitbrain /usr/local/bin/

# Verify installation
gitbrain --version
```

### Project-Local Installation

```bash
# Build release version
swift build -c release --product gitbrain

# Copy to project directory
cp .build/release/gitbrain /path/to/your/project/

# Add to PATH or use directly
./gitbrain init
```

### Using with direnv (macOS/Linux)

```bash
# In your project directory
echo 'export PATH=$PWD:$PATH' > .envrc
direnv allow

# Now you can use gitbrain directly
gitbrain init
```

## Usage in Different Languages

### Python Project

```bash
# Initialize GitBrain
gitbrain init

# Open Trae for CoderAI
trae .

# Open Trae for OverseerAI
trae ./GitBrain/Overseer

# In your Python code, you can also interact with GitBrain files
import json
import os

# Read messages for CoderAI
def read_coder_messages():
    memory_dir = "GitBrain/Memory"
    messages = []
    for filename in sorted(os.listdir(memory_dir)):
        if filename.endswith('.json'):
            with open(os.path.join(memory_dir, filename)) as f:
                messages.append(json.load(f))
    return messages

# Send message to OverseerAI
def send_to_overseer(message):
    import subprocess
    subprocess.run(['gitbrain', 'send', 'overseer', json.dumps(message)])
```

### JavaScript/Node.js Project

```bash
# Initialize GitBrain
gitbrain init

# Open Trae for CoderAI
trae .

# Open Trae for OverseerAI
trae ./GitBrain/Overseer

# In your JavaScript code
const fs = require('fs');
const { execSync } = require('child_process');

// Read messages for CoderAI
function readCoderMessages() {
    const memoryDir = 'GitBrain/Memory';
    const files = fs.readdirSync(memoryDir).filter(f => f.endsWith('.json'));
    return files.map(f => JSON.parse(fs.readFileSync(`${memoryDir}/${f}`)));
}

// Send message to OverseerAI
function sendToOverseer(message) {
    execSync(`gitbrain send overseer '${JSON.stringify(message)}'`);
}
```

### Rust Project

```bash
# Initialize GitBrain
gitbrain init

# Open Trae for CoderAI
trae .

# Open Trae for OverseerAI
trae ./GitBrain/Overseer

// In your Rust code
use std::fs;
use std::process::Command;

// Read messages for CoderAI
fn read_coder_messages() -> Vec<serde_json::Value> {
    let memory_dir = "GitBrain/Memory";
    let mut messages = Vec::new();
    
    if let Ok(entries) = fs::read_dir(memory_dir) {
        let mut files: Vec<_> = entries
            .filter_map(|e| e.ok())
            .filter(|e| e.path().extension().map_or(false, |ext| ext == "json"))
            .collect();
        
        files.sort_by_key(|e| e.path());
        
        for entry in files {
            if let Ok(content) = fs::read_to_string(entry.path()) {
                if let Ok(msg) = serde_json::from_str::<serde_json::Value>(&content) {
                    messages.push(msg);
                }
            }
        }
    }
    
    messages
}

// Send message to OverseerAI
fn send_to_overseer(message: &serde_json::Value) {
    Command::new("gitbrain")
        .args(&["send", "overseer", &message.to_string()])
        .status()
        .expect("Failed to execute gitbrain");
}
```

### Go Project

```bash
# Initialize GitBrain
gitbrain init

# Open Trae for CoderAI
trae .

# Open Trae for OverseerAI
trae ./GitBrain/Overseer

// In your Go code
package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "os"
    "os/exec"
    "path/filepath"
    "sort"
)

// Read messages for CoderAI
func readCoderMessages() ([]map[string]interface{}, error) {
    memoryDir := "GitBrain/Memory"
    files, err := ioutil.ReadDir(memoryDir)
    if err != nil {
        return nil, err
    }
    
    var messages []map[string]interface{}
    for _, file := range files {
        if filepath.Ext(file.Name()) == ".json" {
            data, err := ioutil.ReadFile(filepath.Join(memoryDir, file.Name()))
            if err != nil {
                continue
            }
            
            var msg map[string]interface{}
            if err := json.Unmarshal(data, &msg); err == nil {
                messages = append(messages, msg)
            }
        }
    }
    
    return messages, nil
}

// Send message to OverseerAI
func sendToOverseer(message map[string]interface{}) error {
    data, err := json.Marshal(message)
    if err != nil {
        return err
    }
    
    cmd := exec.Command("gitbrain", "send", "overseer", string(data))
    return cmd.Run()
}
```

## Configuration

### Default GitBrain Path

By default, the CLI looks for `./GitBrain` in the current directory.

### Custom GitBrain Path

You can specify a custom path for each command:

```bash
gitbrain init /custom/path/to/GitBrain
gitbrain send overseer '{"type":"review"}' /custom/path/to/GitBrain
gitbrain check coder /custom/path/to/GitBrain
```

### Environment Variable (Future Enhancement)

```bash
# Set default GitBrain path
export GITBRAIN_PATH=/custom/path/to/GitBrain

# Now all commands use this path
gitbrain check coder
```

## CI/CD Integration

### GitHub Actions

```yaml
name: AI Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ai-review:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install GitBrain
        run: |
          curl -L https://github.com/yourusername/gitbrainswift/releases/latest/download/gitbrain-macos-arm64 -o gitbrain
          chmod +x gitbrain
          sudo mv gitbrain /usr/local/bin/
      
      - name: Initialize GitBrain
        run: gitbrain init
      
      - name: Request AI Review
        run: |
          gitbrain send overseer '{
            "type": "code_review",
            "pr_number": "${{ github.event.number }}",
            "files": ["src/main.py"]
          }'
      
      - name: Check Review Results
        run: gitbrain check coder
```

### GitLab CI

```yaml
ai_review:
  image: swift:latest
  script:
    - swift build -c release --product gitbrain
    - cp .build/release/gitbrain /usr/local/bin/
    - gitbrain init
    - gitbrain send overseer '{"type":"code_review"}'
    - gitbrain check coder
  only:
    - merge_requests
```

## Troubleshooting

### Permission Denied

```bash
# Make the executable executable
chmod +x gitbrain
```

### Command Not Found

```bash
# Add to PATH or use full path
export PATH=$PATH:/path/to/gitbrain/directory
# or
/path/to/gitbrain init
```

### GitBrain Folder Not Found

```bash
# Initialize GitBrain first
gitbrain init

# Or specify the path explicitly
gitbrain check coder /path/to/GitBrain
```

## Platform Support

### Current Support
- macOS 14+ (arm64 and x86_64)

### Future Support
- Linux (arm64 and x86_64)
- Windows (via WSL)

## Building for Different Platforms

### macOS (Apple Silicon)

```bash
swift build -c release --product gitbrain
```

### macOS (Intel)

```bash
swift build -c release --product gitbrain --arch x86_64
```

### Linux

```bash
# Build on Linux machine
swift build -c release --product gitbrain

# Or cross-compile from macOS (requires Docker)
docker run --rm -v $(pwd):/workspace -w /workspace swift:latest \
  swift build -c release --product gitbrain
```

## Best Practices

1. **Version Pinning**: Pin to a specific version for reproducibility
2. **CI/CD**: Include GitBrain setup in your CI pipeline
3. **Documentation**: Document GitBrain usage in your project README
4. **Cleanup**: Add `.gitignore` entry for GitBrain folder (optional)
5. **Testing**: Test GitBrain integration in your test suite

## Uninstallation

```bash
# Remove system-wide installation
sudo rm /usr/local/bin/gitbrain

# Remove project-local installation
rm /path/to/project/gitbrain

# Clean up GitBrain folder (optional)
rm -rf GitBrain
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/yourusername/gitbrainswift/issues
- Documentation: https://github.com/yourusername/gitbrainswift/wiki
