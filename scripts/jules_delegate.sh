#!/bin/sh
# =============================================================================
# Jules Delegate Script
# =============================================================================
# Description: Creates a Jules session, polls until completion, and pulls the
#              resulting patch for review.
# 
# Usage:       jules_delegate.sh "task description" [owner/repo]
# 
# Example:     jules_delegate.sh "write a Python function for email validation"
#              jules_delegate.sh "add tests" Chieji/my-project
# =============================================================================

set -e

# Colors for output (if terminal supports it)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Configuration (will be set after parsing args)
# =============================================================================

WORK_DIR="/var/minis/workspace/jules_work"
POLL_INTERVAL=10
MAX_WAIT_TIME=1800  # 30 minutes max wait
VERBOSE=false
DESC=""
REPO="Chieji/jules-subagent-skill"

# =============================================================================
# Helper Functions
# =============================================================================

print_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] "task description" [owner/repo]

Delegate a coding task to Google's Jules async coding agent.

Arguments:
  "task description"    The task to delegate to Jules (required)
  owner/repo           GitHub repository in format owner/repo (optional)
                       Default: Chieji/jules-subagent-skill

Options:
  -h, --help           Show this help message and exit
  -v, --verbose        Enable verbose output
  --version            Show version information

Examples:
  $(basename "$0") "write a Python function for prime numbers"
  $(basename "$0") "add unit tests" Chieji/my-project
  $(basename "$0") "refactor utils.py" --verbose

Environment Variables:
  JULES_WORK_DIR      Directory to store patches (default: /var/minis/workspace/jules_work)
  JULES_DEFAULT_REPO  Default repository if not specified

Exit Codes:
  0   Success
  1   Invalid arguments
  2   Jules CLI not found
  3   Failed to create session
  4   Session timed out
  5   Failed to pull patch
EOF
}

print_version() {
    echo "jules_delegate.sh version 1.0.0"
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

log_progress() {
    printf "${BLUE}⏳ %s${NC}\n" "$1"
}

validate_repo_format() {
    case "$REPO" in
        */*) return 0 ;;
        *)
            log_error "Invalid repository format: $REPO"
            log_error "Expected format: owner/repo (e.g., Chieji/my-project)"
            return 1
            ;;
    esac
}

check_jules_cli() {
    if ! command -v jules > /dev/null 2>&1; then
        log_error "Jules CLI not found"
        log_error "Install from: https://jules.google.com"
        return 1
    fi
    return 0
}

extract_session_id() {
    echo "$1" | grep -oE '[0-9]+' | head -n 1
}

# =============================================================================
# Parse Arguments
# =============================================================================

VERBOSE=false

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
            break
            ;;
    esac
done

# Reset positional parameters to handle remaining args
set -- "$@"

# =============================================================================
# Validate Input
# =============================================================================

if [ $# -eq 0 ]; then
    log_error "No task description provided"
    print_help
    exit 1
fi

DESC="$1"
REPO="${2:-${JULES_DEFAULT_REPO:-Chieji/jules-subagent-skill}}"

if [ -z "$DESC" ]; then
    log_error "Task description cannot be empty"
    exit 1
fi

validate_repo_format || exit 1
check_jules_cli || exit 2

# Override work dir from env if set
WORK_DIR="${JULES_WORK_DIR:-$WORK_DIR}"

# Create workspace
mkdir -p "$WORK_DIR"

if [ "$VERBOSE" = true ]; then
    log_info "Workspace: $WORK_DIR"
    log_info "Repository: $REPO"
    log_info "Max wait: ${MAX_WAIT_TIME}s"
fi

# =============================================================================
# Step 1: Create Session
# =============================================================================

log_info "Creating Jules session..."
[ "$VERBOSE" = true ] && log_info "Task: $DESC"
[ "$VERBOSE" = true ] && log_info "Repo: $REPO"

OUTPUT=$(jules new --repo "$REPO" "$DESC" 2>&1) || {
    log_error "Failed to create Jules session"
    log_error "Jules output: $OUTPUT"
    exit 3
}

# Extract session ID
SESSION_ID=$(extract_session_id "$OUTPUT")

if [ -z "$SESSION_ID" ]; then
    log_error "Could not extract session ID from Jules response"
    log_error "Response: $OUTPUT"
    exit 3
fi

log_success "Session created: $SESSION_ID"
echo "$SESSION_ID" > "$WORK_DIR/last_session.txt"

if [ "$VERBOSE" = true ]; then
    echo "$OUTPUT" | head -n 20
fi

# =============================================================================
# Step 2: Wait for Completion
# =============================================================================

log_progress "Waiting for Jules to complete..."

ELAPSED=0
STATUS=""

while [ $ELAPSED -lt $MAX_WAIT_TIME ]; do
    # Check status
    STATUS_OUTPUT=$(jules remote list --session 2>&1) || true
    STATUS=$(echo "$STATUS_OUTPUT" | grep "$SESSION_ID" | awk '{print $3}' | head -n 1)
    
    if [ "$VERBOSE" = true ] && [ $((ELAPSED % 30)) -eq 0 ]; then
        log_info "Status check at ${ELAPSED}s: ${STATUS:-pending}"
    fi
    
    case "$STATUS" in
        finished|completed|done)
            log_success "Jules finished after ${ELAPSED}s"
            break
            ;;
        failed|error)
            log_error "Jules session failed"
            exit 4
            ;;
    esac
    
    sleep $POLL_INTERVAL
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
    
    # Progress indicator every minute
    if [ $((ELAPSED % 60)) -eq 0 ]; then
        log_progress "...still working (${ELAPSED}s elapsed)"
    fi
done

if [ "$STATUS" != "finished" ] && [ "$STATUS" != "completed" ] && [ "$STATUS" != "done" ]; then
    log_error "Timeout: Jules session did not complete within ${MAX_WAIT_TIME}s"
    log_warning "Session may still be running. Check manually with:"
    echo "  jules remote list --session"
    echo "  jules remote tail --session $SESSION_ID"
    exit 4
fi

# =============================================================================
# Step 3: Pull Result
# =============================================================================

log_info "Jules finished! Pulling result..."

PATCH_FILE="$WORK_DIR/jules_${SESSION_ID}.patch"

if ! jules remote pull --session "$SESSION_ID" > "$PATCH_FILE" 2>&1; then
    log_error "Failed to pull patch from Jules"
    log_error "Check session status: jules remote status --session $SESSION_ID"
    exit 5
fi

# Verify patch is not empty
if [ ! -s "$PATCH_FILE" ]; then
    log_warning "Patch file is empty — Jules may have produced no changes"
    rm -f "$PATCH_FILE"
    exit 5
fi

LINE_COUNT=$(wc -l < "$PATCH_FILE" | tr -d ' ')

# =============================================================================
# Step 4: Report
# =============================================================================

printf "\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "  ✅ Jules Session Complete\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "  Task:       %s\n" "$DESC"
printf "  Session ID: %s\n" "$SESSION_ID"
printf "  Patch:      %s\n" "$PATCH_FILE"
printf "  Lines:      %s\n" "$LINE_COUNT"
printf "\n"
printf "  ⚠️  Review the patch before applying:\n"
printf "      cat %s\n" "$PATCH_FILE"
printf "\n"
printf "  To apply (after review):\n"
printf "      git apply %s\n" "$PATCH_FILE"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "\n"

log_success "Delegation complete! Review the patch before applying."

exit 0
