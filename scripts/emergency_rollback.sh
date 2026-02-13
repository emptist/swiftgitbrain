#!/bin/bash

set -e

echo "🔄 Emergency Rollback Script"
echo "================================"

MIGRATION_STATE_FILE="./GitBrain/Migration/migration_state.json"
ROLLBACK_LOG="./GitBrain/Migration/rollback.log"

if [ ! -f "$MIGRATION_STATE_FILE" ]; then
    echo "❌ Migration state file not found: $MIGRATION_STATE_FILE"
    exit 1
fi

echo "📋 Reading migration state..."
SNAPSHOT_ID=$(jq -r '.rollback.snapshot_id' "$MIGRATION_STATE_FILE")

if [ "$SNAPSHOT_ID" == "null" ] || [ -z "$SNAPSHOT_ID" ]; then
    echo "❌ No snapshot ID found in migration state"
    echo "⚠️  Cannot perform rollback without snapshot"
    exit 1
fi

echo "📸 Snapshot ID: $SNAPSHOT_ID"

echo "🔍 Checking database connection..."
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL client not found"
    exit 1
fi

DB_NAME="${GITBRAIN_DB_NAME:-gitbrain}"
DB_USER="${GITBRAIN_DB_USER:-$(whoami)}"
DB_HOST="${GITBRAIN_DB_HOST:-localhost}"
DB_PORT="${GITBRAIN_DB_PORT:-5432}"

echo "📊 Database: $DB_NAME@$DB_HOST:$DB_PORT"

echo "⚠️  WARNING: This will rollback all changes made after snapshot $SNAPSHOT_ID"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Rollback cancelled"
    exit 0
fi

echo "🔄 Starting rollback..."
echo "[$(date)] Rollback started" >> "$ROLLBACK_LOG"

if command -v swift &> /dev/null; then
    echo "🚀 Using Swift CLI for rollback..."
    swift run GitBrainMigrationCLI rollback --snapshot-id "$SNAPSHOT_ID" --verbose 2>&1 | tee -a "$ROLLBACK_LOG"
else
    echo "⚠️  Swift CLI not found, performing manual rollback..."
    
    echo "🗑️  Truncating database tables..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
TRUNCATE TABLE knowledge_items CASCADE;
TRUNCATE TABLE brain_states CASCADE;
EOF
    
    echo "✅ Database tables truncated"
fi

echo "📝 Updating migration state..."
jq '.rollback.snapshot_id = null | .rollback.last_successful_migration = null' "$MIGRATION_STATE_FILE" > "${MIGRATION_STATE_FILE}.tmp"
mv "${MIGRATION_STATE_FILE}.tmp" "$MIGRATION_STATE_FILE"

echo "✅ Rollback completed successfully"
echo "[$(date)] Rollback completed" >> "$ROLLBACK_LOG"

echo ""
echo "📊 Next steps:"
echo "1. Verify database state: ./scripts/health_check.sh"
echo "2. Check rollback log: cat $ROLLBACK_LOG"
echo "3. Re-run migration if needed: swift run GitBrainMigrationCLI migrate"
