# Molecule Testing Setup - Summary

## What Was Created

A **hybrid testing approach** for your `iamgini.compliance` collection with both container-based (Podman) and VM-based (Vagrant/libvirt) testing scenarios.

### Directory Structure
```
collections/ansible_collections/iamgini/compliance/tests/
├── Makefile                    # Make targets for easy testing
├── run-tests.sh               # Bash helper script
├── requirements.txt           # Python dependencies for testing
└── molecule/
    ├── README.md             # Comprehensive scenario documentation
    ├── TESTING.md            # Quick reference guide
    ├── default/              # Podman scenario (EXISTING - updated)
    │   ├── molecule.yml      # Updated with comments
    │   └── converge.yml
    └── vm-full-cis/          # VM scenario (NEW)
        ├── molecule.yml      # Vagrant/libvirt config
        ├── prepare.yml       # VM preparation
        ├── converge.yml      # Test execution
        ├── verify.yml        # Validation tests
        └── cleanup.yml       # Cleanup tasks
```

## Two Testing Scenarios

### 1. 🚀 Podman (Fast) - `default` scenario
- **Runtime**: ~3-5 minutes
- **Best for**: Daily development, CI/CD pipelines, quick validation
- **Limitations**: Cannot test kernel params, boot configs, partitions
- **Tests**: Workflow, file permissions, packages, services, SSH, basic firewall

### 2. 🎯 VM (Comprehensive) - `vm-full-cis` scenario
- **Runtime**: ~15-20 minutes (first run downloads boxes)
- **Best for**: Pre-release validation, full CIS compliance testing
- **Platforms**: RHEL 9 and RHEL 8 VMs
- **Tests**: EVERYTHING including kernel, GRUB, partitions, mount options

## How to Use

### Quick Start
```bash
# Navigate to tests directory
cd collections/ansible_collections/iamgini/compliance/tests

# Install dependencies (one time)
pip install -r requirements.txt

# Run fast Podman tests
./run-tests.sh podman
# OR
make test-podman

# Run comprehensive VM tests
./run-tests.sh vm
# OR
make test-vm
```

### Common Workflows

#### During Development (Fast Iteration)
```bash
# Quick test with Podman
molecule test -s default

# Or keep environment running
cd molecule
molecule converge -s default
# Make changes to roles...
molecule converge -s default  # Re-run
```

#### Before Committing/Merging
```bash
# Run both scenarios
./run-tests.sh all
# OR
make test-all
```

#### Debugging
```bash
# Create and keep Podman container
make converge-podman
cd molecule && molecule login -s default

# Create and keep VMs
make converge-vm
cd molecule && molecule login -s vm-full-cis -h rhel9-cis-vm
```

## Prerequisites

### For Podman Testing (Already Works)
```bash
# You already have these:
podman --version
pip install molecule molecule-plugins[podman]
```

### For VM Testing (Need to Install)
```bash
# Install Vagrant and libvirt
sudo dnf install vagrant vagrant-libvirt libvirt qemu-kvm

# Enable libvirt
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER

# Logout and login for group to take effect

# Verify
vagrant --version
virsh list --all

# Pre-download boxes (optional, saves time)
vagrant box add generic/rhel9
vagrant box add generic/rhel8
```

## What Each Scenario Tests

| CIS Control | Podman | VM |
|------------|--------|-----|
| File permissions | ✅ | ✅ |
| Packages | ✅ | ✅ |
| Services (systemd) | ✅ | ✅ |
| SSH hardening | ✅ | ✅ |
| Firewall | ⚠️ | ✅ |
| SELinux | ✅ | ✅ |
| **Kernel params** | ❌ | ✅ |
| **Boot loader (GRUB)** | ❌ | ✅ |
| **Partitions** | ❌ | ✅ |
| **Mount options** | ❌ | ✅ |

Legend: ✅ Full support | ⚠️ Limited | ❌ Not supported

## CI/CD Integration

### Fast Pipeline (PR Validation)
```yaml
# .github/workflows/test.yml
- name: Run Molecule tests
  run: |
    pip install -r tests/requirements.txt
    cd tests && ./run-tests.sh podman
```

### Nightly/Release Pipeline (Full Validation)
```yaml
# Run on schedule or before release
- name: Run comprehensive tests
  run: |
    cd tests && ./run-tests.sh all
```

## Documentation Files

1. **`tests/molecule/README.md`** - Comprehensive guide:
   - Detailed scenario explanations
   - What each scenario can/cannot test
   - Prerequisites and troubleshooting
   - Best practices

2. **`tests/molecule/TESTING.md`** - Quick reference:
   - TL;DR commands
   - When to use each scenario
   - Common workflows
   - CI/CD examples

3. **`tests/Makefile`** - Make targets for convenience

4. **`tests/run-tests.sh`** - Bash script with helpers

## Next Steps

### 1. Install VM Testing Dependencies
```bash
sudo dnf install vagrant vagrant-libvirt libvirt qemu-kvm
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
# Logout and login
```

### 2. Test the Setup
```bash
# Test Podman scenario (should work now)
cd collections/ansible_collections/iamgini/compliance/tests
./run-tests.sh podman

# Test VM scenario (after installing Vagrant)
./run-tests.sh vm
```

### 3. Integrate into Workflow
```bash
# Daily development
make test-podman

# Before releases
make test-all
```

## Troubleshooting

### Podman Issues
```bash
# Clean and retry
podman system prune -a --force
make clean
make test-podman
```

### VM Issues
```bash
# Check libvirt
sudo systemctl status libvirtd

# Check Vagrant
vagrant global-status --prune

# Clean and retry
make clean
make test-vm
```

### "Insufficient memory" for VMs
Edit `tests/molecule/vm-full-cis/molecule.yml`:
```yaml
platforms:
  - name: rhel9-cis-vm
    memory: 1024  # Reduce from 2048
```

## Benefits of This Setup

✅ **Fast feedback** during development (Podman)  
✅ **Comprehensive validation** before releases (VMs)  
✅ **CI/CD ready** (both scenarios)  
✅ **Well documented** (README.md, TESTING.md)  
✅ **Easy to use** (Makefile, run-tests.sh)  
✅ **Handles CIS limitations** (knows what works where)  

## Questions?

- Read: `tests/molecule/README.md` for detailed docs
- Read: `tests/molecule/TESTING.md` for quick reference
- Check: Individual `molecule.yml` files for configuration
- Report issues: https://github.com/iamgini/ansible-collection-compliance/issues
