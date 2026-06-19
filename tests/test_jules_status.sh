#!/bin/sh
# =============================================================================
# Test Suite for Jules Status Script
# =============================================================================
# Run with: ./tests/test_jules_status.sh
# =============================================================================

set -e

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/scripts/jules_status.sh"
FAILED=0
PASSED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_test() {
    printf "[TEST] %s... " "$1"
}

pass() {
    printf "${GREEN}✓ PASS${NC}\n"
    PASSED=$((PASSED + 1))
}

fail() {
    printf "${RED}✗ FAIL${NC} - %s\n" "$1"
    FAILED=$((FAILED + 1))
}

# =============================================================================
# Tests
# =============================================================================

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "  🧪 Testing Jules Status Script\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

# Test 1: Script exists and is executable
log_test "Script exists and is executable"
if [ -x "$SCRIPT" ]; then
    pass
else
    fail "Script not found or not executable at $SCRIPT"
fi

# Test 2: Help flag works
log_test "Help flag (-h) works"
if "$SCRIPT" -h > /dev/null 2>&1; then
    pass
else
    fail "Help flag failed"
fi

# Test 3: Help flag (--help) works
log_test "Help flag (--help) works"
if "$SCRIPT" --help > /dev/null 2>&1; then
    pass
else
    fail "--help flag failed"
fi

# Test 4: Version flag works
log_test "Version flag (--version) works"
if "$SCRIPT" --version > /dev/null 2>&1; then
    pass
else
    fail "--version flag failed"
fi

# Test 5: Verbose flag accepted
log_test "Verbose flag (-v) accepted"
OUTPUT=$("$SCRIPT" -v 2>&1 || true)
if echo "$OUTPUT" | grep -q "Jules CLI not found" || echo "$OUTPUT" | grep -q "No session ID"; then
    pass
else
    fail "Verbose flag should be parsed correctly"
fi

# Test 6: Unknown option rejected
log_test "Unknown option rejected"
if ! "$SCRIPT" --invalid-option > /dev/null 2>&1; then
    pass
else
    fail "Should reject unknown options"
fi

# Test 7: Script has proper shebang
log_test "Script has proper shebang"
if head -n1 "$SCRIPT" | grep -q "^#!/bin/"; then
    pass
else
    fail "Missing or incorrect shebang"
fi

# Test 8: Script has set -e (exit on error)
log_test "Script has 'set -e' for error handling"
if grep -q "^set -e" "$SCRIPT"; then
    pass
else
    fail "Missing 'set -e' for strict error handling"
fi

# Test 9: Session ID validation (numeric)
log_test "Session ID format validation"
# Create a temp work directory with invalid session ID
TEMP_WORK=$(mktemp -d)
echo "invalid_id" > "$TEMP_WORK/last_session.txt"
OUTPUT=$(WORK_DIR="$TEMP_WORK" "$SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "doesn't look like" || echo "$OUTPUT" | grep -q "not found"; then
    pass
else
    fail "Should warn about non-numeric session ID"
fi
rm -rf "$TEMP_WORK"

# Test 10: Empty last_session.txt handling
log_test "Empty last_session.txt handled gracefully"
TEMP_WORK=$(mktemp -d)
touch "$TEMP_WORK/last_session.txt"
OUTPUT=$(WORK_DIR="$TEMP_WORK" "$SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "empty" || echo "$OUTPUT" | grep -q "No session ID"; then
    pass
else
    fail "Should handle empty session file"
fi
rm -rf "$TEMP_WORK"

# =============================================================================
# Summary
# =============================================================================

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "  📊 Test Summary\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "  Passed: ${GREEN}%d${NC}\n" "$PASSED"
printf "  Failed: ${RED}%d${NC}\n" "$FAILED"
printf "  Total:  %d\n" "$((PASSED + FAILED))"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

if [ $FAILED -eq 0 ]; then
    printf "${GREEN}✓ All tests passed!${NC}\n\n"
    exit 0
else
    printf "${RED}✗ Some tests failed.${NC}\n\n"
    exit 1
fi
