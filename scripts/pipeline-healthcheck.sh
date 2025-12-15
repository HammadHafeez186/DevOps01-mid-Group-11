#!/bin/bash
# CI/CD Pipeline Health Check Script
# Validates pipeline configuration and dependencies

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "CI/CD Pipeline Health Check"
echo "================================================"
echo ""

# Check GitHub Actions workflow syntax
check_workflow_syntax() {
    echo -n "Checking workflow syntax... "
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        # Basic YAML validation
        if python -c "import yaml; yaml.safe_load(open('.github/workflows/ci-cd.yml'))" 2>/dev/null; then
            echo -e "${GREEN}✓ Valid${NC}"
            return 0
        else
            echo -e "${RED}✗ Invalid YAML${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Workflow file not found${NC}"
        return 1
    fi
}

# Check required secrets
check_secrets() {
    echo -n "Checking required secrets configuration... "
    local required_secrets=(
        "DOCKERHUB_USERNAME"
        "DOCKERHUB_TOKEN"
        "KUBECONFIG"
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
    )
    
    echo -e "${YELLOW}⚠ Manual verification required${NC}"
    echo "  Required secrets:"
    for secret in "${required_secrets[@]}"; do
        echo "    - $secret"
    done
}

# Check Docker configuration
check_docker() {
    echo -n "Checking Docker availability... "
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Available${NC}"
        docker --version
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Check Node.js version
check_nodejs() {
    echo -n "Checking Node.js version... "
    if command -v node &> /dev/null; then
        local version=$(node --version)
        echo -e "${GREEN}✓ $version${NC}"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Check npm dependencies
check_dependencies() {
    echo -n "Checking npm dependencies... "
    if [ -f "package.json" ]; then
        if [ -d "node_modules" ]; then
            echo -e "${GREEN}✓ Installed${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Not installed${NC}"
            echo "  Run: npm install"
            return 1
        fi
    else
        echo -e "${RED}✗ package.json not found${NC}"
        return 1
    fi
}

# Check test configuration
check_tests() {
    echo -n "Checking test configuration... "
    if grep -q '"test"' package.json; then
        echo -e "${GREEN}✓ Configured${NC}"
        return 0
    else
        echo -e "${RED}✗ No test script found${NC}"
        return 1
    fi
}

# Check Kubernetes manifests
check_k8s_manifests() {
    echo -n "Checking Kubernetes manifests... "
    if [ -d "k8s" ]; then
        local manifest_count=$(find k8s -name "*.yaml" -type f | wc -l)
        echo -e "${GREEN}✓ Found $manifest_count manifests${NC}"
        return 0
    else
        echo -e "${RED}✗ k8s directory not found${NC}"
        return 1
    fi
}

# Check Dockerfile
check_dockerfile() {
    echo -n "Checking Dockerfile... "
    if [ -f "Dockerfile" ]; then
        echo -e "${GREEN}✓ Found${NC}"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Run all checks
main() {
    local failed=0
    
    echo "Running health checks..."
    echo ""
    
    check_workflow_syntax || ((failed++))
    check_secrets
    check_docker || ((failed++))
    check_nodejs || ((failed++))
    check_dependencies || ((failed++))
    check_tests || ((failed++))
    check_k8s_manifests || ((failed++))
    check_dockerfile || ((failed++))
    
    echo ""
    echo "================================================"
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}All checks passed!${NC}"
        exit 0
    else
        echo -e "${RED}$failed check(s) failed${NC}"
        exit 1
    fi
}

main "$@"
