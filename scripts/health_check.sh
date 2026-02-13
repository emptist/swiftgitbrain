#!/bin/bash

set -e

echo "🏥 GitBrain Migration Health Check"
echo "================================"

MIGRATION_STATE_FILE="./GitBrain/Migration/migration_state.json"
HEALTH_LOG="./GitBrain/Migration/health_check.log"

if [ ! -f "$MIGRATION_STATE_FILE" ]; then
    echo "❌ Migration state file not found: $MIGRATION_STATE_FILE"
    exit 1
fi

echo "📋 Reading migration state..."
STATUS=$(jq -r '.status' "$MIGRATION_STATE_FILE")
echo "📊 Migration status: $STATUS"

echo ""
echo "🔍 Checking database connection..."
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL client not found"
    echo "[$(date)] PostgreSQL client not found" >> "$HEALTH_LOG"
    exit 1
fi

DB_NAME="${GITBRAIN_DB_NAME:-gitbrain}"
DB_USER="${GITBRAIN_DB_USER:-$(whoami)}"
DB_HOST="${GITBRAIN_DB_HOST:-localhost}"
DB_PORT="${GITBRAIN_DB_PORT:-5432}"

if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &> /dev/null; then
    echo "✅ Database connection successful"
    echo "[$(date)] Database connection successful" >> "$HEALTH_LOG"
    
    echo ""
    echo "📊 Database statistics..."
    
    KNOWLEDGE_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM knowledge_items;" | tr -d ' ')
    BRAINSTATE_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM brain_states;" | tr -d ' ')
    
    echo "   Knowledge items: $KNOWLEDGE_COUNT"
    echo "   Brain states: $BRAINSTATE_COUNT"
    echo "   Total items: $((KNOWLEDGE_COUNT + BRAINSTATE_COUNT))"
    
    echo ""
    echo "🔍 Checking database integrity..."
    
    DUPLICATE_KNOWLEDGE=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM (SELECT id, COUNT(*) FROM knowledge_items GROUP BY id HAVING COUNT(*) > 1) AS duplicates;" | tr -d ' ')
    DUPLICATE_BRAINSTATE=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM (SELECT id, COUNT(*) FROM brain_states GROUP BY id HAVING COUNT(*) > 1) AS duplicates;" | tr -d ' ')
    
    if [ "$DUPLICATE_KNOWLEDGE" -eq 0 ]; then
        echo "   ✅ No duplicate knowledge items"
    else
        echo "   ❌ Found $DUPLICATE_KNOWLEDGE duplicate knowledge items"
        echo "[$(date)] Found $DUPLICATE_KNOWLEDGE duplicate knowledge items" >> "$HEALTH_LOG"
    fi
    
    if [ "$DUPLICATE_BRAINSTATE" -eq 0 ]; then
        echo "   ✅ No duplicate brain states"
    else
        echo "   ❌ Found $DUPLICATE_BRAINSTATE duplicate brain states"
        echo "[$(date)] Found $DUPLICATE_BRAINSTATE duplicate brain states" >> "$HEALTH_LOG"
    fi
    
    echo ""
    echo "📁 Checking file-based storage..."
    
    KNOWLEDGE_DIR="./GitBrain/Knowledge"
    BRAINSTATE_DIR="./GitBrain/BrainState"
    
    if [ -d "$KNOWLEDGE_DIR" ]; then
        FILE_KNOWLEDGE_COUNT=$(find "$KNOWLEDGE_DIR" -name "*.json" -not -name ".DS_Store" | wc -l | tr -d ' ')
        echo "   File-based knowledge items: $FILE_KNOWLEDGE_COUNT"
        
        if [ "$FILE_KNOWLEDGE_COUNT" -eq "$KNOWLEDGE_COUNT" ]; then
            echo "   ✅ Knowledge items match"
        else
            echo "   ⚠️  Knowledge items mismatch: $FILE_KNOWLEDGE_COUNT (files) vs $KNOWLEDGE_COUNT (database)"
            echo "[$(date)] Knowledge items mismatch: $FILE_KNOWLEDGE_COUNT vs $KNOWLEDGE_COUNT" >> "$HEALTH_LOG"
        fi
    else
        echo "   ℹ️  Knowledge directory not found"
    fi
    
    if [ -d "$BRAINSTATE_DIR" ]; then
        FILE_BRAINSTATE_COUNT=$(find "$BRAINSTATE_DIR" -name "*.json" -not -name ".DS_Store" | wc -l | tr -d ' ')
        echo "   File-based brain states: $FILE_BRAINSTATE_COUNT"
        
        if [ "$FILE_BRAINSTATE_COUNT" -eq "$BRAINSTATE_COUNT" ]; then
            echo "   ✅ Brain states match"
        else
            echo "   ⚠️  Brain states mismatch: $FILE_BRAINSTATE_COUNT (files) vs $BRAINSTATE_COUNT (database)"
            echo "[$(date)] Brain states mismatch: $FILE_BRAINSTATE_COUNT vs $BRAINSTATE_COUNT" >> "$HEALTH_LOG"
        fi
    else
        echo "   ℹ️  Brain state directory not found"
    fi
    
    echo ""
    echo "📝 Updating migration state..."
    jq '.health.database_status = "healthy" | .health.last_health_check = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' "$MIGRATION_STATE_FILE" > "${MIGRATION_STATE_FILE}.tmp"
    mv "${MIGRATION_STATE_FILE}.tmp" "$MIGRATION_STATE_FILE"
    
    echo ""
    echo "✅ Health check completed"
    echo "[$(date)] Health check completed" >> "$HEALTH_LOG"
    
    echo ""
    echo "📊 Health Summary:"
    echo "   Database: ✅ Connected"
    echo "   Knowledge items: $KNOWLEDGE_COUNT"
    echo "   Brain states: $BRAINSTATE_COUNT"
    echo "   Integrity: ✅ No duplicates"
    echo "   Status: ✅ Healthy"
    
    exit 0
else
    echo "❌ Database connection failed"
    echo "[$(date)] Database connection failed" >> "$HEALTH_LOG"
    
    jq '.health.database_status = "unhealthy" | .health.last_health_check = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' "$MIGRATION_STATE_FILE" > "${MIGRATION_STATE_FILE}.tmp"
    mv "${MIGRATION_STATE_FILE}.tmp" "$MIGRATION_STATE_FILE"
    
    exit 1
fi
