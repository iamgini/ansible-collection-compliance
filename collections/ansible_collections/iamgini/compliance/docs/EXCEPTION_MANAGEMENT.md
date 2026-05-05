# Exception Management Guide

This guide provides comprehensive information on managing compliance exceptions in the `iamgini.compliance` collection.

## Table of Contents

1. [Overview](#overview)
2. [Exception Hierarchy](#exception-hierarchy)
3. [Creating Exceptions](#creating-exceptions)
4. [Real-World Examples](#real-world-examples)
5. [Finding Rule IDs](#finding-rule-ids)
6. [Best Practices](#best-practices)
7. [Audit and Reporting](#audit-and-reporting)

## Overview

Compliance exceptions allow you to document and track deviations from security baselines when business or technical requirements necessitate them. The framework provides:

- **Structured Exception Management**: Track why, who, and when exceptions were approved
- **Audit Trail**: Complete history of exceptions in version control
- **Compensating Controls**: Document alternative security measures
- **Review Scheduling**: Automatic tracking of exception review dates
- **Multi-Level**: Support for global, group, and host-specific exceptions

## Exception Hierarchy

Exceptions are resolved in this order (most specific wins):

```
Host Vars (inventory/host_vars/<hostname>.yml)
    ↓ (extends)
Group Vars (inventory/group_vars/<group>.yml)
    ↓ (extends)
Global Defaults (inventory/group_vars/all.yml)
```

### Merging Behavior

- **compliance_skip_rules**: Lists are **merged** (combined from all levels)
- **compliance_exception_reasons**: Dictionaries are **merged**, with host-level reasons **overriding** group-level for the same rule

### Example

```yaml
# group_vars/nginx_servers.yml
compliance_skip_rules:
  - "rule_httpd_disabled"
  - "rule_ip_forward"

# host_vars/nginx-prod-01.yml
compliance_skip_rules:
  - "rule_nfs_disabled"

# Effective result for nginx-prod-01:
# compliance_skip_rules:
#   - "rule_httpd_disabled"      # from group
#   - "rule_ip_forward"          # from group
#   - "rule_nfs_disabled"        # from host
```

## Creating Exceptions

### Step 1: Identify the Rule ID

Rules use XCCDF format: `xccdf_org.ssgproject.content_rule_<rule_name>`

**From HTML Report:**
```
1. Run scan
2. Open HTML report
3. Click on failed rule
4. Copy full Rule ID
```

**From Command Line:**
```bash
# List all rules in profile
oscap info --fetch-remote-resources \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep "xccdf_org.ssgproject.content_rule"

# Search for specific rules
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep -i "ssh\|httpd\|nfs"
```

### Step 2: Determine Exception Level

**Use Group-Level** when:
- Exception applies to ALL servers in a category (e.g., all nginx servers)
- Standard configuration for a server type
- Common business requirement across multiple hosts

**Use Host-Level** when:
- Exception applies to ONE specific server
- Unique business requirement
- Temporary exception for testing/migration

### Step 3: Document the Exception

**Minimum Required Fields:**
```yaml
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_<rule_name>"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_<rule_name>:
    reason: "Clear business/technical justification"
    approved_by: "email@example.com"
    approved_date: "YYYY-MM-DD"
    review_date: "YYYY-MM-DD"
```

**Recommended Additional Fields:**
```yaml
compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_<rule_name>:
    reason: "Detailed explanation"
    business_impact: "Critical | High | Medium | Low"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2027-01-15"
    ticket: "SEC-1234"  # Change management ticket
    compensating_controls:
      - "Alternative security measure 1"
      - "Alternative security measure 2"
    alternative_considered: "Why alternative solution wasn't chosen"
```

## Real-World Examples

### nginx Web Server Exceptions

#### Group Level: All nginx Servers

`inventory/group_vars/nginx_servers.yml`:

```yaml
---
compliance_skip_rules:
  # Web service must be running
  - "xccdf_org.ssgproject.content_rule_service_httpd_disabled"
  
  # Reverse proxy requires IP forwarding
  - "xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward"
  
  # High connection count requires kernel tuning
  - "xccdf_org.ssgproject.content_rule_sysctl_net_core_somaxconn"
  
  # nginx needs network connections
  - "xccdf_org.ssgproject.content_rule_sebool_httpd_can_network_connect"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_httpd_disabled:
    reason: "nginx web server required for production traffic serving"
    business_impact: "Critical - serves customer-facing applications"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2027-01-15"
    ticket: "SEC-1234"
    
  xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward:
    reason: "Required for nginx reverse proxy to backend application servers"
    business_impact: "High - supports microservices architecture"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-15"
    review_date: "2027-01-15"
    compensating_controls:
      - "Firewall rules restrict forwarding to internal backend networks only"
      - "Network segmentation enforced via VLANs"
      
  xccdf_org.ssgproject.content_rule_sysctl_net_core_somaxconn:
    reason: "Increased connection queue (512 → 4096) for high-traffic web server"
    business_impact: "High - prevents connection drops during traffic spikes"
    approved_by: "platform-team@example.com"
    approved_date: "2026-02-01"
    review_date: "2027-02-01"
    
  xccdf_org.ssgproject.content_rule_sebool_httpd_can_network_connect:
    reason: "SELinux boolean required for nginx to proxy to backend services"
    business_impact: "Critical - required for application functionality"
    approved_by: "security-team@example.com"
    approved_date: "2026-01-20"
    review_date: "2027-01-20"
    compensating_controls:
      - "Backend connections restricted to specific ports via SELinux policy"
      - "Application-level authentication enforced on backend connections"
```

#### Host Level: Specific nginx Server

`inventory/host_vars/nginx-prod-01.example.com.yml`:

```yaml
---
# Host inherits all group_vars/nginx_servers.yml exceptions
# Plus these additional host-specific exceptions

compliance_skip_rules:
  # This server needs NFS for shared content
  - "xccdf_org.ssgproject.content_rule_service_nfs_disabled"
  
  # Custom SSH port for deployment automation
  - "xccdf_org.ssgproject.content_rule_firewalld_sshd_port_enabled"
  
  # Monitoring agent requires specific privileges
  - "xccdf_org.ssgproject.content_rule_audit_rules_privileged_commands"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_nfs_disabled:
    reason: "NFS mount for shared static assets (images, CSS, JS) across nginx cluster"
    business_impact: "Critical - content delivery for all web applications"
    approved_by: "security-team@example.com, cto@example.com"
    approved_date: "2026-03-01"
    review_date: "2026-09-01"
    ticket: "SEC-1567"
    compensating_controls:
      - "NFS traffic restricted to dedicated storage VLAN (VLAN 100)"
      - "NFSv4 with Kerberos authentication enabled"
      - "Read-only mount - no write access from web servers"
      - "NFS server IP whitelisting in firewall rules"
    alternative_considered: "Object storage (S3) - planned migration by Q3 2026"
    
  xccdf_org.ssgproject.content_rule_firewalld_sshd_port_enabled:
    reason: "SSH access on custom port 2222 for CI/CD deployment automation"
    business_impact: "High - required for automated deployments"
    approved_by: "security-team@example.com, devops-lead@example.com"
    approved_date: "2026-01-20"
    review_date: "2027-01-20"
    ticket: "SEC-1401"
    compensating_controls:
      - "SSH access restricted to CI/CD runner IP addresses only"
      - "Key-based authentication only - password auth disabled"
      - "fail2ban active with aggressive blocking"
      - "SSH sessions logged to centralized SIEM"
      
  xccdf_org.ssgproject.content_rule_audit_rules_privileged_commands:
    reason: "Datadog agent requires specific privileged commands not in standard audit rules"
    business_impact: "Medium - production monitoring and alerting"
    approved_by: "platform-team@example.com"
    approved_date: "2026-02-10"
    review_date: "2026-08-10"
    ticket: "INFRA-789"
    compensating_controls:
      - "Custom audit rules in /etc/audit/rules.d/datadog.rules"
      - "Agent runs with minimal required capabilities"
```

### Database Server Exceptions

`inventory/group_vars/postgresql_servers.yml`:

```yaml
---
compliance_skip_rules:
  # PostgreSQL service must be running
  - "xccdf_org.ssgproject.content_rule_service_postgresql_disabled"
  
  # Shared memory required for PostgreSQL
  - "xccdf_org.ssgproject.content_rule_sysctl_kernel_shmmax"
  - "xccdf_org.ssgproject.content_rule_sysctl_kernel_shmall"
  
  # File descriptors for database connections
  - "xccdf_org.ssgproject.content_rule_file_descriptor_limits"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_postgresql_disabled:
    reason: "PostgreSQL database service required for application data storage"
    business_impact: "Critical - primary application database"
    approved_by: "dba-team@example.com, security-team@example.com"
    approved_date: "2026-01-10"
    review_date: "2027-01-10"
    
  xccdf_org.ssgproject.content_rule_sysctl_kernel_shmmax:
    reason: "PostgreSQL requires 8GB shared memory for optimal performance"
    business_impact: "High - prevents database performance degradation"
    approved_by: "dba-team@example.com"
    approved_date: "2026-01-10"
    review_date: "2027-01-10"
    compensating_controls:
      - "Shared memory usage monitored via Prometheus"
      - "Memory limits enforced via systemd cgroup limits"
```

### Container Host Exceptions

`inventory/group_vars/docker_hosts.yml`:

```yaml
---
compliance_skip_rules:
  # Docker requires IP forwarding
  - "xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward"
  
  # Container networking
  - "xccdf_org.ssgproject.content_rule_sysctl_net_bridge_nf_call_iptables"
  
  # Docker service enabled
  - "xccdf_org.ssgproject.content_rule_service_docker_disabled"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward:
    reason: "Docker container networking requires IP forwarding for NAT"
    business_impact: "Critical - required for container-to-container communication"
    approved_by: "platform-team@example.com"
    approved_date: "2026-02-01"
    review_date: "2027-02-01"
    compensating_controls:
      - "Docker network isolation via separate bridge networks"
      - "iptables rules restrict inter-container traffic"
      - "Kubernetes network policies enforce segmentation"
```

## Finding Rule IDs

### Method 1: Scan Report (Easiest)

1. Run a compliance scan:
   ```bash
   ansible-playbook playbooks/scan.yml -i inventory -l target-host
   ```

2. Open HTML report:
   ```
   http://report-server.internal/reports/<customer>/<hostname>/<date>/report.html
   ```

3. Browse to failed rules section
4. Click on rule title
5. Copy Rule ID (e.g., `xccdf_org.ssgproject.content_rule_sshd_disable_root_login`)

### Method 2: Query ARF XML

```bash
# Extract all failed rules from recent scan
oscap xccdf eval --results-arf /var/reports/<customer>/<host>/results.xml \
  --profile <profile_id> \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml 2>&1 | \
  grep "Result.*fail"

# Parse ARF XML for rule IDs
xmllint --xpath "//rule-result[@idref and result='fail']/@idref" \
  /var/reports/<customer>/<host>/results.xml
```

### Method 3: Browse SSG Content

```bash
# List all available rules
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep "xccdf_org.ssgproject.content_rule"

# Search for specific keywords
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep -i "ssh\|firewall\|selinux" | \
  grep "xccdf_org.ssgproject.content_rule"

# Get rule details
oscap info --fetch-remote-resources \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | \
  grep -A 5 "rule_sshd_disable_root_login"
```

### Method 4: GitHub SSG Repository

Browse rules at: https://github.com/ComplianceAsCode/content/tree/master/linux_os/guide

Example structure:
```
linux_os/guide/
├── services/
│   ├── ssh/
│   │   └── ssh_server/
│   │       └── sshd_disable_root_login/
│   │           └── rule.yml
│   └── http/
├── system/
└── audit/
```

## Best Practices

### 1. Documentation Standards

**Always Include:**
- Clear, specific reason (not just "required for business")
- Business impact assessment
- Approver name/email
- Approval and review dates
- Change ticket reference

**Recommended:**
- Compensating controls implemented
- Alternative solutions considered
- Rollback/removal plan
- Emergency contact

### 2. Approval Requirements

**Low Risk Exceptions:**
- Single approver (team lead or security officer)
- 12-month review cycle

**Medium Risk Exceptions:**
- Security team approval required
- 6-month review cycle
- Compensating controls documented

**High Risk Exceptions:**
- Multi-party approval (Security + CTO/CISO)
- 3-6 month review cycle
- Formal risk assessment
- Compensating controls mandatory
- Documented migration/removal plan

### 3. Review Cycles

Set appropriate review dates based on risk:

```yaml
# Low risk - annual review
review_date: "2027-01-15"  # 12 months

# Medium risk - semi-annual
review_date: "2026-07-15"  # 6 months

# High risk - quarterly
review_date: "2026-04-15"  # 3 months

# Temporary exception
review_date: "2026-03-01"  # Short duration
alternative_considered: "Migration to compliant solution by Q2 2026"
```

### 4. Version Control

Commit exception files with clear messages:

```bash
# Good commit messages
git add inventory/group_vars/nginx_servers.yml
git commit -m "Add exception for nginx IP forwarding (SEC-1234)

- Approved by security-team@example.com on 2026-01-15
- Required for reverse proxy functionality
- Compensating controls: firewall restrictions
- Review date: 2027-01-15"

# Bad commit message
git commit -m "Updated exceptions"
```

### 5. Compensating Controls

Always document alternative security measures:

```yaml
compensating_controls:
  # Good examples
  - "Firewall rules restrict traffic to 10.0.0.0/8 only"
  - "NFSv4 with Kerberos authentication required"
  - "Network IDS monitors for suspicious activity"
  - "Application-level encryption enforced (TLS 1.3)"
  
  # Too vague (avoid)
  - "Network security in place"
  - "Monitoring enabled"
  - "Security controls applied"
```

### 6. Organization by Server Type

```
inventory/
├── group_vars/
│   ├── all.yml                      # Minimal global exceptions
│   ├── nginx_servers.yml            # Web server exceptions
│   ├── postgresql_servers.yml       # Database exceptions
│   ├── docker_hosts.yml             # Container host exceptions
│   ├── pci_dmz.yml                  # PCI compliance zone
│   └── development_servers.yml      # Dev environment (more relaxed)
└── host_vars/
    └── <specific-exceptions-only>/
```

## Audit and Reporting

### Exception Registry

The framework automatically generates an exception registry JSON file:

```
/var/reports/<customer>/exceptions/
├── exception_registry.json          # All exceptions
├── exceptions_by_host.json          # Per-host view
└── review_schedule.json             # Upcoming reviews
```

### Registry Format

```json
{
  "generated_at": "2026-05-05T10:30:00Z",
  "customer_id": "web-infrastructure",
  "total_exceptions": 8,
  "exceptions": [
    {
      "rule_id": "xccdf_org.ssgproject.content_rule_service_nfs_disabled",
      "hosts": ["nginx-prod-01.example.com"],
      "reason": "NFS required for shared static assets",
      "approved_by": "security-team@example.com",
      "approved_date": "2026-03-01",
      "review_date": "2026-09-01",
      "risk_level": "high",
      "compensating_controls": [
        "NFSv4 with Kerberos",
        "Read-only mount"
      ]
    }
  ]
}
```

### Upcoming Reviews Report

Query exceptions needing review:

```bash
# Find exceptions expiring in next 30 days
ansible-playbook playbooks/report_exception_reviews.yml \
  -e "review_window_days=30"
```

Output:
```
Exceptions Requiring Review (Next 30 Days):
============================================

nginx-prod-01.example.com:
  - rule_service_nfs_disabled
    Review Date: 2026-09-01
    Approved By: security-team@example.com
    Ticket: SEC-1567
```

## Troubleshooting

### Exception Not Applied

**Check effective exceptions:**
```bash
ansible-inventory -i inventory --host nginx-prod-01.example.com | \
  jq '.compliance_skip_rules'
```

**Verify variable precedence:**
```bash
ansible-playbook playbooks/debug_exceptions.yml \
  -i inventory \
  -l nginx-prod-01.example.com
```

### Rule ID Not Found

**Verify rule exists in profile:**
```bash
oscap xccdf eval \
  --profile <profile_id> \
  --check-engine-results \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml 2>&1 | \
  grep "rule_name"
```

### Syntax Errors

**Validate YAML syntax:**
```bash
yamllint inventory/group_vars/nginx_servers.yml
ansible-playbook playbooks/scan.yml --syntax-check
```

## Additional Resources

- [ComplianceAsCode Rule Index](https://github.com/ComplianceAsCode/content)
- [OpenSCAP User Manual](https://www.open-scap.org/resources/documentation/)
- [NIST 800-53 Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

## Support

For questions about exception management:
- GitHub Issues: https://github.com/iamgini/ansible-collection-compliance/issues
- Documentation: https://github.com/iamgini/ansible-collection-compliance/wiki
