# Ansible Collection: iamgini.compliance

Platform-agnostic compliance automation framework — OpenSCAP for Linux, `infra.windows_ops` for Windows.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/ansible-2.14%2B-green.svg)](https://www.ansible.com/)

## Supported Platforms

| Platform | Framework | Benchmarks |
|----------|-----------|------------|
| RHEL 7/8/9/10, Rocky, Alma, Fedora | OpenSCAP + ComplianceAsCode | CIS, STIG, PCI-DSS, HIPAA, OSPP |
| Windows Server 2019/2022/2025 | [`infra.windows_ops`](https://github.com/redhat-cop/infra.windows_ops) | CIS (L1/L2), DISA STIG |

## Architecture

```
Linux (OpenSCAP):
  scan → parse → generate fix → [approval gate] → remediate → rescan

Windows (infra.windows_ops):
  audit (check mode) → [approval gate] → apply hardening
```

Both pipelines use the same `compliance_skip_rules` exception pattern and are AAP workflow-ready.

## Quick Start

```bash
# Install
ansible-galaxy collection install iamgini.compliance
ansible-galaxy collection install -r collections/requirements.yml

# Linux: scan
ansible-playbook playbooks/oscap_scan.yml

# Linux: full cycle (scan + parse + generate fix + commit)
ansible-playbook playbooks/oscap_site.yml

# Windows: CIS hardening
ansible-playbook playbooks/windows_cis.yml

# Windows: STIG hardening
ansible-playbook playbooks/windows_stig.yml

# Drift detection (any playbook)
ansible-playbook playbooks/<playbook>.yml --check
```

## Collection Structure

```
iamgini.compliance/
├── playbooks/
│   ├── oscap_site.yml            # Linux: all phases (scan→parse→generate→commit)
│   ├── oscap_scan.yml            # Linux: OpenSCAP scan
│   ├── oscap_parse.yml           # Linux: parse ARF XML results
│   ├── oscap_generate_fix.yml    # Linux: generate remediation playbook
│   ├── oscap_remediate.yml       # Linux: apply remediation
│   ├── oscap_rescan.yml          # Linux: validation rescan
│   ├── commit_reports.yml        # Git commit generated playbooks
│   ├── setup_report_server.yml   # One-time report server setup
│   ├── windows_cis.yml           # Windows: CIS Benchmark hardening
│   └── windows_stig.yml          # Windows: DISA STIG hardening
├── roles/
│   ├── oscap_scan/               # Install OpenSCAP, run scan, fetch results
│   ├── oscap_parse/              # Parse ARF XML, extract failures
│   ├── oscap_generate_fix/       # oscap generate fix wrapper
│   ├── report_server/            # nginx report server setup
│   └── exception_handler/        # Merge group + host exceptions
├── group_vars/
│   ├── all.yml                   # Global defaults (profile, report server)
│   └── windows_targets.yml       # Windows group defaults
├── execution-environment/        # Custom EE with OpenSCAP + collections
├── collections/requirements.yml  # Collection dependencies
├── profiles/overlay/             # Custom compliance profiles
└── generated/                    # Auto-generated remediation playbooks
```

## Configuration

### Key Variables (`group_vars/all.yml`)

```yaml
customer_id: "my-org"
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level2_server"
ssg_datastream: "/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml"
report_server_host: "report-server.internal"
report_server_base_dir: "/var/reports"
generate_fix_mode: "report_server"    # or "execution_environment"
compliance_skip_rules: []
```

### Generation Modes

| Mode | Where `oscap generate fix` runs | Best for |
|------|---------------------------------|----------|
| `report_server` | On the report server (needs `openscap-utils`) | Persistent infrastructure |
| `execution_environment` | Inside AAP Execution Environment | Dynamic/containerized setups |

## Exception Handling

Skip rules that don't apply to your environment. Exceptions are documented, auditable, and merge across group and host levels.

**Group-level** (`group_vars/<group>.yml`) — applies to all hosts in a group:

```yaml
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_service_nfs_disabled"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_nfs_disabled:
    reason: "NFS required for shared storage"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-01"
    review_date: "2026-07-01"
```

**Host-level** (`host_vars/<hostname>.yml`) — extends group exceptions, host takes precedence for same rule.

**Windows** uses the same pattern with CIS rule IDs (`"1.1.1"`) or STIG IDs (`"V-254238"`).

## Windows Usage

```bash
# CIS Level 1 (default) or Level 2
ansible-playbook playbooks/windows_cis.yml
ansible-playbook playbooks/windows_cis.yml -e "windows_cis_profile='Level 2'"

# STIG
ansible-playbook playbooks/windows_stig.yml

# Run specific categories or rules
ansible-playbook playbooks/windows_cis.yml --tags password_policies
ansible-playbook playbooks/windows_stig.yml --tags cat_i
ansible-playbook playbooks/windows_cis.yml -e '{"windows_cis_only_rules": ["1.1.1", "1.1.2"]}'

# Skip specific rules
ansible-playbook playbooks/windows_cis.yml -e '{"windows_cis_skip_rules": ["5.1"]}'
```

Windows hosts need WinRM configured. Add to inventory:

```ini
[windows_targets:vars]
ansible_connection=winrm
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
ansible_port=5986
```

## AAP Integration

Each playbook maps to a job template. The full compliance cycle is a workflow template:

```
Linux:   scan → parse → generate fix → commit → APPROVAL → remediate → rescan
Windows: audit (check mode) → APPROVAL → apply hardening
```

AAP Configuration-as-Code definitions are available in the companion [`ansible-aap-cac`](https://github.com/iamgini/ansible-aap-cac) repository under `compliance_ops/`.

### Required Credentials

| Credential | Type | Used by |
|------------|------|---------|
| `Compliance-Linux-Machine` | Machine (SSH) | All Linux playbooks |
| `Compliance-Windows-Machine` | Machine (WinRM) | Windows CIS/STIG playbooks |
| `Compliance-SCM` | Source Control | `commit_reports.yml` |

## Related Projects

| Project | Description |
|---------|-------------|
| [ComplianceAsCode/content](https://github.com/ComplianceAsCode/content) | Upstream source for SSG datastreams and remediation content |
| [infra.windows_ops](https://github.com/redhat-cop/infra.windows_ops) | Red Hat CoP validated collection for Windows CIS/STIG |
| [RedHatOfficial CIS roles](https://github.com/orgs/RedHatOfficial/repositories?q=cis) | Pre-built RHEL CIS roles (alternative to `oscap generate fix`) |
| [OpenSCAP](https://www.open-scap.org/) | SCAP scanner implementation |

## License

Apache License 2.0 — see [LICENSE](LICENSE).
