# GitBrain Migration Guide

This guide provides comprehensive instructions for migrating GitBrain from file-based storage to PostgreSQL.

## Overview

The migration process transfers data from file-based JSON storage to a PostgreSQL database using Fluent ORM. The migration includes:

- Knowledge Base: All knowledge items organized by categories
- Brain States: AI state information for CoderAI and OverseerAI

## Prerequisites

### Database Setup

1. **Install PostgreSQL**
   ```bash
   brew install postgresql
   brew services start postgresql
   ```

2. **Create Database**
   ```bash
   createdb gitbrain
   ```

3. **Configure Environment Variables**
   ```bash
   export GITBRAIN_DB_HOST=localhost
   export GITBRAIN_DB_PORT=5432
   export GITBRAIN_DB_NAME=gitbrain
   export GITBRAIN_DB_USER=$(whoami)
   export GITBRAIN_DB_PASSWORD=your_password
   ```

### Run Database Setup Script

```bash
./scripts/setup_database.sh
```

## Migration Process

### Step 1: Check Current State

```bash
swift run GitBrainMigrationCLI status
```

### Step 2: Create Snapshot (Optional but Recommended)

```bash
swift run GitBrainMigrationCLI snapshot --create
```

### Step 3: Dry Run Migration

```bash
swift run GitBrainMigrationCLI migrate --dry-run --verbose
```

### Step 4: Run Migration

```bash
swift run GitBrainMigrationCLI migrate --verbose
```

### Step 5: Validate Migration

```bash
swift run GitBrainMigrationCLI validate --verbose
```

### Step 6: Health Check

```bash
./scripts/health_check.sh
```

## Migration Commands

### Migrate Command

```bash
swift run GitBrainMigrationCLI migrate [options]
```

**Options:**
- `--source-path, -s`: Path to file-based storage directory
- `--knowledge-only, -k`: Migrate knowledge base only
- `--brain-state-only, -b`: Migrate brain states only
- `--dry-run, -d`: Preview migration without executing
- `--verbose, -v`: Enable verbose logging
- `--snapshot`: Create snapshot before migration (default: true)

### Rollback Command

```bash
swift run GitBrainMigrationCLI rollback [options]
```

**Options:**
- `--snapshot-id, -s`: Snapshot ID to rollback to
- `--knowledge-item, -k`: Rollback specific knowledge item (format: category/key)
- `--brain-state, -b`: Rollback specific brain state
- `--verbose, -v`: Enable verbose logging

### Status Command

```bash
swift run GitBrainMigrationCLI status [options]
```

**Options:**
- `--verbose, -v`: Enable verbose logging

### Validate Command

```bash
swift run GitBrainMigrationCLI validate [options]
```

**Options:**
- `--source-path, -s`: Path to file-based storage directory
- `--verbose, -v`: Enable verbose logging

### Snapshot Command

```bash
swift run GitBrainMigrationCLI snapshot [options]
```

**Options:**
- `--create, -c`: Create a new snapshot
- `--list, -l`: List all snapshots
- `--verbose, -v`: Enable verbose logging

## Error Handling

### Retry Logic

The migration includes automatic retry logic with exponential backoff:

- **Max Retries**: 5 attempts
- **Base Delay**: 1 second
- **Max Delay**: 60 seconds
- **Backoff Multiplier**: 2.0

Transient errors (timeout, connection, network, temporary, unavailable, busy, locked) are automatically retried.

### Rollback

If migration fails, you can rollback to a previous snapshot:

```bash
swift run GitBrainMigrationCLI rollback --snapshot-id <snapshot-id>
```

For emergency rollback:

```bash
./scripts/emergency_rollback.sh
```

## Troubleshooting

### Database Connection Issues

**Problem**: Cannot connect to PostgreSQL

**Solution**:
1. Check PostgreSQL is running: `brew services list`
2. Verify database exists: `psql -l`
3. Check environment variables: `env | grep GITBRAIN_DB`
4. Test connection: `psql -h localhost -U $(whoami) -d gitbrain`

### Migration Fails Midway

**Problem**: Migration stops with errors

**Solution**:
1. Check migration log: `cat GitBrain/Migration/migration.log`
2. Run health check: `./scripts/health_check.sh`
3. Rollback to snapshot: `swift run GitBrainMigrationCLI rollback --snapshot-id <id>`
4. Fix issues and retry migration

### Data Mismatch After Migration

**Problem**: File-based and database counts don't match

**Solution**:
1. Run validation: `swift run GitBrainMigrationCLI validate --verbose`
2. Check for .DS_Store files: `find ./GitBrain -name ".DS_Store"`
3. Verify migration log for errors
4. Consider selective rollback and re-migration

## Post-Migration

### Verify Data Integrity

```bash
swift run GitBrainMigrationCLI validate --verbose
./scripts/health_check.sh
```

### Update Application Configuration

Update your application to use PostgreSQL repositories:

```swift
let dbManager = try DatabaseManager.shared
let knowledgeRepo = FluentKnowledgeRepository(database: dbManager.database)
let brainStateRepo = FluentBrainStateRepository(database: dbManager.database)
```

### Backup Old Data (Optional)

After successful migration and verification, you may want to backup old file-based data:

```bash
tar -czf GitBrain_backup_$(date +%Y%m%d).tar.gz ./GitBrain
```

## Monitoring

### Migration Progress

Monitor migration progress with verbose mode:

```bash
swift run GitBrainMigrationCLI migrate --verbose
```

Progress is displayed with:
- Progress bar (█ = completed, ░ = remaining)
- Percentage complete
- Current phase (Discovery, Transfer, Verification)
- Items migrated vs total

### Health Checks

Run periodic health checks:

```bash
./scripts/health_check.sh
```

Health checks verify:
- Database connection
- Data integrity
- No duplicate entries
- File-based vs database counts

## Next Generation Setup

For new AI instances, use the provided reboot materials:

1. **Configuration Template**: `config/migration_config_template.json`
2. **Setup Instructions**: `Documentation/SETUP_INSTRUCTIONS.md`
3. **Health Check Script**: `scripts/health_check.sh`
4. **Emergency Rollback**: `scripts/emergency_rollback.sh`

## Support

For issues or questions:
1. Check migration logs: `GitBrain/Migration/migration.log`
2. Run health check: `./scripts/health_check.sh`
3. Review this guide
4. Check GitBrain documentation: `Documentation/API.md`

## Appendix

### Migration Phases

1. **Discovery**: Scan file-based storage for data
2. **Validation**: Verify data integrity before migration
3. **Transfer**: Move data to PostgreSQL
4. **Verification**: Confirm data migrated correctly
5. **Cleanup**: Optional: Remove old file-based data

### Data Structures

**Knowledge Item**:
- Category: String
- Key: String
- Value: SendableContent (JSON)
- Metadata: SendableContent (JSON)
- Timestamp: Date

**Brain State**:
- AI Name: String
- Role: RoleType (coder/overseer)
- State: SendableContent (JSON)
- Timestamp: Date

### Environment Variables

- `GITBRAIN_DB_HOST`: Database host (default: localhost)
- `GITBRAIN_DB_PORT`: Database port (default: 5432)
- `GITBRAIN_DB_NAME`: Database name (default: gitbrain)
- `GITBRAIN_DB_USER`: Database user (default: current user)
- `GITBRAIN_DB_PASSWORD`: Database password (required)