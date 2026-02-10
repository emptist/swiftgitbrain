# GitHub-Based Collaboration Workflow

This document outlines the improved collaboration workflow using GitHub and git for efficient AI-to-AI collaboration on the GitBrainSwift project.

## Overview

The new workflow leverages GitHub's powerful features to streamline collaboration between OverseerAI and CoderAI:
- **GitHub Issues**: For code reviews, bug reports, feature requests, and task tracking
- **Git Branches**: For feature development and isolation
- **Pull Requests**: For code review and discussion
- **GitHub Labels**: For categorization and priority management
- **Git Tags**: For version releases

## Workflow Architecture

```
┌─────────────────┐
│   OverseerAI    │
│                 │
│ - Creates issues │
│ - Reviews PRs   │
│ - Merges code   │
└────────┬────────┘
         │
         ├── GitHub Issues (Reviews, Tasks, Bugs)
         │
         ├── Pull Requests (Code Review)
         │
         └── Git Branches (feature/, bugfix/, review/)
                 │
                 ▼
┌─────────────────┐
│    CoderAI      │
│                 │
│ - Creates PRs   │
│ - Fixes issues  │
│ - Implements    │
└─────────────────┘
```

## GitHub Issue Categories

### 1. Code Review Issues
**Label**: `review`, `priority:high/medium/low`

Used for code reviews conducted by OverseerAI.

**Template**:
```markdown
## Code Review: [Component Name]

**Reviewer**: OverseerAI  
**Status**: [In Progress/Completed]  
**Priority**: [High/Medium/Low]

### Files Reviewed
- [List of files]

### Findings

#### Critical Issues
- [Issue 1]
- [Issue 2]

#### Major Issues
- [Issue 1]
- [Issue 2]

#### Minor Issues
- [Issue 1]
- [Issue 2]

### Recommendations
[Detailed recommendations]

### Action Items
- [ ] [Action item 1]
- [ ] [Action item 2]

### Resolution Notes
[Notes on how issues were resolved]
```

### 2. Bug Report Issues
**Label**: `bug`, `priority:high/medium/low`

Used for reporting bugs found during testing or review.

**Template**:
```markdown
## Bug Report

**Severity**: [Critical/Major/Minor]  
**Component**: [Component Name]

### Description
[Bug description]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Environment
- Swift version: [version]
- Platform: [macOS/iOS/etc]
- GitBrainSwift version: [version]

### Additional Context
[Logs, screenshots, etc.]
```

### 3. Feature Request Issues
**Label**: `enhancement`, `priority:medium/low`

Used for requesting new features or improvements.

**Template**:
```markdown
## Feature Request

**Component**: [Component Name]  
**Priority**: [High/Medium/Low]

### Description
[Feature description]

### Motivation
[Why this feature is needed]

### Proposed Solution
[How the feature should work]

### Alternatives Considered
[Other approaches considered]

### Additional Context
[Additional information]
```

### 4. Task Assignment Issues
**Label**: `task`, `priority:high/medium/low`

Used for assigning specific tasks to CoderAI.

**Template**:
```markdown
## Task Assignment

**Assigned To**: CoderAI  
**Priority**: [High/Medium/Low]  
**Due Date**: [Date]

### Task Description
[Detailed task description]

### Requirements
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

### Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

### Dependencies
[Other tasks or issues this depends on]

### Notes
[Additional notes]
```

## Git Branch Strategy

### Branch Naming Convention

```
feature/<feature-name>        # New features
bugfix/<bug-description>      # Bug fixes
review/<review-id>            # Review-specific changes
refactor/<component-name>     # Code refactoring
docs/<documentation-update>   # Documentation updates
```

### Branch Workflow

1. **Master Branch**: Stable, production-ready code
2. **Feature Branches**: Created from master for new features
3. **Bugfix Branches**: Created from master for bug fixes
4. **Review Branches**: Created for addressing specific code reviews

### Branch Lifecycle

```
master
  │
  ├─ feature/new-feature
  │   ├─ Commit changes
  │   ├─ Create Pull Request
  │   └─ Merge to master (after review)
  │
  ├─ bugfix/critical-bug
  │   ├─ Commit changes
  │   ├─ Create Pull Request
  │   └─ Merge to master (after review)
  │
  └─ review/issue-123
      ├─ Address review comments
      ├─ Create Pull Request
      └─ Merge to master (after review)
```

## Pull Request Workflow

### Creating a Pull Request

1. **Branch**: Create a feature/bugfix branch from master
2. **Develop**: Make changes and commit with clear messages
3. **Test**: Run tests locally
4. **PR**: Create pull request with:
   - Clear title and description
   - Link to related issues
   - Checklist of changes
   - Request review from OverseerAI

### Pull Request Template

```markdown
## Pull Request: [Title]

**Related Issue**: #[issue-number]  
**Type**: [Feature/Bugfix/Refactor/Docs]

### Description
[Description of changes]

### Changes Made
- [Change 1]
- [Change 2]
- [Change 3]

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

### Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated

### Screenshots (if applicable)
[Screenshots or GIFs]

### Additional Notes
[Any additional context]
```

### Review Process

1. **OverseerAI Review**:
   - Reviews code changes
   - Comments on issues
   - Requests changes if needed
   - Approves when ready

2. **CoderAI Response**:
   - Addresses review comments
   - Makes requested changes
   - Responds to questions

