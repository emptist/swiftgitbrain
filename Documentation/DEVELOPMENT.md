# Developer Guide

This guide provides comprehensive information for developers who want to build, test, and contribute to GitBrainSwift.

## Prerequisites

- **Swift 6.2** or later
- **macOS 15.0** or later (minimum deployment target)
- **Xcode** (optional, for development with Xcode)
- **Git** (for version control)

### Installing Swift

```bash
# On macOS with Homebrew
brew install swift

# Verify installation
swift --version
```

## Building the Project

### Building from Source

#### Using Swift Package Manager

```bash
# Navigate to the project directory
cd /path/to/gitbrainswift

# Build the project (debug configuration)
swift build

# Build with release configuration (optimized)
swift build -c release
```

#### Build Output

After building, the binaries are located in:
- **Debug**: `.build/debug/`
- **Release**: `.build/release/`

```
.build/
├── debug/
│   ├── gitbrain                    # CLI executable (debug)
│   ├── GitBrainSwift.build/
│   └── ...
└── release/
    ├── gitbrain                    # CLI executable (release)
    ├── GitBrainSwift.build/
    └── ...
```

### Building Specific Targets

```bash
# Build only the CLI tool
swift build --target GitBrainCLI

# Build only the library
swift build --target GitBrainSwift

# Build plugin test executable
swift build --target PluginTest
```

### Build Options

```bash
# Enable verbose output
swift build --verbose

# Build with specific Swift version
swift build --swift-version 6.2

# Clean build artifacts before building
swift build --clean
```

## Creating a Binary

### Creating a Release Binary

```bash
# Build in release mode
swift build -c release

# The binary is now available at:
# .build/release/gitbrain
```

### Verifying the Binary

```bash
# Check the binary
ls -lh .build/release/gitbrain

# Test the binary
.build/release/gitbrain --help

# Verify binary architecture
file .build/release/gitbrain
# Output: Mach-O 64-bit executable arm64
```

## Installing Globally

### Method 1: Copy to /usr/local/bin

```bash
# Build release binary
swift build -c release

# Copy to system path
sudo cp .build/release/gitbrain /usr/local/bin/gitbrain

# Make executable (if needed)
sudo chmod +x /usr/local/bin/gitbrain

# Verify installation
gitbrain --help
```

### Method 2: Create Symbolic Link

```bash
# Build release binary
swift build -c release

# Create symbolic link
sudo ln -s $(pwd)/.build/release/gitbrain /usr/local/bin/gitbrain

# Verify installation
gitbrain --help
```

### Method 3: Add to PATH

```bash
# Add build directory to PATH (temporary)
export PATH="$PATH:$(pwd)/.build/release"

# Add to shell configuration (permanent)
echo 'export PATH="$PATH:$(pwd)/.build/release"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
gitbrain --help
```

## Development Workflow

### Setting Up Development Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/gitbrainswift.git
cd gitbrainswift

# Create a feature branch
git checkout -b feature/my-feature

# Build the project
swift build
```

### Running Tests

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose

# Run specific test
swift test --filter testMessageCreation

# Run tests in release mode
swift test -c release
```

### Code Quality

```bash
# Format code (if using SwiftFormat)
swiftformat Sources/ Tests/

# Lint code (if using SwiftLint)
swiftlint lint Sources/ Tests/
```

### Building Documentation

```bash
# Documentation is in Markdown format
# No build step required

# Preview documentation locally (if using a tool)
# Example: grip (GitHub README Instant Preview)
brew install grip
grip README.md
```

## Creating a Release

### Version Bumping

1. Update version in `Package.swift`:

```swift
let package = Package(
    name: "GitBrainSwift",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "GitBrainSwift",
            targets: ["GitBrainSwift"]
        ),
        .executable(
            name: "gitbrain",
            targets: ["GitBrainCLI"]
        )
    ],
    // ...
)
```

2. Update version in documentation files if needed

3. Commit changes:

```bash
git add Package.swift
git commit -m "bump: version to X.Y.Z"
```

### Creating Release Build

```bash
# Clean build artifacts
swift package clean

# Build release binary
swift build -c release

# Create release archive
cd .build/release
tar -czf gitbrain-x.y.z-darwin-arm64.tar.gz gitbrain
```

### Tagging Release

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to remote
git push origin v1.0.0
```

### GitHub Release

1. Go to GitHub repository releases page
2. Click "Draft a new release"
3. Select the tag you just pushed
4. Upload the release archive
5. Add release notes
6. Publish the release

## Troubleshooting

### Build Errors

#### Error: "Swift version not found"

**Solution**: Install Swift 6.2 or later

```bash
brew install swift
```

#### Error: "Module not found"

**Solution**: Clean build and rebuild

```bash
swift package clean
swift build
```

#### Error: "Permission denied"

**Solution**: Fix file permissions

```bash
chmod +x .build/debug/gitbrain
```

### Runtime Errors

#### Error: "command not found: gitbrain"

**Solution**: Add binary to PATH or install globally

```bash
# Temporary
export PATH="$PATH:$(pwd)/.build/release"

# Permanent
sudo cp .build/release/gitbrain /usr/local/bin/gitbrain
```

#### Error: "dyld: Library not loaded"

**Solution**: Ensure you're using the correct Swift runtime

```bash
# Rebuild with correct Swift version
swift build -c release
```

### Testing Issues

#### Error: "Test suite failed"

**Solution**: Run tests with verbose output to see details

```bash
swift test --verbose
```

#### Error: "No tests found"

**Solution**: Ensure test target is properly configured in Package.swift

```swift
.testTarget(
    name: "GitBrainSwiftTests",
    dependencies: ["GitBrainSwift"],
    path: "Tests/GitBrainSwiftTests"
)
```

## Performance Optimization

### Build Time Optimization

```bash
# Use incremental builds (default)
swift build

# Use build cache
swift build --enable-test-discovery

# Parallel build (default)
swift build -j $(sysctl -n hw.ncpu)
```

### Binary Size Optimization

```bash
# Strip debug symbols
strip .build/release/gitbrain

# Verify size reduction
ls -lh .build/release/gitbrain
```

## Contributing

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

### Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(cli): add message clear command
fix(communication): handle empty message queue
docs(readme): update installation instructions
```

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Update documentation if needed
7. Submit a pull request

## Additional Resources

- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Swift.org](https://swift.org/)
- [GitHub Actions Workflow](.github/workflows/release.yml)

## Getting Help

- Check the [README.md](README.md) for general information
- Review [CLI_TOOLS.md](Documentation/CLI_TOOLS.md) for CLI usage
- See [DESIGN_DECISIONS.md](Documentation/DESIGN_DECISIONS.md) for architectural decisions
- Open an issue on GitHub for bugs or feature requests
