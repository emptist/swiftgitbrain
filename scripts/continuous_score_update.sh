#!/bin/bash

# Continuous score update loop for Creator
# This script will continuously update the score until it reaches 20000

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DB_PATH="$PROJECT_DIR/GitBrain/Memory/scores.db"
DB_DIR="$(dirname "$DB_PATH")"

AI_NAME="Creator"
TARGET_SCORE=20000
INCREMENT_INTERVAL=60  # 60 seconds

# Create database directory if it doesn't exist
mkdir -p "$DB_DIR"

# Create table if it doesn't exist
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS ai_scores (id INTEGER PRIMARY KEY AUTOINCREMENT, ai_name TEXT NOT NULL UNIQUE, score INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL);"

echo "Starting continuous score update loop for $AI_NAME"
echo "Target score: $TARGET_SCORE"
echo "Interval: $INCREMENT_INTERVAL seconds"
echo ""

while true; do
    # Get current score
    CURRENT_SCORE=$(sqlite3 "$DB_PATH" "SELECT score FROM ai_scores WHERE ai_name = '$AI_NAME';")
    
    # Check if target reached
    if [ "$CURRENT_SCORE" -ge "$TARGET_SCORE" ]; then
        echo "Target score of $TARGET_SCORE reached! Current score: $CURRENT_SCORE"
        echo "Loop completed successfully."
        break
    fi
    
    # Increment score
    sqlite3 "$DB_PATH" "INSERT INTO ai_scores (ai_name, score, updated_at) VALUES ('$AI_NAME', 1, datetime('now')) ON CONFLICT(ai_name) DO UPDATE SET score = score + 1, updated_at = datetime('now');"
    
    # Get new score
    NEW_SCORE=$(sqlite3 "$DB_PATH" "SELECT score FROM ai_scores WHERE ai_name = '$AI_NAME';")
    
    # Calculate progress
    PROGRESS=$((NEW_SCORE * 100 / TARGET_SCORE))
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Score: $NEW_SCORE / $TARGET_SCORE ($PROGRESS%)"
    
    # Wait for next increment
    sleep $INCREMENT_INTERVAL
done

echo "Continuous score update loop finished."
