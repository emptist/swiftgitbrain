#!/bin/bash
# Monitor automated keep-alive and message processing loop
# This script runs forever, checking for messages every 120 seconds
# and sending heartbeats to keep the AI alive

set -e

# Configuration
AI_NAME="monitor"
AI_ROLE="monitor"
CHECK_INTERVAL=90
HEARTBEAT_INTERVAL=90
LAST_HEARTBEAT=0

# Increment keepalive counter
increment_counter() {
    local current_value=$(cat "GitBrain/keepalive_counter.txt" 2>/dev/null || echo "0")
    local new_value=$((current_value + 1))
    echo "$new_value" > "GitBrain/keepalive_counter.txt"
    log "Keepalive counter incremented: $current_value -> $new_value"
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Send heartbeat to Creator
send_heartbeat() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local heartbeat_file="/tmp/monitor_heartbeat_$$.json"
    
    cat > "$heartbeat_file" << EOF
{
  "type": "heartbeat",
  "ai_name": "$AI_NAME",
  "role": "$AI_ROLE",
  "status": "active",
  "message": "Monitor is active and monitoring for submissions",
  "timestamp": "$timestamp"
}
EOF

    log "Sending heartbeat to Creator..."
    if ./.build/debug/gitbrain send creator "$heartbeat_file" > /dev/null 2>&1; then
        log_success "Heartbeat sent successfully"
        LAST_HEARTBEAT=$(date +%s)
    else
        log_error "Failed to send heartbeat"
    fi

    rm -f "$heartbeat_file"
}

# Check for messages from Creator
check_messages() {
    log "Checking for messages from Creator..."
    
    local output
    output=$(./.build/debug/gitbrain check "$AI_NAME" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        log_error "Failed to check messages: $output"
        return 1
    fi

    # Count messages
    local message_count
    message_count=$(echo "$output" | grep -c "^\[creator -> monitor\]" 2>/dev/null || echo "0")
    
    # Ensure message_count is a valid number
    message_count=$(echo "$message_count" | tr -d '[:space:]')
    if [ -z "$message_count" ] || ! [[ "$message_count" =~ ^[0-9]+$ ]]; then
        message_count=0
    fi
    
    if [ "$message_count" -gt 0 ]; then
        log_success "Found $message_count message(s) from Creator"
        echo "$output"
        return 0
    else
        log "No new messages from Creator"
        return 1
    fi
}

# Process a message from Creator
process_message() {
    local message_file="$1"
    log "Processing message: $message_file"
    
    # Read message type
    local message_type
    message_type=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$message_file" | cut -d'"' -f4)
    
    case "$message_type" in
        "code")
            log_success "Received code submission for review"
            log "Submission file: $message_file"
            log "Please review the code and provide feedback"
            ;;
        "status")
            log "Received status update from Creator"
            local status
            status=$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$message_file" | cut -d'"' -f4)
            log "Status: $status"
            ;;
        "heartbeat")
            log "Received heartbeat from Creator"
            ;;
        "request")
            log_success "Received request from Creator"
            log "Request file: $message_file"
            ;;
        "question")
            log "Received question from Creator"
            log "Question file: $message_file"
            log "Please provide an answer"
            ;;
        *)
            log_warning "Unknown message type: $message_type"
            ;;
    esac
}

# Main loop
log "Starting Monitor automated keep-alive loop..."
log "Check interval: ${CHECK_INTERVAL}s, Heartbeat interval: ${HEARTBEAT_INTERVAL}s"
log "Press Ctrl+C to stop"

while true; do
    current_time=$(date +%s)
    # Increment keepalive counter
    increment_counter
    
    # Check for messages
    if check_messages; then
        # Get list of message files
        local message_files
        message_files=$(ls -t GitBrain/Overseer/*.json 2>/dev/null || true)
        
        if [ -n "$message_files" ]; then
            echo "$message_files" | while read -r msg_file; do
                process_message "$msg_file"
            done
        fi
    fi
    
    # Send heartbeat if needed
    time_since_heartbeat=$((current_time - LAST_HEARTBEAT))
    if [ $time_since_heartbeat -ge $HEARTBEAT_INTERVAL ]; then
        send_heartbeat
    fi
    
    # Wait before next check
    log "Waiting ${CHECK_INTERVAL}s before next check..."
    sleep $CHECK_INTERVAL
done
