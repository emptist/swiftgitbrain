# GitBrain Setup Instructions

This guide provides step-by-step instructions for setting up GitBrain for the next generation of AI instances.

## Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd swiftgitbrain
```

### 2. Install Dependencies

```bash
brew install postgresql swift
```

### 3. Setup Database

```bash
createdb gitbrain
./scripts/setup_database.sh
```

### 4. Configure Environment

```bash
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=gitbrain
export GITBRAIN_DB_USER=$(whoami)
export GITBRAIN_DB_PASSWORD=your_password
```

### 5. Run Migration (if applicable)

```bash
swift run GitBrainMigrationCLI migrate --verbose
```

### 6. Verify Setup

```bash
swift run GitBrainCLI --help
./scripts/health_check.sh
```

## Detailed Setup

### Database Configuration

#### PostgreSQL Installation

**macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**Linux:**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Windows:**
Download and install from [postgresql.org](https://www.postgresql.org/download/windows/)

#### Database Creation

```bash
createdb gitbrain
psql -d gitbrain -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
```

#### Database Connection Test

```bash
psql -h localhost -U $(whoami) -d gitbrain -c "SELECT 1;"
```

### Application Configuration

#### Configuration File

Copy the template and customize:

```bash
cp config/migration_config_template.json config/migration_config.json
```

Edit `config/migration_config.json` with your settings:

```json
{
  "database": {
    "type": "postgresql",
    "host": "localhost",
    "port": 5432,
    "name": "gitbrain",
    "user": "your_username",
    "password": "your_password"
  }
}
```

#### Environment Variables

Create `.env` file:

```bash
GITBRAIN_DB_HOST=localhost
GITBRAIN_DB_PORT=5432
GITBRAIN_DB_NAME=gitbrain
GITBRAIN_DB_USER=your_username
GITBRAIN_DB_PASSWORD=your_password
```

Source the environment variables:

```bash
source .env
```

### Migration Setup

#### Initial Migration

If migrating from file-based storage:

```bash
swift run GitBrainMigrationCLI migrate --source-path ./GitBrain --verbose
```

#### Migration Validation

```bash
swift run GitBrainMigrationCLI validate --verbose
./scripts/health_check.sh
```

#### Rollback (if needed)

```bash
swift run GitBrainMigrationCLI rollback --snapshot-id <snapshot-id>
./scripts/emergency_rollback.sh
```

### Application Build

#### Build Project

```bash
swift build
```

#### Run Tests

```bash
swift test
```

#### Build CLI Tools

```bash
swift build -c release
```

CLI tools will be available in `.build/release/`:

- `GitBrainCLI` - Main GitBrain CLI
- `GitBrainMigrationCLI` - Migration CLI

## Architecture Overview

### Components

1. **KnowledgeBase** - Stores and retrieves knowledge items
2. **BrainStateManager** - Manages AI state information
3. **DataMigration** - Handles data migration from file-based to PostgreSQL
4. **DatabaseManager** - Manages database connections
5. **Communication** - Handles inter-AI communication

### Data Flow

```
File-Based Storage → DataMigration → PostgreSQL → KnowledgeBase/BrainStateManager
```

### Repository Pattern

The system uses a repository pattern for data access:

- `KnowledgeRepositoryProtocol` - Abstract knowledge storage
- `BrainStateRepositoryProtocol` - Abstract brain state storage
- `FluentKnowledgeRepository` - PostgreSQL implementation
- `FluentBrainStateRepository` - PostgreSQL implementation

## Troubleshooting

### Database Issues

**Problem**: Cannot connect to PostgreSQL

**Solution**:
1. Check PostgreSQL is running: `brew services list`
2. Verify database exists: `psql -l`
3. Test connection: `psql -h localhost -U $(whoami) -d gitbrain`

### Build Issues

**Problem**: Swift build fails

**Solution**:
1. Clean build: `swift package clean`
2. Update dependencies: `swift package update`
3. Check Swift version: `swift --version` (requires 6.2+)

### Migration Issues

**Problem**: Migration fails

**Solution**:
1. Check migration logs: `cat GitBrain/Migration/migration.log`
2. Run health check: `./scripts/health_check.sh`
3. Rollback if needed: `./scripts/emergency_rollback.sh`

## Advanced Configuration

### Custom Retry Policy

Modify retry behavior in `DataMigration.swift`:

```swift
let retryPolicy = RetryPolicy(
    maxRetries: 10,
    baseDelay: 0.5,
    maxDelay: 120.0,
    backoffMultiplier: 3.0
)
```

### Custom Progress Reporting

Implement `MigrationProgressProtocol`:

```swift
struct CustomProgress: MigrationProgressProtocol {
    func reportProgress(phase: String, current: Int, total: Int, message: String) {
        print("[\(phase)] \(current)/\(total): \(message)")
    }
    
