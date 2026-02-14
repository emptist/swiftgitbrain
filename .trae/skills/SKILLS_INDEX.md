# Skills Index

This directory contains skills for autonomous AI development in the GitBrainSwift project.

## Available Skills

### Core Development Skills

#### [Development Planning](./development_planning/SKILL.md)
**Purpose**: Analyze requirements and create structured development plans

**When to Use**:
- Receiving new development tasks
- Planning complex multi-step implementations
- Estimating effort and dependencies
- Assessing risks and mitigation strategies

**Output**: Structured task breakdown with phases, tasks, and risks

#### [Task Execution](./task_execution/SKILL.md)
**Purpose**: Autonomously execute development tasks following patterns

**When to Use**:
- Implementing features or bug fixes
- Writing code following a plan
- Making changes to existing code
- Creating new components

**Output**: Working code, tests, and documentation

#### [Testing](./testing/SKILL.md)
**Purpose**: Write, execute, and validate tests using Swift Testing framework

**When to Use**:
- Implementing new features (TDD approach)
- Fixing bugs (regression tests)
- Refactoring code (prevent regressions)
- Validating implementation quality

**Output**: Comprehensive test suites with high coverage

#### [Documentation Generation](./documentation_generation/SKILL.md)
**Purpose**: Generate and maintain documentation following project standards

**When to Use**:
- After implementing new features
- Updating existing documentation
- Creating API documentation
- Writing usage guides

**Output**: Clear, accurate documentation with examples

### Collaboration Skills

#### [Create Status Update](./create_status_update/SKILL.md)
**Purpose**: Create standardized status updates for Monitor

**When to Use**:
- After making progress
- When encountering issues
- Periodically during long tasks
- When requested by Monitor

**Output**: JSON status update with progress and next steps

#### [Apply Review Feedback](./apply_review_feedback/SKILL.md)
**Purpose**: Apply code review feedback from Monitor

**When to Use**:
- Receiving review feedback
- Addressing code quality issues
- Fixing implementation problems

**Output**: Corrected code addressing all feedback

#### [Keep Working](./keep-working/SKILL.md)
**Purpose**: Maintain continuous AI collaboration by avoiding "completed" marks

**When to Use**:
- Always! Use this skill to keep AIs alive

**Output**: Continuous collaboration without sleep

### Workflow Skills

#### [Process To Process Folder](./process_to_process_folder/SKILL.md)
**Purpose**: Automatically process messages from ToProcess folder

**When to Use**:
- New messages appear in GitBrain/Memory/ToProcess/
- Periodically checking for new tasks
- Processing incoming communications

**Output**: Processed messages and status updates

#### [Move Processed Files](./move_processed_files/SKILL.md)
**Purpose**: Move processed files from ToProcess to Processed folder

**When to Use**:
- After processing messages
- When cleaning up completed tasks
- Maintaining folder organization

**Output**: Organized file structure

#### [Skill Creator](./skill-creator/SKILL.md)
**Purpose**: Create new skills for autonomous development

**When to Use**:
- Need for new autonomous capability
- Standardizing recurring workflows
- Creating reusable patterns

**Output**: New skill with documentation

## Skill Usage Workflow

### 1. Identify Need
Determine what needs to be done:
- New task or feature?
- Need to plan or execute?
- Need to test or document?
- Need to collaborate?

### 2. Select Skill
Choose appropriate skill:
- **Planning** → Development Planning
- **Implementation** → Task Execution
- **Quality** → Testing
- **Documentation** → Documentation Generation
- **Collaboration** → Create Status Update / Apply Review Feedback

### 3. Follow Skill
Execute skill instructions:
- Read skill documentation
- Follow step-by-step process
- Use provided templates
- Follow best practices

### 4. Update Status
Report progress:
- Use Create Status Update skill
- Report every 5-10 minutes
- Include files modified
- List next steps

### 5. Store Learnings
Capture knowledge:
- Store patterns in GitBrain
- Document decisions made
- Note issues encountered
- Share solutions with other AIs

## Skill Development

### Creating New Skills

Use the [Skill Creator](./skill-creator/SKILL.md) to create new skills:

1. **Identify Need**: What autonomous capability is needed?
2. **Design Skill**: Define purpose, when to use, and process
3. **Write Documentation**: Clear instructions and examples
4. **Test Skill**: Verify it works as expected
5. **Register Skill**: Add to this index

### Skill Template

```markdown
# Skill Name

## Description
<Brief description of what this skill does>

## When to Use
<When this skill should be invoked>

## Process
<Step-by-step instructions>

## Output Format
<What the skill produces>

## Best Practices
<Tips for using this skill effectively>

## Integration with GitBrain
<How this skill interacts with GitBrain>

## Example
<Concrete example of skill usage>

## Related Skills
<Links to related skills>
```

## Best Practices

### For AIs Using Skills

1. **Always Read First**: Understand skill before using
2. **Follow Process**: Don't skip steps
3. **Use Templates**: Leverage provided formats
4. **Report Progress**: Use status updates regularly
5. **Store Learnings**: Contribute to GitBrain
6. **Ask for Help**: If stuck or uncertain

### For Creating Skills

1. **Be Specific**: Clear purpose and use cases
2. **Be Complete**: Cover all aspects of the task
3. **Be Tested**: Verify skill works
4. **Be Documented**: Provide examples and templates
5. **Be Integrated**: Connect with GitBrain and other skills

## Skill Maintenance

### Updating Skills

When skills need improvement:

1. **Identify Issue**: What's not working well?
2. **Propose Change**: How to improve the skill?
3. **Test Change**: Verify improvement works
4. **Update Documentation**: Keep skills current
5. **Communicate**: Tell other AIs about changes

### Deprecating Skills

When skills are no longer needed:

1. **Mark Deprecated**: Add deprecation notice
2. **Suggest Alternative**: What to use instead?
3. **Update References**: Remove from active use
4. **Archive**: Keep for historical reference
5. **Remove from Index**: Update this document

## Contributing

To contribute new skills:

1. **Create Skill**: Follow skill template
2. **Test Thoroughly**: Ensure it works correctly
3. **Document Clearly**: Provide examples and best practices
4. **Add to Index**: Update this file
5. **Share with Team**: Let other AIs know

## Related Documentation

- [AI Self-Driven Development Framework](../../Documentation/AI_Self_Driven_Development.md)
- [API Documentation](../../Documentation/API.md)
- [Project README](../../README.md)