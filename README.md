#  Ansible for Compliance Hardening

A community Ansible collection for automated security compliance scanning and remediation using OpenSCAP and ComplianceAsCode.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/ansible-2.14%2B-green.svg)](https://www.ansible.com/)

## Overview

`iamgini.compliance` is a platform-agnostic, open-source compliance automation framework that enables:

- **Automated Security Scanning**: Run OpenSCAP compliance scans across your infrastructure
- **Intelligent Remediation**: Generate and apply targeted remediation playbooks
- **Exception Management**: Handle compliance exceptions at group and host levels
- **Compliance Reporting**: Track compliance scores and generate audit-ready reports
- **GitOps Workflow**: Version-controlled remediation playbooks with approval gates

## Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Linux (RHEL family) | ✅ Supported | RHEL 8, 9, Rocky, AlmaLinux, Fedora |
| Linux (Debian family) | ✅ Supported | Ubuntu 22.04+, Debian 11+ |
| Windows | 🚧 Planned | Phase 4 - Different toolchain |
| Network Devices | 🚧 Planned | Future phase |

## Architecture

The framework implements a 4-phase workflow:

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: SCAN                                                   │
│ ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐    │
│ │ Run OpenSCAP│───▶│ Fetch Results│───▶│ Push to Report  │    │
│ │ on Targets  │    │ to Controller│    │ Server (nginx)  │    │
│ └─────────────┘    └──────────────┘    └─────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Phase 2: ANALYZE & GENERATE                                     │
│ ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐    │
│ │ Parse ARF   │───▶│ Generate Fix │───▶│ Commit to Git   │    │
│ │ Extract Fail│    │ Playbook     │    │ Repository      │    │
│ └─────────────┘    └──────────────┘    └─────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: REMEDIATE (Manual Approval Required)                   │
│ ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐    │
│ │ Load        │───▶│ Apply        │───▶│ Validation      │    │
│ │ Exceptions  │    │ Remediation  │    │ Rescan          │    │
│ └─────────────┘    └──────────────┘    └─────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Install the Collection

```bash
ansible-galaxy collection install iamgini.compliance
```

### 2. Configure Inventory

Create `inventory/group_vars/all.yml`:

```yaml
customer_id: "my-org"
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level2_server"
ssg_datastream: "/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml"
report_server_host: "report-server.internal"
report_server_base_dir: "/var/reports"
```

### 3. Set Up Report Server

```bash
ansible-playbook playbooks/setup_report_server.yml -i hosts.ini
```

### 4. Run Your First Scan

```bash
ansible-playbook playbooks/scan.yml -i hosts.ini
```

### 5. View Results

Browse to: `http://report-server.internal/reports/<customer_id>/<hostname>/<date>-<profile>/report.html`

## Collection Structure

```
iamgini.compliance/
├── roles/
│   ├── oscap_scan/          # OpenSCAP scanning on targets
│   ├── report_server/       # nginx-based report server setup
│   ├── parse_results/       # ARF XML parsing and analysis
│   ├── generate_fix/        # Remediation playbook generation
│   └── exception_handler/   # Exception and deviation management
├── playbooks/
│   ├── site.yml            # Master playbook (all phases)
│   ├── scan.yml            # Phase 1: Scan execution
│   ├── parse_failures.yml  # Phase 2: Parse results
│   ├── generate_remediation.yml  # Phase 2: Generate fix
│   ├── commit_playbook.yml # Phase 2: Git commit
│   ├── remediate.yml       # Phase 3: Apply remediation
│   └── rescan.yml          # Phase 3: Validation scan
├── inventory/
│   ├── group_vars/         # Group-level configuration
│   └── host_vars/          # Host-level exceptions
└── profiles/
    ├── overlay/            # Custom profile definitions
    └── README.md           # Profile documentation
```

## Configuration

### Variable Hierarchy

Variables are resolved in this order (highest precedence first):

1. **Host vars** (`inventory/host_vars/<hostname>.yml`)
2. **Group vars** (`inventory/group_vars/<group>.yml`)
3. **Global defaults** (`inventory/group_vars/all.yml`)
4. **Role defaults** (`roles/*/defaults/main.yml`)

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `customer_id` | Organization identifier | `default-org` |
| `cis_profile` | XCCDF profile ID | `cis_level2_server` |
| `ssg_datastream` | Path to SSG datastream XML | (platform-specific) |
| `report_server_host` | Report server hostname | `report-server.internal` |
| `generate_fix_mode` | Generation mode | `report_server` |
| `compliance_skip_rules` | Rules to skip (exceptions) | `[]` |

### Generation Modes

The collection supports two modes for generating remediation playbooks:

#### Mode 1: Report Server (Default)

```yaml
generate_fix_mode: "report_server"
```

- Runs `oscap generate fix` on the report server
- Requires `openscap-utils` on report server
- Best for persistent infrastructure

#### Mode 2: Execution Environment

```yaml
generate_fix_mode: "execution_environment"
```

- Runs `oscap generate fix` inside Ansible Automation Platform EE
- Requires `openscap-utils` in EE image
- Best for dynamic/containerized environments

## Exception Handling

Exceptions allow you to skip rules that don't apply to your environment.

### Group-Level Exceptions

Define in `inventory/group_vars/<group>.yml`:

```yaml
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_service_nfs_disabled"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_nfs_disabled:
    reason: "NFS required for shared application data"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-01"
    review_date: "2026-07-01"
```

### Host-Level Exceptions

Define in `inventory/host_vars/<hostname>.yml`:

```yaml
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_package_tftp_removed"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_package_tftp_removed:
    reason: "PXE boot server - TFTP required"
    approved_by: "infra-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2026-07-15"
```

### How Exceptions Work

1. Group and host exceptions are **merged** (host extends group)
2. Host-level reasons **override** group-level for the same rule
3. Exception registry JSON is written to report server
4. Remediation playbook uses skip tags based on effective exceptions

### Managing Exceptions by Server Type

For server types with common exception requirements (web servers, database servers, etc.), use group-based exceptions to avoid duplication.

#### Example: nginx Web Servers

**Step 1: Create an inventory group**

In `inventory/hosts.yml`:

```yaml
all:
  children:
    nginx_servers:
      hosts:
        nginx-prod-01.example.com:
        nginx-prod-02.example.com:
        nginx-staging-01.example.com:
```

**Step 2: Create group-level exceptions**

Create `inventory/group_vars/nginx_servers.yml`:

```yaml
---
# Exceptions common to ALL nginx servers
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_service_httpd_disabled"
  - "xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_httpd_disabled:
    reason: "nginx web server required for production traffic"
    business_impact: "Critical - serves customer applications"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2027-01-15"
    ticket: "SEC-1234"

  xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward:
    reason: "Required for nginx reverse proxy to backend servers"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2027-01-15"
    compensating_controls:
      - "Firewall rules restrict forwarding to internal networks only"
```

**Step 3: Add host-specific exceptions (if needed)**

For servers with unique requirements, create `inventory/host_vars/<hostname>.yml`:

```yaml
---
# nginx-prod-01.example.com has additional exceptions
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_service_nfs_disabled"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_nfs_disabled:
    reason: "NFS required for shared static assets across cluster"
    business_impact: "Critical - content delivery"
    approved_by: "security-team@example.com"
    approved_date: "2026-03-01"
    review_date: "2026-09-01"
    ticket: "SEC-1567"
    compensating_controls:
      - "NFSv4 with Kerberos authentication"
      - "Read-only mount"
      - "Dedicated storage VLAN"
```

#### Finding Rule IDs for Exceptions

**Method 1: From HTML Report**

1. Run a scan: `ansible-playbook playbooks/scan.yml`
2. Open the HTML report at: `http://report-server.internal/reports/<customer>/<host>/<date>/report.html`
3. Find the failing rule (e.g., "Disable SSH Root Login")
4. Copy the full Rule ID from the report (e.g., `xccdf_org.ssgproject.content_rule_sshd_disable_root_login`)

**Method 2: From ARF XML**

```bash
# List all failed rules from most recent scan
oscap info --fetch-remote-resources \
  /var/reports/<customer>/<host>/<date>/results.xml | \
  grep "xccdf_org.ssgproject.content_rule"
```

**Method 3: From SSG Content**

```bash
# Search available rules in datastream
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep -i "nginx\|httpd\|web"
```

#### Exception Best Practices

1. **Document Business Impact**: Always explain why the exception is needed and what breaks without it
2. **Track Approvals**: Include approver email and approval date for audit trails
3. **Set Review Dates**: Schedule regular reviews (typically 6-12 months)
4. **Add Compensating Controls**: List alternative security measures implemented
5. **Reference Tickets**: Link to change management or security review tickets
6. **Use Group Vars**: Consolidate common exceptions at the group level
7. **Version Control**: Commit exception files to Git with descriptive messages

#### Exception File Locations

```
inventory/
├── group_vars/
│   ├── all.yml                    # Global defaults (minimal exceptions)
│   ├── nginx_servers.yml          # Exceptions for all nginx servers
│   ├── database_servers.yml       # Exceptions for all database servers
│   └── pci_compliance_scope.yml   # Exceptions for PCI-DSS systems
└── host_vars/
    ├── nginx-prod-01.example.com.yml   # Host-specific exceptions
    └── db-prod-01.example.com.yml      # Host-specific exceptions
```

#### Example Exception Scenarios by Server Type

**Web Servers (nginx, Apache)**
- HTTP/HTTPS services enabled
- Reverse proxy network settings
- Custom kernel tuning for high connections
- SELinux booleans for network connectivity

**Database Servers (PostgreSQL, MySQL)**
- Database service enabled
- Increased shared memory limits
- Custom file descriptor limits
- Database-specific port access

**Container Hosts (Docker, Podman)**
- IP forwarding enabled
- Bridge networking enabled
- Storage driver requirements
- cgroup configurations

**See Real Examples**: Check `inventory/group_vars/nginx_servers.yml` and `inventory/host_vars/nginx-prod-01.example.com.yml` for complete nginx exception templates with detailed justifications.

## Ansible Automation Platform Integration

### Workflow Template Setup

Create an AAP workflow template with these nodes:

```
Node 1: job_template → scan
Node 2: job_template → parse_failures
Node 3: job_template → generate_remediation
Node 4: approval_node (APPROVAL GATE - human review required)
Node 5: job_template → remediate
Node 6: job_template → rescan
```

### Job Template Configuration

Each playbook becomes a job template:

- **scan**: `playbooks/scan.yml`
- **parse_failures**: `playbooks/parse_failures.yml`
- **generate_remediation**: `playbooks/generate_remediation.yml`
- **remediate**: `playbooks/remediate.yml`
- **rescan**: `playbooks/rescan.yml`

### Credentials

Required credentials in AAP:

- **Machine Credential**: SSH access to managed nodes
- **SCM Credential**: Git repository access (for commit_playbook.yml)
- **Report Server Credential**: SSH access to report server

## Testing

### Linting

```bash
# Ansible lint
ansible-lint playbooks/

# YAML lint
yamllint .
```

### Molecule

```bash
# Test individual roles
cd roles/oscap_scan
molecule test

# Test full workflow
cd tests/molecule/default
molecule test
```

### Dry Run

```bash
# Syntax check generated remediation
ansible-playbook --syntax-check generated/<customer>/<host>/<date>/remediation.yml

# Check mode (no changes)
ansible-playbook playbooks/remediate.yml --check
```

## Contributing

Contributions are welcome! This is a community-driven project.

### Adding New Profiles

1. Create profile in `profiles/overlay/<name>.profile`
2. Build custom SSG datastream (if needed)
3. Test with a scan
4. Submit PR with documentation

### Adding Platform Support

1. Update platform detection in `roles/oscap_scan/tasks/install.yml`
2. Add platform-specific package lists
3. Update documentation
4. Test on target platform

### Resources

- [ComplianceAsCode Project](https://github.com/ComplianceAsCode/content)
- [OpenSCAP Documentation](https://www.open-scap.org/resources/documentation/)
- [Ansible Collection Development](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html)

## License

Apache License 2.0 - See [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/iamgini/ansible-collection-compliance/issues)
- **Documentation**: [Wiki](https://github.com/iamgini/ansible-collection-compliance/wiki)
- **Community**: [Discussions](https://github.com/iamgini/ansible-collection-compliance/discussions)

## Acknowledgments

This collection builds on:

- [ComplianceAsCode](https://github.com/ComplianceAsCode/content) - Open-source security content
- [OpenSCAP](https://www.open-scap.org/) - SCAP scanner implementation
- Ansible community collections and best practices

---

**Note**: This collection is vendor-neutral and platform-agnostic. It works with any Ansible deployment, including Ansible Automation Platform, community ansible-core, and other automation platforms.
