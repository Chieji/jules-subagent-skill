#!/bin/sh
# jules_delegate.sh - Delegate a task to Jules and wait for completion
# Part of the jules-subagent skill for Minis

set -e

DESC="$1"
WORK_DIR="/var/minis/workspace/jules_work"
mkdir -p "$WORK_DIR"

# Validate input
if [ -z "$DESC" ]; then
    echo "❌ Error: No task description provided"
    echo "Usage: jules_delegate.sh \"your task here\""
    exit 1
fi

# Step 1: Create session
echo "🚀 Creating Jules session for: $DESC"
OUTPUT=$(jules new "$DESC" 2>&1)

# Extract session ID (format: "Created session 1234567")
SID=$(echo "$OUTPUT" | grep -oE '[0-9]{7,}' | head -n1)
if [ -z "$SID" ]; then
    echo "❌ Failed to create session or extract session ID"
    echo "Output was: $OUTPUT"
    exit 1
fi

# Save session ID for later retrieval
echo "$SID" > "$WORK_DIR/last_session.txt"
echo "📋 Session created: $SID"

# Step 2: Wait for completion
echo "⏳ Waiting for Jules to complete..."
while true; do
    SESSION_LINE=$(jules remote list --session 2>/dev/null | grep "$SID" || true)

    if [ -n "$SESSION_LINE" ]; then
        STATUS=$(echo "$SESSION_LINE" | awk '{print $3}')

        if [ "$STATUS" = "finished" ] || [ "$STATUS" = "completed" ] || [ "$STATUS" = "done" ] || [ "$STATUS" = "success" ]; then
            break
        fi

        sleep 10
        echo "   ...still working (session: $SID)"
    else
        # Session not in list yet, may still be queued
        sleep 10
        echo "   ...waiting to start (session: $SID)"
    fi
done

# Step 3: Pull the result
PATCH_FILE="$WORK_DIR/jules_${SID}.patch"
echo "📥 Jules finished! Pulling result..."

jules remote pull --session "$SID" > "$PATCH_FILE" 2>&1 || {
    echo "⚠️ Warning: Pull returned non-zero, checking output..."
    cat "$PATCH_FILE" 2>/dev/null || true
}

# Step 4: Report
LINE_COUNT=$(wc -l < "$PATCH_FILE" 2>/dev/null || echo "0")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Jules Session Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Task:       $DESC"
echo "  Session ID: $SID"
echo "  Patch:      $PATCH_FILE"
echo "  Lines:      $LINE_COUNT"
echo ""
echo "  ⚠️  Review the patch before applying:"
echo "      cat $PATCH_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
