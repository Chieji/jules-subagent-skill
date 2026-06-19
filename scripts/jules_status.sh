#!/bin/sh
# =============================================================================
# Jules Status Checker
# =============================================================================
# Description: Check the status of Jules sessions — last session or specific ID.
#
# Usage:       jules_status.sh [session_id]
#
# Example:     jules_status.sh              # Check last session
#              jules_status.sh 1234567890    # Check specific session
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
WORK_DIR="/var/minis/workspace/jules_work"
LAST_SESSION_FILE="$WORK_DIR/last_session.txt"

# =============================================================================
# Helper Functions
# =============================================================================

print_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [session_id]

Check the status of a Jules session.

Arguments:
  session_id           Specific session ID to check (optional)
                       If omitted, checks the last session from $LAST_SESSION_FILE

Options:
  -h, --help           Show this help message and exit
  -v, --verbose        Show full Jules output
  --version            Show version information

Examples:
  $(basename "$0")              # Check last session
  $(basename "$0") 1234567890   # Check specific session
  $(basename "$0") -v           # Verbose output for last session

Exit Codes:
  0   Session found and status retrieved
  1   No session ID provided or found
  2   Jules CLI not found
  3   Failed to retrieve status
EOF
}

print_version() {
    echo "jules_status.sh version 1.0.0"
    echo "Part of jules-subagent-skill for Minis"
    echo "https://github.com/Chieji/jules-subagent-skill"
}

log_info() {
    printf "${BLUE}ℹ️  %s${NC}\n" "$1"
}

log_success() {
    printf "${GREEN}✅ %s${NC}\n" "$1"
}

log_warning() {
    printf "${YELLOW}⚠️  %s${NC}\n" "$1"
}

log_error() {
    printf "${RED}❌ %s${NC}\n" "$1"
}

# =============================================================================
# Parse Arguments
# =============================================================================

VERBOSE=false
SESSION_ID=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --version)
            print_version
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            print_help
            exit 1
            ;;
        *)
            SESSION_ID="$1"
            shift
            ;;
    esac
done

# =============================================================================
# Validate Environment
# =============================================================================

if ! command -v jules > /dev/null 2>&1; then
    log_error "Jules CLI not found"
    log_error "Install from: https://jules.google.com"
    exit 2
fi

# =============================================================================
# Determine Session ID
# =============================================================================

if [ -z "$SESSION_ID" ]; then
    # Try to read from file
    if [ -f "$LAST_SESSION_FILE" ]; then
        SESSION_ID=$(cat "$LAST_SESSION_FILE" | tr -d '[:space:]')
        if [ -z "$SESSION_ID" ]; then
            log_error "Last session file is empty: $LAST_SESSION_FILE"
            log_info "Provide a session ID as argument or create a new session."
            exit 1
        fi
        log_info "Using last session ID: $SESSION_ID"
    else
        log_error "No session ID provided and no last session found"
        log_info "Usage: $(basename "$0") [session_id]"
        log_info "Or create a new session with: jules_delegate.sh"
        exit 1
    fi
fi

# Validate session ID format (numeric)
if ! echo "$SESSION_ID" | grep -qE '^[0-9]+$'; then
    log_warning "Session ID doesn't look like a standard Jules ID: $SESSION_ID"
    log_info "Jules session IDs are typically long numbers (e.g., 2638064033004501342)"
fi

# =============================================================================
# Check Status
# =============================================================================

log_info "Checking status for session: $SESSION_ID"

if [ "$VERBOSE" = true ]; then
    jules remote status --session "$SESSION_ID" 2>&1 || {
        log_error "Failed to retrieve status"
        exit 3
    }
else
    STATUS_OUTPUT=$(jules remote list --session 2>&1) || {
        log_error "Failed to retrieve session list"
        exit 3
    }
    
    SESSION_LINE=$(echo "$STATUS_OUTPUT" | grep "$SESSION_ID") || true
    
    if [ -z "$SESSION_LINE" ]; then
        log_warning "Session not found in recent sessions list"
        log_info "Try with -v flag for full status, or check if the ID is correct."
        exit 3
    fi
    
    # Parse and display
    printf "\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "  📊 Jules Session Status\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n"
    
    # Show the matching line formatted
    echo "$SESSION_LINE" | while read -r line; do
        ID=$(echo "$line" | awk '{print $1}')
        DESC=$(echo "$line" | cut -f2 | sed 's/^[[:space:]]*//' | head -c 40)
        REPO=$(echo "$line" | awk '{print $3}')
        TIME=$(echo "$line" | awk '{print $4, $5}')
        STATUS=$(echo "$line" | awk '{print $6}')
        
        printf "  Session ID:  %s\n" "$ID"
        printf "  Task:        %s...\n" "$DESC"
        printf "  Repository:  %s\n" "$REPO"
        printf "  Created:     %s\n" "$TIME"
        
        case "$STATUS" in
            finished|completed|done)
                printf "  Status:      ${GREEN}%s${NC}\n" "$STATUS"
                ;;
            failed|error)
                printf "  Status:      ${RED}%s${NC}\n" "$STATUS"
                ;;
            running|working)
                printf "  Status:      ${YELLOW}%s${NC}\n" "$STATUS"
                ;;
            *)
                printf "  Status:      ${BLUE}%s${NC}\n" "$STATUS"
                ;;
        esac
    done
    
    printf "\n"
    printf "  Commands:\n"
    printf "    View live log:   jules remote tail --session %s\n" "$SESSION_ID"
    printf "    Pull result:     jules remote pull --session %s\n" "$SESSION_ID"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n"
fi

exit 0
