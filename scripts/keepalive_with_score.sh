#!/bin/bash

# Keepalive script that uses SQLite-based scoring system
# This script initializes the database and increments the AI's score as a keepalive mechanism

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DB_PATH="$PROJECT_DIR/GitBrain/Memory/scores.db"
DB_DIR="$(dirname "$DB_PATH")"

AI_NAME="${1:-Creator}"

# Create database directory if it doesn't exist
mkdir -p "$DB_DIR"

# Create table if it doesn't exist
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS ai_scores (id INTEGER PRIMARY KEY AUTOINCREMENT, ai_name TEXT NOT NULL UNIQUE, score INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL);"

# Use sqlite3 command to increment score
sqlite3 "$DB_PATH" "INSERT INTO ai_scores (ai_name, score, updated_at) VALUES ('$AI_NAME', 1, datetime('now')) ON CONFLICT(ai_name) DO UPDATE SET score = score + 1, updated_at = datetime('now');"

# Get current score
SCORE=$(sqlite3 "$DB_PATH" "SELECT score FROM ai_scores WHERE ai_name = '$AI_NAME';")

echo "Keepalive: $AI_NAME score incremented to $SCORE"
