# Contributing to GitBrainSwift

Thank you for your interest in contributing to GitBrainSwift! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## Getting Started

### Prerequisites

- Swift 6.2 or later
- Swift Package Manager
- Git
- macOS 15+ (for development)

### Setting Up Development Environment

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gitbrainswift.git
cd gitbrainswift
```

2. Build the project:
```bash
swift build
```

3. Run tests:
```bash
swift test
```

## Development Workflow

### Branching Strategy

- `main`: Stable, production-ready code
- `develop`: Development branch for new features
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches
- `hotfix/*`: Critical hotfixes

### Creating a Feature Branch

1. Ensure your `develop` branch is up to date:
```bash
git checkout develop
git pull origin develop
```

2. Create a new feature branch:
```bash
git checkout -b feature/your-feature-name
```

### Making Changes

#### Code Style Guidelines

Follow these Swift coding standards:

- Use Swift 6.2 best practices
- Use Protocol-Oriented Programming (POP)
- Ensure Sendable protocol compliance for concurrent code
- Use proper async/await syntax
- Write clear, readable code
- Add appropriate error handling
- Use meaningful variable and function names
- Add comments for complex logic
- Avoid force unwrapping (`!`) - use safe unwrapping instead

#### Naming Conventions

- **Types**: PascalCase (e.g., `GitManager`, `FileBasedCommunication`)
- **Functions/Methods**: camelCase (e.g., `sendMessageToOverseer`, `getMessagesForCoder`)
- **Variables/Properties**: camelCase (e.g., `overseerFolder`, `fileManager`)
- **Constants**: camelCase (e.g., `defaultTimeout`, `maxRetries`)
- **Enums**: PascalCase (e.g., `GitError`, `CommunicationError`)

#### Architecture Guidelines

- Follow MVVM architecture where applicable
- Use actors for concurrent code
- Implement protocols for extensibility
- Separate concerns (communication, validation, storage)
- Use dependency injection

#### Error Handling

- Use Swift's error handling with `throws` and `try`
- Create custom error types with `LocalizedError` conformance
- Provide descriptive error messages
- Handle errors gracefully
- Log errors appropriately

#### Testing Guidelines

- Use Swift Testing Framework (not XCTest)
- Write comprehensive tests for all public APIs
- Test both success and failure cases
- Use proper async/await syntax in tests
- Ensure tests are independent and repeatable
- Aim for at least 80% code coverage
- Add integration tests for complex workflows

#### Documentation Guidelines

- Document all public APIs
- Add comments for complex logic
- Keep documentation up to date
- Include code examples
- Use clear and concise language

### Commit Guidelines

#### Commit Message Format

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(gitmanager): add configurable timeout for git commands

Add configurable timeout parameter to GitManager initializer
with default value of 30 seconds. This allows users to
adjust timeout based on their needs.

Closes #123
```

```
fix(communication): resolve file locking race condition

Implement proper file locking using flock() to prevent
concurrent access issues. Add retry logic with exponential
backoff for failed lock attempts.

Fixes #456
```

### Pull Request Process

1. **Update your branch**:
```bash
git checkout develop
git pull origin develop
git checkout feature/your-feature-name
git rebase develop
```

2. **Run tests**:
```bash
swift test
```

3. **Run linting** (if configured):
```bash
swiftlint
```

4. **Push your branch**:
```bash
git push origin feature/your-feature-name
```

5. **Create a Pull Request**:
   - Go to GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Target `develop` branch
   - Fill in the PR template

#### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added for new functionality
- [ ] All tests passing
```

#### Review Process

1. **Automated Checks**: CI/CD will run tests and linting
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any review comments
4. **Approval**: At least one maintainer approval required
5. **Merge**: Maintainer will merge to `develop`

## Reporting Issues

### Bug Reports

When reporting bugs, include:

- Clear description of the problem
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment (OS, Swift version)
- Screenshots/logs if applicable

### Feature Requests

When requesting features, include:

- Clear description of the feature
- Use case or problem it solves
- Proposed solution (if any)
- Alternative solutions considered

## Plugin Development

### Creating Plugins

See the [Plugin Development Guide](Documentation/PLUGIN_DEVELOPMENT.md) for detailed instructions on creating custom plugins.

### Submitting Plugins

1. Fork the repository
2. Create a feature branch for your plugin
3. Implement the plugin following the guidelines
4. Add tests and documentation
5. Submit a pull request

## Documentation

### Improving Documentation

- Fix typos and grammar errors
- Add missing information
- Improve clarity
- Add examples
- Update outdated information

### Documentation Structure

- `README.md`: Main project documentation
- `CONTRIBUTING.md`: Contribution guidelines (this file)
- `Documentation/`: Detailed documentation
  - `ARCHITECTURE.md`: Architecture overview
  - `API.md`: API documentation
  - `PLUGIN_DEVELOPMENT.md`: Plugin development guide
  - `TESTING.md`: Testing guidelines
  - `DESIGN_DECISIONS.md`: Design decisions

## Questions?

- Check existing issues and pull requests
- Read the documentation
- Ask questions in GitHub Discussions
- Contact maintainers

## License

By contributing to GitBrainSwift, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in the project's CONTRIBUTORS file and in release notes.

Thank you for contributing to GitBrainSwift!
