# Group Variables

This directory contains default variable definitions for the compliance scanning playbooks.

## Variable Files

### all.yml
Global defaults that apply to all hosts. These can be overridden at the group or host level.

**Key Variables:**

| Variable | Default | Description |
|----------|---------|-------------|
| `customer_id` | `demo-org` | Organization/customer identifier for reporting |
| `cis_profile` | `cis_level2_server` | CIS profile to scan against |
| `ssg_datastream` | `/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml` | SCAP content datastream file |
| `report_server_host` | `report_server` | Inventory hostname of the report server |
| `report_server_base_dir` | `/var/www/compliance-reports` | Base directory for storing reports |

## Overriding Defaults

### At Group Level
Create group-specific variable files:
```
group_vars/
  rhel9_cis_l2.yml
  rhel9_cis_l1.yml
  rhel9_stig.yml
```

Example `group_vars/rhel9_cis_l1.yml`:
```yaml
---
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level1_server"
customer_id: "prod-environment"
```

### At Host Level
Create `host_vars/` directory with host-specific files:
```
host_vars/
  rhel9-server-01.yml
```

Example `host_vars/rhel9-server-01.yml`:
```yaml
---
customer_id: "critical-system"
compliance_skip_rules:
  - xccdf_org.ssgproject.content_rule_disable_host_auth
compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_disable_host_auth: "Required for legacy app integration"
```

## Common Profile Values

**CIS Profiles:**
- `xccdf_org.ssgproject.content_profile_cis_level1_server` - CIS Level 1 Server
- `xccdf_org.ssgproject.content_profile_cis_level2_server` - CIS Level 2 Server
- `xccdf_org.ssgproject.content_profile_cis_level1_workstation` - CIS Level 1 Workstation
- `xccdf_org.ssgproject.content_profile_cis_level2_workstation` - CIS Level 2 Workstation

**STIG Profiles:**
- `xccdf_org.ssgproject.content_profile_stig` - DISA STIG
- `xccdf_org.ssgproject.content_profile_stig_gui` - DISA STIG for GUI systems

**Other Profiles:**
- `xccdf_org.ssgproject.content_profile_pci-dss` - PCI-DSS
- `xccdf_org.ssgproject.content_profile_hipaa` - HIPAA
- `xccdf_org.ssgproject.content_profile_ospp` - OSPP (Protection Profile for General Purpose OS)

## SSG Datastream Paths

- **RHEL 9**: `/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml`
- **RHEL 8**: `/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml`
- **RHEL 7**: `/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml`
- **Ubuntu 20.04**: `/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml`
- **Ubuntu 22.04**: `/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml`
