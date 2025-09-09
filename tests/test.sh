#!/bin/sh
# CheetSheetz CLI Test Suite

set -e

# Test configuration
TEST_DIR="$(dirname "$0")"
CLI_PATH="$TEST_DIR/../bin/cheatsheetz"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Colors for test output
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' BLUE='' RESET=''
fi

# Test utilities
test_count=0
pass_count=0
fail_count=0

test_start() {
    test_count=$((test_count + 1))
    printf "${BLUE}Test %d:${RESET} %s... " "$test_count" "$1"
}

test_pass() {
    pass_count=$((pass_count + 1))
    printf "${GREEN}PASS${RESET}\n"
}

test_fail() {
    fail_count=$((fail_count + 1))
    printf "${RED}FAIL${RESET}\n"
    if [ -n "$1" ]; then
        printf "  Error: %s\n" "$1"
    fi
}

# Test functions
test_cli_exists() {
    test_start "CLI executable exists"
    if [ -x "$CLI_PATH" ]; then
        test_pass
    else
        test_fail "CLI not found or not executable"
        return 1
    fi
}

test_help_command() {
    test_start "Help command works"
    if "$CLI_PATH" help >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Help command failed"
        return 1
    fi
}

test_version_command() {
    test_start "Version command works"
    local output
    if output=$("$CLI_PATH" version 2>&1) && echo "$output" | grep -q "version"; then
        test_pass
    else
        test_fail "Version command failed or missing version info"
        return 1
    fi
}

test_categories_command() {
    test_start "Categories command works"
    if "$CLI_PATH" categories >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Categories command failed"
        return 1
    fi
}

test_no_color_option() {
    test_start "No-color option works"
    local output
    if output=$("$CLI_PATH" --no-color help 2>&1); then
        test_pass
    else
        test_fail "No-color option failed"
        return 1
    fi
}

test_invalid_command() {
    test_start "Invalid command handling"
    if ! "$CLI_PATH" invalid-command-xyz >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Should have failed on invalid command"
        return 1
    fi
}

test_config_command() {
    test_start "Config command works"
    if "$CLI_PATH" config >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Config command failed"
        return 1
    fi
}

# POSIX compliance tests
test_posix_compliance() {
    test_start "POSIX shell compatibility"
    
    # Test with dash shell if available
    if command -v dash >/dev/null 2>&1; then
        if dash "$CLI_PATH" version >/dev/null 2>&1; then
            test_pass
        else
            test_fail "Not compatible with dash shell"
            return 1
        fi
    else
        # Test basic POSIX constructs
        if grep -q "bash" "$CLI_PATH" || grep -q "zsh" "$CLI_PATH"; then
            test_fail "Contains non-POSIX shell references"
            return 1
        else
            test_pass
        fi
    fi
}

# Syntax validation
test_shell_syntax() {
    test_start "Shell syntax validation"
    
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck "$CLI_PATH" >/dev/null 2>&1; then
            test_pass
        else
            test_fail "ShellCheck found issues"
            return 1
        fi
    else
        # Basic syntax check
        if sh -n "$CLI_PATH" 2>/dev/null; then
            test_pass
        else
            test_fail "Syntax errors found"
            return 1
        fi
    fi
}

# Run all tests
run_tests() {
    printf "${BLUE}%s${RESET}\n" "Starting CheetSheetz CLI Test Suite"
    printf "%s\n" "======================================="
    echo
    
    # Basic functionality tests
    test_cli_exists || exit 1
    test_help_command
    test_version_command
    test_categories_command
    test_config_command
    test_no_color_option
    test_invalid_command
    
    # Compliance tests
    test_posix_compliance
    test_shell_syntax
    
    echo
    printf "%s\n" "======================================="
    printf "${BLUE}Test Results:${RESET}\n"
    printf "Total tests: %d\n" "$test_count"
    printf "${GREEN}Passed: %d${RESET}\n" "$pass_count"
    
    if [ "$fail_count" -gt 0 ]; then
        printf "${RED}Failed: %d${RESET}\n" "$fail_count"
        exit 1
    else
        printf "${GREEN}All tests passed!${RESET}\n"
        exit 0
    fi
}

# Check if CLI exists before testing
if [ ! -f "$CLI_PATH" ]; then
    error "CLI not found at $CLI_PATH. Run 'make build' first."
fi

# Run tests
run_tests