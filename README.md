# GitBrain Mini System

A simplified, file-based AI collaboration system using Maildir for communication and Git for version control.

## Overview

GitBrain is a lightweight AI collaboration platform that enables multiple AIs to work together through:
- **Maildir-based communication**: Async message passing between AIs
- **Brainstate memory**: Persistent AI states as versioned files
- **Git integration**: Complete history and collaboration support
- **Role-based architecture**: CoderAI, ReviewerAI, OverseerAI roles
- **Simple deployment**: No database or network complexity

## Architecture

```
GitBrain/
├── core/                    # Core system components
│   ├── communication/       # Maildir-based messaging
│   ├── memory/              # Brainstate management
│   ├── daemon/              # Monitoring and event handling
│   └── utils/               # Utility functions
├── roles/                   # AI role definitions
│   ├── coder/              # CoderAI implementation
│   ├── reviewer/           # ReviewerAI implementation
│   └── overseer/           # OverseerAI implementation
├── configs/                 # Configuration files
│   └── templates/          # Configuration templates
├── scripts/                 # Installation and setup scripts
│   ├── install/            # Installation scripts
│   └── setup/              # Setup scripts
├── docs/                    # Documentation
│   ├── api/                # API documentation
│   └── guides/             # User guides
└── tests/                   # Test suites
    ├── unit/               # Unit tests
    └── integration/        # Integration tests
```

## Quick Start

### Installation

```bash
# Install as papi package
pip install gitbrain

# Initialize a new GitBrain workspace
gitbrain init my-workspace

# Add AIs to the workspace
gitbrain add-ai coder
gitbrain add-ai reviewer
gitbrain add-ai overseer

# Start the GitBrain daemon
gitbrain start
```

### Configuration

Edit `gitbrain.yaml` to configure your AIs:

```yaml
system:
  name: "My GitBrain Workspace"
  version: "1.0.0"

maildir:
  base: "./mailboxes"
  check_interval: 5

brainstate:
  base: "./brainstates"
  auto_save: true
  save_interval: 60

roles:
  coder:
    enabled: true
    mailbox: "coder"
    brainstate: "coder_state.json"
  
  reviewer:
    enabled: true
    mailbox: "reviewer"
    brainstate: "reviewer_state.json"
  
  overseer:
    enabled: true
    mailbox: "overseer"
    brainstate: "overseer_state.json"
```

## Roles

### CoderAI
- **Purpose**: Implement features and write code
- **Responsibilities**:
  - Receive tasks from OverseerAI
  - Write and modify code
  - Send code to ReviewerAI for review
  - Apply feedback from ReviewerAI

### ReviewerAI
- **Purpose**: Review code and provide feedback
- **Responsibilities**:
  - Receive code from CoderAI
  - Review code quality and correctness
  - Provide feedback to CoderAI
  - Approve or request changes

### OverseerAI
- **Purpose**: Coordinate and manage the workflow
- **Responsibilities**:
  - Assign tasks to CoderAI
  - Monitor progress
  - Resolve conflicts
  - Make final decisions

## Communication Flow

```
OverseerAI ──assign──> CoderAI ──code──> ReviewerAI
     ↑                                    │
     └─────────approve────────────────────┘
```

## Brainstate Memory

Each AI maintains its own brainstate as a JSON file:

```json
{
  "ai_name": "CoderAI",
  "version": "1.0.0",
  "last_updated": "2026-02-10T00:00:00Z",
  "state": {
    "current_task": null,
    "completed_tasks": [],
    "knowledge_base": {},
    "preferences": {}
  }
}
```

## Features

- **File-based communication**: All communication through Maildir
- **Persistent memory**: AI states saved as files
- **Version control**: Git integration for history
- **Hot-reload**: Configuration changes without restart
- **Auto-repair**: Automatic mailbox repair
- **Event-driven**: Trigger files for notifications
- **Simple deployment**: No database or network setup

## License

MIT License
