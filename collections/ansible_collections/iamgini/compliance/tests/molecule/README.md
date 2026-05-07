# Molecule Testing Scenarios

This directory contains multiple Molecule test scenarios for the `iamgini.compliance` collection. Each scenario serves different testing purposes.

## Available Scenarios

### 1. `default` - Podman Container Testing (Fast)
**Driver**: Podman  
**Platform**: RHEL 9 UBI container (privileged, with systemd)  
**Purpose**: Quick smoke tests for CI/CD pipelines  
**Best For**:
- Testing OpenSCAP scan workflow
- Validating role syntax and logic
- Basic compliance checks (file permissions, packages, services)
- PR validation and pre-commit hooks

**Limitations**:
- ❌ Cannot test kernel parameters or boot loader configs
- ❌ Cannot test partition-level controls (separate /tmp, /var, etc.)
- ❌ Limited hardware and network kernel parameter testing
- ❌ Some filesystem mount options won't work

**Run Time**: ~2-5 minutes

```bash
# Run Podman-based tests
molecule test -s default

# Or just converge without destroying
molecule converge -s default
```

### 2. `vm-full-cis` - Full VM Testing (Comprehensive)
**Driver**: Vagrant with libvirt provider  
**Platforms**: 
- RHEL 9 VM
- RHEL 8 VM

**Purpose**: Complete CIS benchmark compliance testing  
**Best For**:
- Full CIS Level 1 and Level 2 testing
- Testing kernel parameters, GRUB configs, boot settings
- Testing partition and filesystem mount options
- Hardware and network stack testing
- Pre-release validation

**Requirements**:
- Vagrant installed
- libvirt/KVM installed and configured
- At least 4GB RAM free (2GB per VM)

**Run Time**: ~10-20 minutes (depending on downloads)

```bash
# Run full VM-based tests
molecule test -s vm-full-cis

# Test specific OS
molecule test -s vm-full-cis -- --limit rhel9-cis-vm

# Keep VMs running for debugging
molecule converge -s vm-full-cis
molecule login -s vm-full-cis -h rhel9-cis-vm
```

## Testing Strategy Recommendations

### For Development (Local)
```bash
# Quick iteration during development
molecule converge -s default

# Full validation before commit
molecule test -s vm-full-cis
```

### For CI/CD Pipeline
```bash
# GitHub Actions / GitLab CI (container-based)
molecule test -s default

# Nightly builds (if VM runners available)
molecule test -s vm-full-cis
```

### For Pre-Release Testing
```bash
# Run both scenarios
molecule test --all
```

## What Each Scenario Tests

| CIS Control Category | Podman (`default`) | VM (`vm-full-cis`) |
|---------------------|-------------------|-------------------|
| File permissions | ✅ Full | ✅ Full |
| Package management | ✅ Full | ✅ Full |
| Service configuration | ✅ Full | ✅ Full |
| User/group management | ✅ Full | ✅ Full |
| SSH hardening | ✅ Full | ✅ Full |
| Firewall rules | ✅ Limited | ✅ Full |
| SELinux | ✅ Good | ✅ Full |
| Audit rules | ✅ Limited | ✅ Full |
| Kernel parameters | ❌ None | ✅ Full |
| Boot loader (GRUB) | ❌ None | ✅ Full |
| Partition configs | ❌ None | ✅ Full |
| Filesystem mounting | ❌ Limited | ✅ Full |
| Network kernel settings | ❌ Limited | ✅ Full |
| Time synchronization | ⚠️ Partial | ✅ Full |

Legend:
- ✅ Full - Complete testing capability
- ⚠️ Partial - Some features work, some don't
- ❌ None/Limited - Cannot test reliably

## Prerequisites

### For Podman Scenario
```bash
# Install Molecule with Podman driver
pip install molecule molecule-plugins[podman] ansible-core

# Verify Podman
podman --version
```

### For VM Scenario
```bash
# Install Molecule with Vagrant
pip install molecule molecule-plugins[vagrant] ansible-core

# Install Vagrant and libvirt
# Fedora/RHEL:
sudo dnf install vagrant vagrant-libvirt libvirt

# Start libvirt
sudo systemctl enable --now libvirtd

# Verify setup
vagrant --version
virsh list --all
```

## Troubleshooting

### Podman Issues
```bash
# If containers fail to start
podman system prune -a --force
molecule destroy -s default
```

### VM Issues
```bash
# If VMs fail to create
vagrant global-status --prune
molecule destroy -s vm-full-cis

# Check libvirt
sudo systemctl status libvirtd
virsh list --all
```

### Common Errors

**"Could not find a ready container"**
- Solution: Ensure Podman is running: `podman ps`

**"Vagrant box not found"**
- Solution: Pre-download: `vagrant box add generic/rhel9`

**"Insufficient memory"**
- Solution: Reduce VM memory in `molecule.yml` or test one platform at a time

## Adding New Scenarios

To add a new scenario (e.g., for Ubuntu or Debian):

```bash
cd tests/molecule
molecule init scenario ubuntu-cis --driver-name vagrant
# Edit ubuntu-cis/molecule.yml with Ubuntu boxes
```

## Best Practices

1. **Run Podman tests frequently** - They're fast and catch most issues
2. **Run VM tests before merging** - They catch OS-specific and kernel-level issues
3. **Use VM tests for release validation** - Ensures production-grade compliance
4. **Keep scenarios isolated** - Don't mix container and VM testing in one scenario
5. **Document limitations** - Update this README when you find scenario-specific issues

## Contributing

When adding new test scenarios:
- Document the purpose and limitations
- Update this README
- Ensure both Podman and VM scenarios remain functional
- Add scenario-specific variables in `molecule.yml` inventory section
