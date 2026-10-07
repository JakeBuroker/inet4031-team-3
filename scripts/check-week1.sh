#!/bin/bash

# Week 1 Validation Check Script
# This script verifies that all Week 1 deliverables are in place and functional.
# Run this from the repository root: ./scripts/check-week1.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASS_COUNT=0
FAIL_COUNT=0

# Function to print pass/fail messages
check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "Week 1 Validation Check"
echo "=========================================="
echo ""

# Check 1: Repository structure
echo "Checking repository structure..."
REQUIRED_FILES=(
    "README.md"
    "team-charter.md"
    "ansible/site.yml"
    "ansible/inventory"
    ".gitignore"
)

REQUIRED_DIRS=(
    "ansible"
    "scripts"
    "week-1"
    "week-2"
    "week-3"
    "week-4"
    "week-5"
    "week-6"
    "week-7"
    "week-8"
    "week-9"
    "docs"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$REPO_ROOT/$file" ]; then
        check_pass "File exists: $file"
    else
        check_fail "File missing: $file"
    fi
done

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$REPO_ROOT/$dir" ]; then
        check_pass "Directory exists: $dir"
    else
        check_fail "Directory missing: $dir"
    fi
done

echo ""
echo "Checking README.md content..."

if grep -q "Team Name:" "$REPO_ROOT/README.md" || grep -q "team name" "$REPO_ROOT/README.md" | grep -v "\[Enter"; then
    check_pass "README.md contains team name field"
else
    check_warn "README.md team name may not be filled in (check manually)"
fi

if grep -q "Google Doc" "$REPO_ROOT/README.md"; then
    check_pass "README.md contains Google Doc link section"
else
    check_fail "README.md missing Google Doc link section"
fi

echo ""
echo "Checking team-charter.md content..."

CHARTER_CHECKS=(
    "Team Name"
    "Team Number"
    "Full Roster"
    "7-Sprint Rotation Schedule"
    "Communication Norms"
    "Operating Agreements"
    "Container Baseline"
)

for check in "${CHARTER_CHECKS[@]}"; do
    if grep -q "$check" "$REPO_ROOT/team-charter.md"; then
        check_pass "team-charter.md contains section: $check"
    else
        check_fail "team-charter.md missing section: $check"
    fi
done

echo ""
echo "Checking Ansible configuration..."

if grep -q "localhost ansible_connection=local" "$REPO_ROOT/ansible/inventory"; then
    check_pass "ansible/inventory configured for localhost"
else
    check_fail "ansible/inventory not properly configured"
fi

if grep -q "Baseline environment setup" "$REPO_ROOT/ansible/site.yml"; then
    check_pass "ansible/site.yml contains baseline play"
else
    check_fail "ansible/site.yml missing baseline play"
fi

if grep -q "dnf:" "$REPO_ROOT/ansible/site.yml"; then
    check_pass "ansible/site.yml contains dnf module usage"
else
    check_fail "ansible/site.yml missing dnf module tasks"
fi

if command -v ansible >/dev/null 2>&1; then
    check_pass "Ansible is installed"
else
    check_fail "Ansible is not installed"
fi

echo ""
echo "Checking documentation files..."

DOC_FILES=(
    "docs/sprint-1-retrospective.md"
    "docs/week-01-environment-log.md"
    "docs/week-01-acceptance-criteria.md"
    "docs/qa-report-1.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$REPO_ROOT/$doc" ]; then
        check_pass "Documentation file exists: $doc"
    else
        check_fail "Documentation file missing: $doc"
    fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. See above for details.${NC}"
    exit 1
fi
