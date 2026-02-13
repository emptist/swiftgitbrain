#!/bin/bash

# GitBrain Database Setup Script
# This script sets up PostgreSQL for GitBrainSwift integration testing

set -e

DB_NAME="gitbrain_test"
DB_USER="${USER}"

echo "Setting up GitBrain database..."
echo "Database name: $DB_NAME"
echo "Database user: $DB_USER"

# Check if database exists
if psql -h localhost -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>&1 | grep -q 1; then
    echo "Database '$DB_NAME' already exists"
else
    echo "Creating database '$DB_NAME'..."
    createdb -h localhost "$DB_NAME"
    echo "Database '$DB_NAME' created successfully"
fi

# Grant privileges
echo "Granting privileges..."
psql -h localhost -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" > /dev/null 2>&1 || true

echo "Database setup complete!"
echo ""
echo "Environment variables for testing:"
echo "export GITBRAIN_DB_HOST=localhost"
echo "export GITBRAIN_DB_PORT=5432"
echo "export GITBRAIN_DB_NAME=$DB_NAME"
echo "export GITBRAIN_DB_USER=$DB_USER"
echo "export GITBRAIN_DB_PASSWORD="