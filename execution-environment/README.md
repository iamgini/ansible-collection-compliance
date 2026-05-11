# Execution Environment for Compliance Scanning

This directory contains the definition for building an Ansible Execution Environment (EE) that includes OpenSCAP tools and SCAP Security Guide content.

## Features

This EE enables **agentless compliance scanning** where:
- ✅ No OpenSCAP installation needed on target systems
- ✅ SCAP content bundled in the container
- ✅ Remote scanning via `oscap-ssh`
- ✅ Fix generation happens in the EE
- ✅ Works with Ansible Automation Platform 2.x

## Building the Execution Environment

### Prerequisites

- `ansible-builder` installed (`pip install ansible-builder`)
- Podman or Docker

### Build Command

```bash
cd execution-environment/
ansible-builder build -t compliance-scanner-ee:latest
```

### Build with verbose output

```bash
ansible-builder build -t compliance-scanner-ee:latest -v 3
```

## What's Included

### System Packages (bindep.txt)
- `openscap-scanner` - OpenSCAP scanning engine
- `scap-security-guide` - SCAP content (CIS, STIG, PCI-DSS, etc.)
- `openscap-utils` - Additional tools including `oscap-ssh`
- `git` - For remediation playbook storage

### Python Packages (requirements.txt)
- `lxml` - XML processing library

### Ansible Collections (requirements.yml)
- `ansible.posix`
- `community.general`
- `ansible.utils`

## Using the Execution Environment

### Option 1: With ansible-navigator (Development)

```bash
# Run scan playbook
ansible-navigator run playbooks/scan.yml \
  --eei compliance-scanner-ee:latest \
  -m stdout

# Interactive mode
ansible-navigator run playbooks/scan.yml \
  --eei compliance-scanner-ee:latest
```

### Option 2: With Ansible Automation Platform

1. **Push to registry:**
   ```bash
   podman tag compliance-scanner-ee:latest registry.example.com/compliance-scanner-ee:latest
   podman push registry.example.com/compliance-scanner-ee:latest
   ```

2. **Configure in AAP:**
   - Navigate to: **Administration → Execution Environments**
   - Click **Add**
   - Name: `Compliance Scanner EE`
   - Image: `registry.example.com/compliance-scanner-ee:latest`

3. **Use in Job Templates:**
   - Set **Execution Environment** to `Compliance Scanner EE`
   - Run your compliance scanning jobs

## Execution Modes

The compliance playbooks support two execution modes:

### Execution Environment Mode (Default)
```yaml
# group_vars/all.yml
execution_mode: "execution_environment"
```

**How it works:**
1. EE container has oscap-ssh and SCAP content
2. Playbook runs oscap-ssh to scan targets remotely
3. No installation needed on targets
4. Results stored in EE, then pushed to report server

**Requirements:**
- SSH access to targets
- Target systems must be accessible from EE

### Local Mode
```yaml
# group_vars/all.yml
execution_mode: "local"
```

**How it works:**
1. Install OpenSCAP on each target
2. Run oscap locally on target
3. Fetch results back
4. Push to report server

**Use when:**
- Targets cannot be reached via SSH from EE
- Targets have restricted network access

## SCAP Content Location in EE

The EE includes SCAP content at standard paths:
```
/usr/share/xml/scap/ssg/content/
├── ssg-rhel7-ds.xml
├── ssg-rhel8-ds.xml
├── ssg-rhel9-ds.xml
├── ssg-ubuntu2004-ds.xml
├── ssg-ubuntu2204-ds.xml
└── ...
```

These paths are referenced in `group_vars/all.yml` via `ssg_datastream` variable.

## Testing the EE

### Test Build
```bash
# Build
ansible-builder build -t compliance-scanner-ee:test

# Verify OpenSCAP is included
podman run -it --rm compliance-scanner-ee:test /bin/bash
[container]# oscap --version
[container]# ls /usr/share/xml/scap/ssg/content/
```

### Test with Molecule
```bash
# Use the EE in molecule tests
MOLECULE_GLOB_MODE=role molecule test --eei compliance-scanner-ee:latest
```

## Customization

### Add More System Packages

Edit `bindep.txt`:
```
openscap-scanner [platform:rpm]
scap-security-guide [platform:rpm]
openscap-utils [platform:rpm]
git [platform:rpm platform:dpkg]
your-package-here [platform:rpm]
```

### Add Python Dependencies

Edit `requirements.txt`:
```
lxml>=4.9.0
your-python-package>=1.0.0
```

### Add Collections

Edit `requirements.yml`:
```yaml
---
collections:
  - name: ansible.posix
  - name: community.general
  - name: ansible.utils
  - name: your.collection
```

### Change Base Image

Edit `execution-environment.yml`:
```yaml
images:
  base_image:
    name: quay.io/ansible/ansible-runner:latest  # or your preferred base
```

## Troubleshooting

### Build Fails - Package Not Found
- Check package availability in base image repo
- Verify platform tags in `bindep.txt`
- Try with different base image

### oscap-ssh Command Not Found
- Ensure `openscap-utils` is in `bindep.txt`
- Rebuild the EE
- Verify: `podman run --rm ee:latest which oscap-ssh`

### SSH Connection Issues
- Verify SSH keys are mounted/available in AAP
- Check `ansible_user` and `ansible_host` in inventory
- Test SSH manually: `ssh ansible@target-host`

### SCAP Content Not Found
- Verify `scap-security-guide` in `bindep.txt`
- Check path: `podman run --rm ee:latest ls /usr/share/xml/scap/ssg/content/`
- Update `ssg_datastream` variable if path differs

## Best Practices

1. **Version your EE images:**
   ```bash
   ansible-builder build -t compliance-scanner-ee:1.0.0
   podman tag compliance-scanner-ee:1.0.0 compliance-scanner-ee:latest
   ```

2. **Use private registries for production:**
   - Push to your organization's registry
   - Use image signing for security
   - Implement scanning for vulnerabilities

3. **Test before deploying:**
   - Build and test locally first
   - Run full playbooks with ansible-navigator
   - Verify all SCAP content paths

4. **Keep content updated:**
   - Rebuild periodically for latest SCAP content
   - Update base image for security patches
   - Document versions used

## Integration with CI/CD

### GitLab CI Example
```yaml
build-ee:
  stage: build
  image: quay.io/ansible/ansible-builder:latest
  script:
    - cd execution-environment
    - ansible-builder build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    - podman push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  only:
    - tags
```

### GitHub Actions Example
```yaml
name: Build EE
on:
  push:
    tags:
      - 'v*'
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build EE
        run: |
          pip install ansible-builder
          cd execution-environment
          ansible-builder build -t ghcr.io/${{ github.repository }}:${{ github.ref_name }}
```

## Further Reading

- [Ansible Builder Documentation](https://ansible-builder.readthedocs.io/)
- [OpenSCAP Documentation](https://www.open-scap.org/tools/openscap-base/)
- [SCAP Security Guide](https://github.com/ComplianceAsCode/content)
- [AAP Execution Environments Guide](https://docs.ansible.com/automation-controller/latest/html/userguide/execution_environments.html)
