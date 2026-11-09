#!/bin/bash

# Week 7 Validation Script
# This script runs all acceptance checks for Week 7 deliverables
# Run from the repository root: ./scripts/check-week7.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# kubectl/tofu are typically installed to /usr/local/bin; make sure it's on
# PATH regardless of how this script is invoked (e.g. under sudo, where
# root's PATH may not include it).
export PATH="/usr/local/bin:$PATH"

# k3d writes its kubeconfig under the home directory of whichever user ran
# `k3d cluster create` (your normal user, not root). If this script is run
# with sudo, point kubectl back at that config instead of root's.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
if [ -f "$REAL_HOME/.kube/config" ]; then
    export KUBECONFIG="$REAL_HOME/.kube/config"
fi

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track pass/fail status
PASS_COUNT=0
FAIL_COUNT=0

# Helper function to print results
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

echo "========================================="
echo "Week 7 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: RBAC and NetworkPolicy Manifests Exist
# =========================================
echo "Check 1: RBAC and NetworkPolicy Manifests Exist"
echo "-----------------------------------------------------"

REQUIRED_MANIFESTS=(
    "manifests/flask-serviceaccount.yaml"
    "manifests/flask-role.yaml"
    "manifests/flask-rolebinding.yaml"
    "manifests/default-deny.yaml"
    "manifests/allow-nginx-to-flask.yaml"
    "manifests/allow-flask-to-postgres.yaml"
    "manifests/allow-ingress-to-nginx.yaml"
    "manifests/allow-prometheus-to-flask.yaml"
    "manifests/flask-securitycontext-patch.yaml"
)

for f in "${REQUIRED_MANIFESTS[@]}"; do
    if [ -f "$REPO_ROOT/$f" ]; then
        check_pass "$f exists"
    else
        check_fail "$f not found"
    fi
done

# =========================================
# Check 2: CI Workflow Includes Trivy Scan
# =========================================
echo ""
echo "Check 2: CI Workflow Includes Trivy Scan"
echo "----------------------------------------------"

if grep -q "aquasecurity/trivy-action" "$REPO_ROOT/.github/workflows/ci.yml" 2>/dev/null; then
    check_pass "ci.yml includes a Trivy scan step"
else
    check_fail "ci.yml is missing a Trivy scan step"
fi

# =========================================
# Check 3: Flask Uses Custom ServiceAccount
# =========================================
echo ""
echo "Check 3: Flask Uses Custom ServiceAccount"
echo "------------------------------------------------"

SERVICE_ACCOUNT=$(kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}' 2>/dev/null || echo "")

if [ "$SERVICE_ACCOUNT" = "flask-app" ]; then
    check_pass "Flask pod uses the 'flask-app' ServiceAccount"
else
    check_fail "Flask ServiceAccount is '$SERVICE_ACCOUNT', expected 'flask-app'"
fi

# =========================================
# Check 4: NetworkPolicy Applied
# =========================================
echo ""
echo "Check 4: NetworkPolicy Applied"
echo "------------------------------------"

REQUIRED_POLICIES=(
    "default-deny-ingress"
    "allow-nginx-to-flask"
    "allow-flask-to-postgres"
    "allow-ingress-to-nginx"
    "allow-prometheus-to-flask"
)

for policy in "${REQUIRED_POLICIES[@]}"; do
    if kubectl get networkpolicy "$policy" &>/dev/null; then
        check_pass "NetworkPolicy '$policy' exists"
    else
        check_fail "NetworkPolicy '$policy' not found"
    fi
done

# =========================================
# Check 5: Application Works After NetworkPolicy
# =========================================
echo ""
echo "Check 5: Application Works After NetworkPolicy"
echo "-----------------------------------------------------"

# Kubernetes port is the team's Week 2 HOST_PORT + 10 (e.g. 8083 -> 8093)
if [ -f "$REPO_ROOT/week-2/.env" ]; then
    HOST_PORT=$(grep -E "^HOST_PORT=" "$REPO_ROOT/week-2/.env" | cut -d '=' -f2)
fi
KUBE_PORT=$(( ${HOST_PORT:-8071} + 10 ))

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${KUBE_PORT}/incidents 2>/dev/null || true)
if [ "$HTTP_CODE" = "200" ]; then
    check_pass "Application responds at http://localhost:${KUBE_PORT}/incidents (HTTP $HTTP_CODE)"
else
    check_fail "Application did not respond correctly at http://localhost:${KUBE_PORT}/incidents (HTTP $HTTP_CODE) - check HOST_PORT in week-2/.env matches your assigned port"
fi

# =========================================
# Check 6: SecurityContext Is Set
# =========================================
echo ""
echo "Check 6: SecurityContext Is Set"
echo "-------------------------------------"

ALLOW_PRIV=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null || echo "")
READ_ONLY=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || echo "")
RUN_NON_ROOT=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null || echo "")
DROPPED_CAPS=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.drop[0]}' 2>/dev/null || echo "")

if [ "$ALLOW_PRIV" = "false" ]; then
    check_pass "allowPrivilegeEscalation is false"
else
    check_fail "allowPrivilegeEscalation is '$ALLOW_PRIV', expected 'false'"
fi

if [ "$READ_ONLY" = "true" ]; then
    check_pass "readOnlyRootFilesystem is true"
else
    check_fail "readOnlyRootFilesystem is '$READ_ONLY', expected 'true'"
fi

if [ "$RUN_NON_ROOT" = "true" ]; then
    check_pass "runAsNonRoot is true"
else
    check_fail "runAsNonRoot is '$RUN_NON_ROOT', expected 'true'"
fi

if [ "$DROPPED_CAPS" = "ALL" ]; then
    check_pass "capabilities.drop includes ALL"
else
    check_fail "capabilities.drop does not include ALL (found: '$DROPPED_CAPS')"
fi

# =========================================
# Check 7: OpenTofu Configuration Updated (not applied this week)
# =========================================
echo ""
echo "Check 7: OpenTofu Configuration Updated"
echo "---------------------------------------------------------"

FLASK_TF="$REPO_ROOT/infrastructure/flask.tf"
if [ -f "$FLASK_TF" ]; then
    if grep -Eq 'service_account_name[[:space:]]*=[[:space:]]*"flask-app"' "$FLASK_TF"; then
        check_pass "flask.tf sets service_account_name = \"flask-app\""
    else
        check_fail "flask.tf is missing service_account_name = \"flask-app\""
    fi
    if grep -Eq 'allow_privilege_escalation[[:space:]]*=[[:space:]]*false' "$FLASK_TF"; then
        check_pass "flask.tf has a security_context with allow_privilege_escalation = false"
    else
        check_fail "flask.tf is missing the security_context block"
    fi
else
    check_fail "infrastructure/flask.tf not found"
fi

# =========================================
# Summary
# =========================================
echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Status: ALL CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}Status: SOME CHECKS FAILED - Review errors above${NC}"
    exit 1
fi
