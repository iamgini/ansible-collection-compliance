# Quick Start Guide

Get started with compliance scanning in 5 minutes!

## Prerequisites

- Ansible 2.15 or later
- Target systems running RHEL 7/8/9 (or compatible)
- `scap-security-guide` package installed on target systems
- SSH access to target systems

## Step 1: Configure Inventory

Copy the example inventory and customize it:

```bash
cp hosts.ini.example hosts.ini
```

Edit `hosts.ini` with your server details:

```ini
[rhel9_cis_l2]
my-server ansible_host=192.168.1.100 ansible_user=ansible

[report_server]
report-server ansible_host=192.168.1.10 ansible_user=ansible
```

## Step 2: (Optional) Customize Variables

The playbooks come with sensible defaults in `group_vars/all.yml`:

- `customer_id`: `demo-org`
- `cis_profile`: CIS Level 2 Server
- `ssg_datastream`: RHEL 9 content

To override, create custom group_vars or host_vars files:

```bash
# For group-level customization
vim group_vars/rhel9_cis_l2.yml

# For host-level customization
mkdir -p host_vars
vim host_vars/my-server.yml
```

Example override:
```yaml
---
customer_id: "production-environment"
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level1_server"
```

## Step 3: Set Up Report Server

```bash
ansible-playbook playbooks/setup_report_server.yml
```

This installs nginx and configures the report directory.

## Step 4: Run Compliance Scan

Scan all hosts:
```bash
ansible-playbook playbooks/scan.yml
```

Scan specific group:
```bash
ansible-playbook playbooks/scan.yml -e "target_hosts=rhel9_cis_l2"
```

Scan single host:
```bash
ansible-playbook playbooks/scan.yml -l my-server
```

## Step 5: View Reports

Reports are stored on the report server at:
- Base directory: `/var/www/compliance-reports/`
- Organized by: `<customer_id>/<hostname>/<date>/`

Access via web browser:
```
http://<report-server-ip>/reports/
```

## Testing with Localhost

To test without remote servers:

1. Edit `hosts.ini`:
```ini
[localhost_test]
localhost ansible_connection=local

[report_server]
localhost ansible_connection=local
```

2. Install SCAP Security Guide:
```bash
sudo dnf install scap-security-guide openscap-scanner
```

3. Run scan:
```bash
ansible-playbook playbooks/scan.yml -e "target_hosts=localhost_test"
```

## Common Variables

### Required Variables (with defaults)
- `customer_id`: Organization identifier *(default: demo-org)*
- `cis_profile`: Profile to scan *(default: cis_level2_server)*
- `ssg_datastream`: SCAP content file *(default: RHEL 9)*
- `report_server_host`: Report server hostname *(default: report_server)*

### Optional Variables
- `oscap_scan_timeout`: Scan timeout in seconds *(default: 600)*
- `generate_fix_mode`: Where to generate fixes *(default: report_server)*
- `compliance_skip_rules`: List of rules to skip
- `compliance_exception_reasons`: Justification for exceptions

## Troubleshooting

### "No hosts matched"
- Check your inventory file syntax
- Verify group names match in playbook and inventory
- Use `ansible-inventory --list` to validate

### "Required variables missing"
- Ensure `group_vars/all.yml` exists
- Check for typos in custom variable files
- Verify variables are defined at group or host level

### "SCAP datastream not found"
- Install: `sudo dnf install scap-security-guide`
- Verify path: `ls -l /usr/share/xml/scap/ssg/content/`
- Update `ssg_datastream` variable if using different RHEL version

### Connection Issues
- Test SSH access: `ssh ansible@<target-host>`
- Verify `ansible_user` and `ansible_host` in inventory
- Check SSH keys or passwords are configured

## Next Steps

- Configure custom compliance profiles
- Set up exception handling for specific rules
- Integrate with Ansible Automation Platform
- Automate remediation using generated playbooks

For detailed documentation, see [README.md](README.md)
