#!/bin/sh
# =============================================================================
# Test Runner for Jules Sub-Agent Skill
# =============================================================================
# Run all tests with: ./tests/run_tests.sh
# Run specific test:  ./tests/run_tests.sh delegate
#                      ./tests/run_tests.sh status
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    printf "\n"
    printf "╔════════════════════════════════════════════════════════════════╗\n"
    printf "║        🧪 Jules Sub-Agent Skill - Test Suite                  ║\n"
    printf "╚════════════════════════════════════════════════════════════════╝\n"
    printf "\n"
}

print_footer() {
    printf "\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "  🏁 Test Run Complete\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# =============================================================================
# Run Tests
# =============================================================================

print_header

# Make scripts executable
chmod +x "$SCRIPT_DIR"/test_*.sh 2>/dev/null || true

SPECIFIC_TEST="$1"

if [ -n "$SPECIFIC_TEST" ]; then
    case "$SPECIFIC_TEST" in
        delegate|jules_delegate)
            printf "${BLUE}▶ Running delegate tests...${NC}\n"
            "$SCRIPT_DIR/test_jules_delegate.sh"
            ;;
        status|jules_status)
            printf "${BLUE}▶ Running status tests...${NC}\n"
            "$SCRIPT_DIR/test_jules_status.sh"
            ;;
        *)
            printf "${RED}Unknown test: $SPECIFIC_TEST${NC}\n"
            printf "Available tests: delegate, status\n"
            exit 1
            ;;
    esac
else
    # Run all tests
    printf "${BLUE}▶ Running all tests...${NC}\n\n"
    
    FAILED=0
    
    printf "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    printf "${YELLOW}  Test Suite 1: jules_delegate.sh${NC}\n"
    printf "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    if "$SCRIPT_DIR/test_jules_delegate.sh"; then
        :
    else
        FAILED=$((FAILED + 1))
    fi
    
    printf "\n"
    printf "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    printf "${YELLOW}  Test Suite 2: jules_status.sh${NC}\n"
    printf "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    if "$SCRIPT_DIR/test_jules_status.sh"; then
        :
    else
        FAILED=$((FAILED + 1))
    fi
    
    print_footer
    
    if [ $FAILED -eq 0 ]; then
        printf "\n${GREEN}✅ All test suites passed!${NC}\n\n"
        exit 0
    else
        printf "\n${RED}❌ $FAILED test suite(s) failed.${NC}\n\n"
        exit 1
    fi
fi

print_footer
