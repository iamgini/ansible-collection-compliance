#!/bin/bash
# Helper script to run Molecule tests
# Usage: ./run-tests.sh [podman|vm|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOLECULE_DIR="${SCRIPT_DIR}/molecule"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  podman          Run Podman container tests (fast, ~3 min)"
    echo "  vm              Run VM tests (comprehensive, ~15 min)"
    echo "  all             Run all test scenarios"
    echo "  converge-podman Create Podman environment without destroying"
    echo "  converge-vm     Create VM environment without destroying"
    echo "  clean           Destroy all test environments"
    echo "  lint            Run linters only"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 podman       # Quick test during development"
    echo "  $0 vm           # Full CIS compliance test"
    echo "  $0 all          # Run everything (before release)"
}

check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"

    if ! command -v molecule &> /dev/null; then
        echo -e "${RED}Error: molecule not found${NC}"
        echo "Install with: pip install -r ${SCRIPT_DIR}/requirements.txt"
        exit 1
    fi

    if [ "$1" == "vm" ] || [ "$1" == "all" ]; then
        if ! command -v vagrant &> /dev/null; then
            echo -e "${RED}Error: vagrant not found (required for VM tests)${NC}"
            echo "Install vagrant and libvirt for VM testing"
            exit 1
        fi
    fi

    if [ "$1" == "podman" ] || [ "$1" == "all" ]; then
        if ! command -v podman &> /dev/null; then
            echo -e "${RED}Error: podman not found (required for container tests)${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}Dependencies OK${NC}"
}

run_podman_tests() {
    echo -e "${GREEN}Running Podman tests (default scenario)...${NC}"
    echo -e "${YELLOW}This tests: workflow, basic controls, file permissions, packages, services${NC}"
    echo -e "${YELLOW}Cannot test: kernel params, boot configs, partitions${NC}"
    echo ""

    cd "${MOLECULE_DIR}"
    molecule test -s default

    echo -e "${GREEN}✓ Podman tests passed${NC}"
}

run_vm_tests() {
    echo -e "${GREEN}Running VM tests (vm-full-cis scenario)...${NC}"
    echo -e "${YELLOW}This tests: Full CIS benchmark including kernel, boot, partitions${NC}"
    echo -e "${YELLOW}Note: First run will download Vagrant boxes (~500MB each)${NC}"
    echo ""

    cd "${MOLECULE_DIR}"
    molecule test -s vm-full-cis

    echo -e "${GREEN}✓ VM tests passed${NC}"
}

converge_podman() {
    echo -e "${GREEN}Creating Podman test environment (without destroying)...${NC}"
    cd "${MOLECULE_DIR}"
    molecule converge -s default
    echo -e "${GREEN}✓ Podman environment ready${NC}"
    echo -e "${YELLOW}To login: cd ${MOLECULE_DIR} && molecule login -s default${NC}"
}

converge_vm() {
    echo -e "${GREEN}Creating VM test environment (without destroying)...${NC}"
    cd "${MOLECULE_DIR}"
    molecule converge -s vm-full-cis
    echo -e "${GREEN}✓ VM environment ready${NC}"
    echo -e "${YELLOW}To login to RHEL9: cd ${MOLECULE_DIR} && molecule login -s vm-full-cis -h rhel9-cis-vm${NC}"
}

clean_all() {
    echo -e "${YELLOW}Destroying all test environments...${NC}"
    cd "${MOLECULE_DIR}"
    molecule destroy --all
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

run_lint() {
    echo -e "${GREEN}Running linters...${NC}"

    if command -v ansible-lint &> /dev/null; then
        ansible-lint "${SCRIPT_DIR}/../roles/"
    else
        echo -e "${YELLOW}Warning: ansible-lint not found, skipping${NC}"
    fi

    if command -v yamllint &> /dev/null; then
        yamllint "${SCRIPT_DIR}/../roles/"
    else
        echo -e "${YELLOW}Warning: yamllint not found, skipping${NC}"
    fi

    echo -e "${GREEN}✓ Linting complete${NC}"
}

# Main logic
case "$1" in
    podman)
        check_dependencies "podman"
        run_podman_tests
        ;;
    vm)
        check_dependencies "vm"
        run_vm_tests
        ;;
    all)
        check_dependencies "all"
        run_podman_tests
        echo ""
        run_vm_tests
        echo ""
        echo -e "${GREEN}✓✓✓ All tests passed! ✓✓✓${NC}"
        ;;
    converge-podman)
        check_dependencies "podman"
        converge_podman
        ;;
    converge-vm)
        check_dependencies "vm"
        converge_vm
        ;;
    clean)
        clean_all
        ;;
    lint)
        run_lint
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}Error: Invalid option '$1'${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
