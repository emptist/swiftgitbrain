#!/bin/bash
# CoderAI keep-alive using shared counter
# Increments counter every 60 seconds to stay alive

set -e

# Configuration
AI_NAME="coder"
COUNTER_FILE="GitBrain/keepalive_counter.txt"
INCREMENT_INTERVAL=60  # 60 seconds

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} CoderAI Keep-Alive: $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} CoderAI Keep-Alive: $1"
}

# Ensure counter file exists
if [ ! -f "$COUNTER_FILE" ]; then
    echo "0" > "$COUNTER_FILE"
    log "Created counter file with initial value 0"
fi

log "Starting CoderAI keep-alive loop (increment every ${INCREMENT_INTERVAL}s)..."

while true; do
    # Read current counter value
    if [ -f "$COUNTER_FILE" ]; then
        current_value=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
        
        # Increment counter
        new_value=$((current_value + 1))
        
        # Write new value
        echo "$new_value" > "$COUNTER_FILE"
        
        log_success "Counter incremented: $current_value -> $new_value"
    else
        log "Counter file not found, recreating..."
        echo "0" > "$COUNTER_FILE"
    fi
    
    # Wait before next increment
    sleep $INCREMENT_INTERVAL
done
