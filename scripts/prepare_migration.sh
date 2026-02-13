#!/bin/bash

# GitBrain Migration Preparation Script
# This script prepares the environment for migration testing

set -e

echo "🔧 Preparing GitBrain migration environment..."
echo ""

# Check PostgreSQL status
echo "Checking PostgreSQL status..."
if brew services list | grep postgresql | grep -q "started"; then
    echo "✅ PostgreSQL is running"
else
    echo "⚠️  PostgreSQL is not running"
    echo "Starting PostgreSQL..."
    brew services start postgresql
    sleep 2
fi

# Create test database if needed
DB_NAME="gitbrain_test"
DB_USER="${USER}"

echo ""
echo "Checking test database..."
if psql -h localhost -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>&1 | grep -q 1; then
    echo "✅ Test database '$DB_NAME' already exists"
else
    echo "Creating test database '$DB_NAME'..."
    createdb -h localhost "$DB_NAME"
    echo "✅ Test database '$DB_NAME' created"
fi

# Grant privileges
echo "Granting privileges..."
psql -h localhost -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" > /dev/null 2>&1 || true

# Set environment variables
echo ""
echo "📋 Environment variables:"
export GITBRAIN_DB_HOST=localhost
export GITBRAIN_DB_PORT=5432
export GITBRAIN_DB_NAME=$DB_NAME
export GITBRAIN_DB_USER=$DB_USER
export GITBRAIN_DB_PASSWORD=""

echo "   GITBRAIN_DB_HOST=localhost"
echo "   GITBRAIN_DB_PORT=5432"
echo "   GITBRAIN_DB_NAME=$DB_NAME"
echo "   GITBRAIN_DB_USER=$DB_USER"
echo "   GITBRAIN_DB_PASSWORD=(empty)"

# Create test data structure
echo ""
echo "📁 Creating test data structure..."
mkdir -p GitBrain/Knowledge
mkdir -p GitBrain/BrainState

echo "✅ Test directories created"

# Test migration CLI
echo ""
echo "🧪 Testing migration CLI..."
swift run gitbrain-migrate --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Migration CLI is ready"
else
    echo "❌ Migration CLI test failed"
    exit 1
fi

echo ""
echo "🎉 Migration environment is ready!"
echo ""
echo "Next steps:"
echo "1. Run: swift run gitbrain-migrate status"
echo "2. Run: swift run gitbrain-migrate validate --source-path ."
echo "3. Run: swift run gitbrain-migrate migrate --dry-run --verbose"
echo "4. When ready: swift run gitbrain-migrate migrate --verbose"
echo ""