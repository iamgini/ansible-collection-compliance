# Custom Profile Overlays

This directory is for organization-specific or custom compliance profile definitions.

## Creating a Custom Profile

Custom profiles can:
1. Extend existing SSG profiles with additional rules
2. Remove rules that don't apply to your environment
3. Define entirely new compliance requirements
4. Combine multiple standard profiles

## Profile Format

Profiles use YAML format following ComplianceAsCode conventions:

```yaml
documentation_complete: true

title: 'Custom Hardened Profile for Linux Servers'

description: |-
    This profile extends CIS Level 2 with additional organizational requirements.

extends: xccdf_org.ssgproject.content_profile_cis_level2_server

selections:
    # Additional rules beyond CIS L2
    - rule_id_1
    - rule_id_2
    # Remove rules that don't apply
    - '!rule_id_to_remove'
```

## Using Custom Profiles

1. Place your `.profile` file in this directory
2. Build a custom SSG datastream that includes your profile
3. Reference the profile in `group_vars/` using its XCCDF ID
4. Update `ssg_datastream` path to point to your custom datastream

## Example

See `example-custom.profile` for a documented example.

## Resources

- ComplianceAsCode Profile Guide: https://complianceascode.readthedocs.io/en/latest/manual/developer/02_building_profile.html
- SSG Rule Browser: https://static.open-scap.org/ssg-guides/
