# Makefile for running Molecule tests
# Usage: make test-podman, make test-vm, make test-all

.PHONY: help install test-podman test-vm test-all clean lint

help:
	@echo "Molecule Test Targets:"
	@echo "  make install      - Install test dependencies"
	@echo "  make test-podman  - Run fast Podman tests (default scenario)"
	@echo "  make test-vm      - Run full VM tests (vm-full-cis scenario)"
	@echo "  make test-all     - Run all test scenarios"
	@echo "  make lint         - Run ansible-lint and yamllint"
	@echo "  make clean        - Destroy all test environments"
	@echo ""
	@echo "Development Targets:"
	@echo "  make converge-podman  - Create and provision Podman container (no destroy)"
	@echo "  make converge-vm      - Create and provision VMs (no destroy)"
	@echo "  make verify-podman    - Run verification tests only (Podman)"
	@echo "  make verify-vm        - Run verification tests only (VM)"

install:
	@echo "Installing test dependencies..."
	pip install -r requirements.txt
	ansible-galaxy collection install -r ../requirements.yml

test-podman:
	@echo "Running Podman-based tests (fast)..."
	cd molecule && molecule test -s default

test-vm:
	@echo "Running VM-based tests (comprehensive)..."
	cd molecule && molecule test -s vm-full-cis

test-all: test-podman test-vm
	@echo "All tests completed!"

converge-podman:
	@echo "Creating Podman test environment..."
	cd molecule && molecule converge -s default

converge-vm:
	@echo "Creating VM test environment..."
	cd molecule && molecule converge -s vm-full-cis

verify-podman:
	cd molecule && molecule verify -s default

verify-vm:
	cd molecule && molecule verify -s vm-full-cis

lint:
	@echo "Running linters..."
	ansible-lint ../roles/*/
	yamllint ../roles/

clean:
	@echo "Cleaning up test environments..."
	cd molecule && molecule destroy --all
	@echo "Cleanup complete!"

# Specific OS testing
test-rhel9-only:
	cd molecule && molecule test -s vm-full-cis -- --limit rhel9-cis-vm

test-rhel8-only:
	cd molecule && molecule test -s vm-full-cis -- --limit rhel8-cis-vm

# Debug targets
debug-podman:
	cd molecule && molecule converge -s default
	cd molecule && molecule login -s default

debug-vm-rhel9:
	cd molecule && molecule converge -s vm-full-cis
	cd molecule && molecule login -s vm-full-cis -h rhel9-cis-vm

debug-vm-rhel8:
	cd molecule && molecule converge -s vm-full-cis
	cd molecule && molecule login -s vm-full-cis -h rhel8-cis-vm
