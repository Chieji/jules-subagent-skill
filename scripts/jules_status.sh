#!/bin/sh
# jules_status.sh - Check status of the most recent Jules session
# Part of the jules-subagent skill for Minis

WORK_DIR="/var/minis/workspace/jules_work"

# Determine session ID
if [ -n "$1" ]; then
    SID="$1"
else
    SID=$(cat "$WORK_DIR/last_session.txt" 2>/dev/null || true)
fi

if [ -z "$SID" ]; then
    echo "❌ No session ID found. Either:"
    echo "   - Run jules_status.sh <session_id> with an ID"
    echo "   - Run jules_delegate.sh first to create a session"
    exit 1
fi

echo "📋 Checking session: $SID"
echo ""

# Get status from Jules CLI
STATUS=$(jules remote list --session 2>/dev/null | grep "$SID" | awk '{print $3}')

if [ -z "$STATUS" ]; then
    echo "❌ Session $SID not found"
    echo "   It may still be queued or there may be an auth issue"
    exit 1
fi

echo "Status: $STATUS"

# Show patch if available
PATCH_FILE="$WORK_DIR/jules_${SID}.patch"
if [ -f "$PATCH_FILE" ]; then
    echo "Patch file: $PATCH_FILE"
    echo "Lines: $(wc -l < "$PATCH_FILE")"
else
    echo "Patch file: not yet pulled"
    echo "Run: jules remote pull --session $SID"
fi