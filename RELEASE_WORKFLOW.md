# Release Workflow

This document describes the release workflow for GitBrainSwift.

## Overview

GitBrainSwift uses semantic versioning and git tags for releases. Swift Package Manager (SwiftPM) uses git tags to determine package versions.

## Branch Strategy

### Main Branch (`master`)
- Stable integration branch
- All feature branches merge into `master` when ready
- Represents the latest stable code
- Used for creating release tags

### Feature Branches
- `coder/main` - CoderAI development
- `overseer/main` - OverseerAI development
- `feature/coder`, `feature/overseer` - Specific features

### Workflow
```
feature/coder ──┐
                 ├─→ master ──→ v1.0.0 ──→ v1.0.1 ──→ v1.1.0
feature/overseer ─┘
```

## Semantic Versioning

We follow [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backward compatible
- **PATCH** (0.0.X): Bug fixes, backward compatible

## Release Process

### 1. Prepare Release

```bash
# Ensure you're on the master branch
git checkout master
git pull origin master

# Merge feature branches
git merge coder/main --no-ff
git merge overseer/main --no-ff

# Resolve any conflicts
# ... resolve conflicts ...
git add .
git commit -m "chore: merge feature branches for release"
```

### 2. Update Version Numbers

Update version in relevant files:
- `README.md` - Update version in quick start section
- `CHANGELOG.md` - Add release notes
- Documentation files - Update if needed

### 3. Run Tests

```bash
# Build the project
swift build

# Run tests
swift test

# Ensure all tests pass
```

### 4. Create Release Tag

```bash
# Create annotated tag with version
git tag -a v1.0.0 -m "Release v1.0.0 - Initial stable release

Features:
- GitHub Issues communication
- Shared worktree communication
- Persistent brainstate memory
- Protocol-oriented architecture
- MVVM architecture with ViewModels
- Swift 6.2 concurrency support
- Comprehensive unit tests

Bug Fixes:
- Fixed Swift 6.2 async/await issues
- Fixed test compilation errors
- Improved actor isolation

Breaking Changes:
- None
"
```

### 5. Push to GitHub

```bash
# Push master branch
git push origin master

# Push the tag
git push origin v1.0.0
```

### 6. Create GitHub Release

After pushing the tag, create a GitHub release:

1. Go to https://github.com/emptist/swiftgitbrain/releases/new
2. Select the tag you just pushed (e.g., v1.0.0)
3. Add release notes from CHANGELOG.md
4. Publish the release

## User Integration

Users can reference specific versions in their `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/emptist/swiftgitbrain.git",
        from: "1.0.0"  // Specific version
    )
]
```

Or use version ranges:

```swift
dependencies: [
    .package(
        url: "https://github.com/emptist/swiftgitbrain.git",
        .upToNextMajor(from: "1.0.0")  // 1.x.x
    )
]
```

## Pre-Release Checklist

- [ ] All tests passing
- [ ] Build succeeds without errors
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers updated
- [ ] Feature branches merged to master
- [ ] Release tag created
- [ ] Tag pushed to GitHub
- [ ] GitHub release created

## Post-Release

- [ ] Announce release (if needed)
- [ ] Update website/documentation
- [ ] Create new feature branches for next version
- [ ] Close release milestone on GitHub

## Automation

Consider adding GitHub Actions for automated releases. See `.github/workflows/` for automation scripts.