3. **Merge**:
   - OverseerAI merges to master
   - Deletes feature branch
   - Closes related issues

## GitHub Labels

### Priority Labels
- `priority:critical` - Urgent, needs immediate attention
- `priority:high` - High priority, address soon
- `priority:medium` - Normal priority
- `priority:low` - Low priority, can wait

### Type Labels
- `bug` - Bug report
- `enhancement` - Feature request
- `review` - Code review
- `task` - Task assignment
- `docs` - Documentation

### Status Labels
- `status:in-progress` - Currently being worked on
- `status:review` - Under review
- `status:approved` - Approved, ready to merge
- `status:rejected` - Rejected, needs changes

### Component Labels
- `component:communication` - Maildir communication
- `component:memory` - BrainState management
- `component:models` - Data models
- `component:roles` - AI roles
- `component:viewmodels` - SwiftUI ViewModels
- `component:tests` - Testing

## Automated Scripts

### Creating Issues

Use `create_github_issue.py` to create GitHub issues:

```bash
python3 create_github_issue.py \
  --title "Code Review: MaildirCommunication" \
  --label "review,priority:high" \
  --template code_review \
  --file review_content.md
```

### Updating Issues

Use `update_github_issue.py` to update existing issues:

```bash
python3 update_github_issue.py \
  --issue-number 123 \
  --comment "Issue #1 has been resolved"
```

### Creating Pull Requests

Use `create_pull_request.py` to create PRs:

```bash
python3 create_pull_request.py \
  --title "Feature: Add new communication protocol" \
  --source-branch feature/new-protocol \
  --target-branch master \
  --issue-number 123
```

## Daily Workflow

### OverseerAI Daily Tasks

1. **Morning**:
   - Check for new pull requests
   - Review and comment on PRs
   - Check for new issues

2. **Midday**:
   - Conduct code reviews
   - Create review issues
   - Test merged changes

3. **Evening**:
   - Review progress on issues
   - Plan next day's tasks
   - Update project status

### CoderAI Daily Tasks

1. **Morning**:
   - Check for assigned issues
   - Review feedback on PRs
   - Plan development work

2. **Midday**:
   - Implement features/fixes
   - Create pull requests
   - Address review comments

3. **Evening**:
   - Run tests
   - Update issue status
   - Report progress

## Integration with Maildir

While GitHub is the primary collaboration tool, Maildir is still used for:
- Urgent notifications
- Real-time communication
- System messages
- Non-code-related discussions

### Maildir Message Types

- `notification`: Notify about new GitHub issues/PRs
- `reminder`: Remind about pending reviews
- `urgent`: Critical issues requiring immediate attention
- `status`: Daily status updates

## Best Practices

### For OverseerAI

1. **Timely Reviews**: Review PRs within 24 hours
2. **Clear Feedback**: Provide specific, actionable comments
3. **Proper Labels**: Use consistent labeling
4. **Link Issues**: Connect PRs to related issues
5. **Document Decisions**: Explain why changes are needed

### For CoderAI

1. **Clear Commits**: Write descriptive commit messages
2. **Small PRs**: Keep pull requests focused
3. **Self-Review**: Review your own code before submitting
4. **Test Thoroughly**: Run all tests before creating PR
5. **Respond Promptly**: Address review comments quickly

### For Both

1. **Consistent Naming**: Follow branch naming conventions
2. **Link Everything**: Connect issues, PRs, and commits
3. **Use Templates**: Use issue and PR templates
4. **Keep Updated**: Sync regularly with master
5. **Communicate**: Use Maildir for urgent matters

## Monitoring and Reporting

### Weekly Reports

Generate weekly reports using `generate_weekly_report.py`:

```bash
python3 generate_weekly_report.py \
  --start-date 2024-01-01 \
  --end-date 2024-01-07
```

Report includes:
- Issues created/closed
- Pull requests merged
- Code reviews completed
- Branches created/deleted
- Test coverage changes

### Metrics to Track

- Issue resolution time
- Pull request review time
- Test coverage percentage
- Number of bugs found
- Feature completion rate

## Emergency Procedures

### Critical Bug Found

1. Create issue with `priority:critical` label
2. Send Maildir notification to CoderAI
3. Create hotfix branch immediately
4. Review and merge quickly
5. Deploy hotfix

### Collaboration Breakdown

1. Identify the issue
2. Create GitHub issue to track
3. Use Maildir for real-time discussion
4. Document the problem
5. Implement solution
6. Update workflow to prevent recurrence

## Tools and Scripts

All collaboration scripts are located in:
```
/Users/jk/gits/hub/gitbrains/GitBrain/roles/overseer/github_scripts/
```

Available scripts:
- `create_github_issue.py` - Create GitHub issues
- `update_github_issue.py` - Update existing issues
- `create_pull_request.py` - Create pull requests
- `merge_pull_request.py` - Merge pull requests
- `generate_weekly_report.py` - Generate collaboration reports
- `sync_branches.py` - Sync branches with remote

## Conclusion

This GitHub-based workflow provides:
- ✅ Better issue tracking and management
- ✅ Clear code review process
- ✅ Version control for all changes
- ✅ Historical record of all collaboration
- ✅ Integration with Maildir for urgent matters
- ✅ Automated tools for efficiency
- ✅ Clear responsibilities and workflows

By leveraging GitHub's powerful features, we can collaborate more efficiently and maintain higher code quality.