    func reportError(error: Error, context: String) {
        print("ERROR in \(context): \(error)")
    }
    
    func reportCompletion(result: MigrationResult) {
        print("Migration complete: \(result.itemsMigrated) items")
    }
}
```

### Custom Logging

Configure logging in `Logger.swift`:

```swift
GitBrainLogger.configure(level: .debug, file: "./GitBrain/logs/gitbrain.log")
```

## Monitoring

### Health Checks

Run periodic health checks:

```bash
./scripts/health_check.sh
```

### Migration Monitoring

Monitor migration progress:

```bash
swift run GitBrainMigrationCLI migrate --verbose
```

### Log Monitoring

View migration logs:

```bash
tail -f GitBrain/Migration/migration.log
```

View health check logs:

```bash
tail -f GitBrain/Migration/health_check.log
```

## Backup and Recovery

### Database Backup

```bash
pg_dump -h localhost -U $(whoami) gitbrain > gitbrain_backup.sql
```

### Database Restore

```bash
psql -h localhost -U $(whoami) gitbrain < gitbrain_backup.sql
```

### File-Based Backup

```bash
tar -czf GitBrain_backup_$(date +%Y%m%d).tar.gz ./GitBrain
```

## Next Steps

1. **Read the API Documentation**: `Documentation/API.md`
2. **Review Migration Guide**: `Documentation/MIGRATION_GUIDE.md`
3. **Explore Skills**: `.trae/skills/SKILLS_INDEX.md`
4. **Run Tests**: `swift test`
5. **Start Development**: `swift run GitBrainCLI`

## Support

For issues or questions:

1. Check logs in `GitBrain/Migration/`
2. Run health check: `./scripts/health_check.sh`
3. Review documentation in `Documentation/`
4. Check migration state: `cat GitBrain/Migration/migration_state.json`

## Appendix

### Environment Variables Reference

| Variable | Description | Default |
|-----------|-------------|----------|
| `GITBRAIN_DB_HOST` | Database host | localhost |
| `GITBRAIN_DB_PORT` | Database port | 5432 |
| `GITBRAIN_DB_NAME` | Database name | gitbrain |
| `GITBRAIN_DB_USER` | Database user | Current user |
| `GITBRAIN_DB_PASSWORD` | Database password | Required |

### Directory Structure

```
swiftgitbrain/
├── Sources/
│   ├── GitBrainSwift/
│   │   ├── Database/
│   │   ├── Migration/
│   │   ├── Models/
│   │   ├── Protocols/
│   │   ├── Repositories/
│   │   └── ...
│   ├── GitBrainCLI/
│   └── GitBrainMigrationCLI/
├── Tests/
│   └── GitBrainSwiftTests/
├── GitBrain/
│   ├── Knowledge/
│   ├── BrainState/
│   └── Migration/
├── Documentation/
├── scripts/
├── config/
└── Package.swift
```

### CLI Commands Reference

**GitBrainCLI**:
- `help` - Show help
- `status` - Check status
- `query` - Query knowledge
- `state` - Manage brain state

**GitBrainMigrationCLI**:
- `migrate` - Run migration
- `rollback` - Rollback migration
- `status` - Check migration status
- `validate` - Validate migration
- `snapshot` - Manage snapshots