documentation_complete: true

title: 'Example Custom Hardened Profile'

description: |-
    This is an example custom profile that extends CIS Level 2 Server benchmark
    with additional organizational requirements.

    This profile is for documentation purposes only. Copy and modify for your
    organization's specific needs.

    Key additions:
    - Enhanced password complexity requirements
    - Additional audit logging rules
    - Custom service hardening

    Key removals:
    - Rules that conflict with required legacy applications

extends: xccdf_org.ssgproject.content_profile_cis_level2_server

selections:
    # Additional password requirements beyond CIS L2
    - var_password_pam_minlen=16
    - var_password_pam_dcredit=-2
    - var_password_pam_ucredit=-2
    - var_password_pam_lcredit=-2
    - var_password_pam_ocredit=-2

    # Enhanced audit logging
    - audit_rules_privileged_commands
    - audit_rules_usergroup_modification
    - audit_rules_networkconfig_modification

    # Example: Remove a rule that conflicts with required legacy service
    # Uncomment and modify as needed:
    # - '!service_telnet_disabled'

# Custom variable overrides
# Uncomment and modify as needed:
# var_password_pam_minlen: 16
# var_accounts_maximum_age_login_defs: 60
