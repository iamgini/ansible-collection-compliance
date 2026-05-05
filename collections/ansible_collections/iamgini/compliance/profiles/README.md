# Compliance Profiles

This directory contains compliance profile definitions and customizations.

## Directory Structure

- `upstream/`: Reserved for upstream ComplianceAsCode/SSG profile references
- `overlay/`: Custom and organization-specific profile overlays

## Using Profiles

Profiles are referenced in `group_vars/` files using their full XCCDF identifier:

```yaml
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level2_server"
```

## Standard Profiles Available in SSG

### CIS Benchmarks
- `cis_level1_server` - CIS Level 1 Server
- `cis_level2_server` - CIS Level 2 Server
- `cis_level1_workstation` - CIS Level 1 Workstation
- `cis_level2_workstation` - CIS Level 2 Workstation

### Government Standards
- `stig` - DISA STIG for applicable OS
- `pci-dss` - PCI-DSS v3.2.1
- `hipaa` - HIPAA Security Rule
- `ospp` - OSPP (Common Criteria)

### Industry Standards
- `standard` - Standard System Security Profile
- `anssi_bp28_high` - ANSSI BP-028 High Level
- `cui` - Controlled Unclassified Information (CUI)

## Custom Profile Overlays

Custom profiles extend or modify upstream profiles. Create overlay profiles in `overlay/` directory.

Example: `overlay/custom-hardened.profile`

Refer to ComplianceAsCode documentation for profile syntax:
https://complianceascode.readthedocs.io/en/latest/manual/developer/02_building_profile.html
