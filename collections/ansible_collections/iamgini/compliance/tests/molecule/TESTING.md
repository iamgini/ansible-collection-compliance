# Quick Testing Guide

## TL;DR

```bash
# Fast test (Podman) - Use during development
molecule test -s default                    # ~3 minutes

# Full test (VM) - Use before releases
molecule test -s vm-full-cis               # ~15 minutes

# Run both
molecule test --all
```

## When to Use Each Scenario

### Use Podman (`default`) when:
- 🚀 You need quick feedback during development
- 🔄 Running in CI/CD (GitHub Actions, GitLab CI)
- ✅ Testing workflow and role logic
- 📝 Validating syntax and basic functionality

### Use VM (`vm-full-cis`) when:
- 🔒 Testing full CIS benchmark compliance
- 🎯 Validating kernel, boot, or partition controls
- 📦 Pre-release validation
- 🧪 Testing OS-specific edge cases

## Common Commands

### Podman Scenario
```bash
# Full test cycle (create, test, destroy)
molecule test -s default

# Create and run without destroying (for debugging)
molecule converge -s default

# Run verify step only
molecule verify -s default

# Cleanup
molecule destroy -s default
```

### VM Scenario
```bash
# Full test cycle
molecule test -s vm-full-cis

# Test only RHEL 9
molecule converge -s vm-full-cis -- --limit rhel9-cis-vm

# Login to VM for debugging
molecule login -s vm-full-cis -h rhel9-cis-vm

# Keep VMs running for manual testing
molecule converge -s vm-full-cis

# Cleanup VMs
molecule destroy -s vm-full-cis
```

## Understanding CIS Control Coverage

### ✅ Both Podman and VM Can Test:
- File and directory permissions
- Package installation/removal
- Service configuration (systemd)
- User and group management
- SSH daemon configuration
- Basic firewall rules
- SELinux settings
- Log configuration

### ⚠️ Only VMs Can Test:
- **Kernel parameters** (sysctl at boot, GRUB settings)
- **Boot loader** (GRUB password, kernel options)
- **Partitioning** (separate /tmp, /var, /home with noexec/nosuid)
- **Filesystem mounts** (nodev, nosuid, noexec options)
- **Hardware controls** (USB, wireless device disabling)
- **Advanced audit** (immutable audit logs)

## Installation Prerequisites

### For Podman Testing
```bash
# Install dependencies
pip install molecule molecule-plugins[podman]

# Verify Podman
podman --version
```

### For VM Testing
```bash
# Install Molecule with Vagrant
pip install molecule molecule-plugins[vagrant]

# Install Vagrant and libvirt (Fedora/RHEL)
sudo dnf install vagrant vagrant-libvirt libvirt qemu-kvm

# Enable libvirt
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER

# Verify
vagrant --version
virsh list --all
```

### For Both
```bash
# Install Ansible and collection dependencies
pip install ansible-core
ansible-galaxy collection install -r collections/requirements.yml
```

## Troubleshooting

### Podman: "Failed to create container"
```bash
# Clean up
podman system prune -a --force
molecule destroy -s default

# Verify privileged containers work
podman run --rm --privileged registry.access.redhat.com/ubi9/ubi-init:latest echo "OK"
```

### VM: "Box could not be found"
```bash
# Pre-download boxes
vagrant box add generic/rhel9
vagrant box add generic/rhel8

# Or use different boxes in molecule.yml:
# For local testing, you can use: centos/stream9, almalinux/9
```

### VM: "Insufficient memory"
Edit `molecule.yml` and reduce memory:
```yaml
platforms:
  - name: rhel9-cis-vm
    memory: 1024  # Reduce from 2048
```

### VM: "Cannot connect to libvirt"
```bash
# Check libvirt
sudo systemctl status libvirtd

# Check your user is in libvirt group
groups | grep libvirt

# If not, add and re-login
sudo usermod -aG libvirt $USER
```

## Performance Tips

### Speed up Podman tests
```bash
# Skip dependency installation if already done
molecule test -s default -- --skip-tags dependency

# Use cached images
podman images | grep ubi9
```

### Speed up VM tests
```bash
# Pre-download Vagrant boxes
vagrant box add generic/rhel9
vagrant box add generic/rhel8

# Test one platform at a time
molecule test -s vm-full-cis -- --limit rhel9-cis-vm

# Reuse existing VMs
molecule converge -s vm-full-cis  # Don't destroy
molecule verify -s vm-full-cis    # Run checks again
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Test Collection

on: [push, pull_request]

jobs:
  podman-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install molecule molecule-plugins[podman]
      - name: Run Molecule tests
        run: molecule test -s default

  vm-test:
    runs-on: ubuntu-latest  # or self-hosted with KVM
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
      - name: Run full VM tests
        run: molecule test -s vm-full-cis
```

## Example Workflow

### Daily Development
```bash
# 1. Make changes to role
vim roles/oscap_scan/tasks/main.yml

# 2. Quick test with Podman
molecule converge -s default

# 3. If it works, run full test
molecule test -s default
```

### Before PR/Merge
```bash
# Run both scenarios
molecule test -s default && \
molecule test -s vm-full-cis

# Or in parallel (if you have resources)
molecule test -s default &
molecule test -s vm-full-cis &
wait
```

### Before Release
```bash
# Clean everything
molecule destroy --all

# Run comprehensive tests
molecule test --all

# Manual validation if needed
molecule converge -s vm-full-cis
molecule login -s vm-full-cis -h rhel9-cis-vm
```

## Getting Help

- Molecule docs: https://molecule.readthedocs.io/
- Report issues: https://github.com/iamgini/ansible-collection-compliance/issues
- See also: `README.md` in this directory for detailed scenario documentation
