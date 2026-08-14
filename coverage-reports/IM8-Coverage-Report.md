# Singapore IM8 Coverage Report

Mapping Singapore Government ICT&SS (IM8) security controls to automation coverage
provided by RedHatOfficial CIS roles (Linux) and `infra.windows_ops` CIS/STIG roles (Windows).

## Summary

| IM8 Family | Controls Mapped | Directly Satisfied | Partially Satisfied | Not Addressed |
|------------|----------------:|-------------------:|--------------------:|--------------:|
| IS — Infrastructure Security | 5 | 3 | 2 | 0 |
| AC — Access Control | 5 | 2 | 2 | 1 |
| LM — Logging & Monitoring | 3 | 1 | 2 | 0 |
| NS — Network Security | 1 | 1 | 0 | 0 |
| DP — Data Protection | 2 | 1 | 1 | 0 |
| ST — Security Testing | 2 | 0 | 1 | 1 |
| CK — Cryptography | 1 | 1 | 0 | 0 |
| **Total** | **19** | **9** | **8** | **2** |

**Coverage**: 9/19 directly satisfied (47%), 8/19 partially satisfied (42%), 2/19 not addressed (11%).

## Scope

**IM8 controls mapped**: Only controls with host-level technical requirements automatable
via OS hardening roles. Cloud-native controls (tenant management, CSP posture, CSPM),
organisational controls (domain registration, public disclosure programmes), and
Singapore-specific identity controls (Singpass/Corppass) are excluded.

**Automation roles assessed**:

| Role | Platform | Source |
|------|----------|--------|
| `RedHatOfficial.rhel9_cis_server_l1` | RHEL 9 | [GitHub](https://github.com/RedHatOfficial/ansible-role-rhel9-cis_server_l1) — CIS v2.0.0 |
| `infra.windows_ops.windows_manage_cis` | Windows Server 2022 | [Red Hat CoP](https://github.com/redhat-cop/infra.windows_ops) v2.0.1 |
| `infra.windows_ops.windows_manage_stig` | Windows Server 2022 | [Red Hat CoP](https://github.com/redhat-cop/infra.windows_ops) v2.0.1 |

**IM8 profile levels**: Level 0 (mandatory), Level 1 (hygiene), Level 2 (best practice).
Most mapped controls are Level 0 or Level 1 for medium-risk cloud systems.

---

## Detailed Control Mapping

### IS — Infrastructure Security

#### IS-3: Restricted Administrator Privileges (Level 1)

> "Restrict administrator privileges by disabling remote login for the root/administrator user
> and restricting sudo/administrators group access."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 5.2.10 | `sshd_disable_root_login` | Disables SSH root login (`PermitRootLogin no`) |
| 4.3.4 | `sudo_require_reauthentication` | Requires re-authentication for sudo (`timestamp_timeout`) |
| 4.3.5 | `sudo_remove_no_authenticate` | Removes `NOPASSWD` entries from sudoers |
| 4.3.6 | `ensure_pam_wheel_group_empty` | Restricts `su` to wheel/sugroup members |
| 4.3.2 | `sudo_add_use_pty` | Forces sudo to run in a pseudo-terminal |
| 4.3.3 | `sudo_custom_logfile` | Enables sudo command logging |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 2.2.x User Rights | Restricts "Act as part of the OS" to nobody, limits RDP/local logon to Admins |
| 2.3.x Security Options | Renames default administrator account, disables Guest |

**Windows — `windows_manage_stig`:**

| STIG Controls | What It Does |
|---------------|--------------|
| V-254451–V-254461 | "Act as part of OS" empty, log on locally Admins-only, deny Guest logon |

---

#### IS-4: Least Functionality (Level 1)

> "Disable or remove unnecessary functions, system ports, protocols, software, and services on the host."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Section | Toggle Variables (examples) | What It Does |
|-------------|---------------------------|--------------|
| 1.1.1.x Filesystems | `kernel_module_cramfs_disabled`, `kernel_module_freevxfs_disabled`, `kernel_module_hfs_disabled`, `kernel_module_hfsplus_disabled`, `kernel_module_jffs2_disabled` | Disables unused filesystem kernel modules |
| 2.1.x Services | `service_autofs_disabled`, `service_avahi_daemon_disabled`, `service_cups_disabled`, `service_bluetooth_disabled`, `service_rpcbind_disabled`, `service_nfs_disabled` | Disables unnecessary services |
| 2.2.x Packages | `package_bind_removed`, `package_dhcp_removed`, `package_httpd_removed`, `package_nginx_removed`, `package_vsftpd_removed`, `package_ftp_removed`, `package_telnet_removed`, `package_samba_removed`, `package_squid_removed`, `package_rsync_removed` | Removes unnecessary server packages |
| 3.2.x Network | (gap) | Network protocol modules (dccp, sctp, tipc) — missing in role |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 5.x Services | Disables 8 services: Remote Registry, Simple TCP/IP, Telnet, Xbox Live, Print Spooler (conditional), others |

**Windows — `windows_manage_stig`:**

| STIG Controls | What It Does |
|---------------|--------------|
| V-254401–V-254410+ | Disables 10+ services: Telnet (CAT I), Fax, FTP, IIS Admin, iSCSI, Simple TCP/IP, SNMP/Trap, RD Gateway |

---

#### IS-5: Host System Hardening (Level 1)

> "Harden the host configuration with reference to industry standards."
> Guidance: "Use appropriate benchmarks from NIST National Checklist Program or CIS Benchmarks."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

This is the umbrella IM8 control that explicitly references CIS Benchmarks. The entire scope
of the CIS roles directly satisfies IS-5.

**Linux**: `RedHatOfficial.rhel9_cis_server_l1` implements ~163 CIS RHEL 9 controls
(~68% of automatable CIS v3.0.0 recommendations). See [CIS RHEL 9 Coverage Report](CIS-RHEL9-Coverage-Report.md).

**Windows**: `windows_manage_cis` covers CIS Windows Server 2022 across 10 sections
(password, lockout, user rights, OS hardening, services, firewall, audit, crypto, network).
`windows_manage_stig` adds DISA STIG with stricter baselines.

---

#### IS-10: Synchronise Time Clocks (Level 1)

> "Synchronise internal clocks to a common reference time source."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 2.3.1 | `package_chrony_installed` | Ensures chrony is installed |
| 2.3.2 | `chronyd_specify_remote_server` | Configures NTP server list (`var_multiple_time_servers`) |
| 2.3.3 | `chronyd_run_as_chrony_user` | Runs chronyd as unprivileged user |

**Windows**: Neither CIS nor STIG role includes time synchronisation.
`infra.windows_ops` has a separate `windows_manage_time` role (not assessed here).

---

#### IS-9: End-of-Support Assets (Level 1)

> "Ensure deployed assets have not reached end-of-support (EOS)."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

No CIS/STIG role directly tracks EOS dates. However, the roles enforce package management
hygiene that supports EOS practices:

**Linux**: `ensure_gpgcheck_globally_activated`, `ensure_redhat_gpgkey_installed` — ensures
only signed, supported packages are installed.

**Windows STIG**: V-254352–V-254354 — disables AutoRun/AutoPlay to prevent unsigned software.

Tracking actual EOS dates requires inventory/CMDB integration outside CIS scope.

---

### AC — Access Control

#### AC-1: Principle of Least Privilege (Level 1)

> "Deny access by default and grant only the minimum permissions required
> for authorised accounts or processes to perform a specific function."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 5.4.2 | `accounts_no_uid_except_zero` | Only root has UID 0 |
| 5.4.1 | `no_password_auth_for_systemaccounts` | System accounts cannot log in with passwords |
| 5.4.1 | `no_shelllogin_for_systemaccounts` | System accounts have no interactive shell |
| 6.1.x | `file_permissions_*` (75+ toggles) | Restricts file/directory permissions |
| 4.3.6 | `ensure_pam_wheel_group_empty` | Only sugroup members can use `su` |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 2.2.x | 14 user rights assignments — limits who can act as OS, debug programs, log on locally/via RDP |
| 2.3.10.x | Blocks anonymous SID translation, SAM/share enumeration, null session fallback |

**Gap**: IM8 AC-1 is broader than host-level — covers application RBAC, cloud IAM policies.
CIS roles satisfy the OS-level component only.

---

#### AC-3: Inactive and Expired Accounts (Level 0 — mandatory)

> "Disable or remove accounts within [N] days of expiry or [N] days of inactivity."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | Default | What It Does |
|-----------|-----------------|---------|--------------|
| 5.6.1.4 | `account_disable_post_pw_expiration` | 45 days | `INACTIVE` in `/etc/default/useradd` |
| 5.6.1.1 | `accounts_maximum_age_login_defs` | 365 days | Max password age in `login.defs` |
| 5.6.1.1 | `accounts_password_set_max_life_existing` | — | Applies max age to existing accounts |

**Windows — `windows_manage_cis`:**

| CIS Rule | Default | What It Does |
|-----------|---------|--------------|
| 1.1.2 | 365 days | Maximum password age |

**Windows — `windows_manage_stig`:**

| STIG Rule | Default | What It Does |
|-----------|---------|--------------|
| V-254239 | 60 days | Maximum password age (stricter) |

---

#### AC-5: Endpoint Device Hardening (Level 0 — mandatory)

> "Require hardened endpoint devices for remote developer, maintainer, or administrator access."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

The CIS/STIG roles harden the endpoint OS itself — they satisfy the "hardened endpoint" requirement
when applied to admin workstations or jump hosts. However, IM8 AC-5 also implies endpoint management
(MDM, compliance checks before granting access) which is outside CIS scope.

**Linux**: Full CIS L1 profile applied to admin workstations satisfies the hardening component.

**Windows**: CIS + STIG roles together provide comprehensive workstation hardening (UAC, credential
guard, PowerShell execution policy, screensaver lock, logon banners).

---

#### AC-6: Default Credentials (Level 0 — mandatory)

> "Change default credentials prior to first use."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 5.5.3 | `no_empty_passwords` | Denies login with empty passwords in PAM |
| 5.5.3 | `no_empty_passwords_etc_shadow` | Locks accounts with empty password fields |
| 5.2.6 | `sshd_disable_empty_passwords` | Rejects empty passwords over SSH |

**Windows — `windows_manage_cis`:**

| CIS Rule | What It Does |
|-----------|--------------|
| 2.3.1.1 | Disables built-in Guest account |
| 2.3.1.5 | Renames default Administrator account |
| 1.1.6 | Disables storing passwords with reversible encryption |

**Windows — `windows_manage_stig`:**

| STIG Rule | What It Does |
|-----------|--------------|
| V-254446 | Blank password prevention (CAT I) |

---

#### AC-13: Static Credential Expiry and Rotation (Level 2)

> "Rotate long-lived credentials like API keys every [N] days or use time-restricted credentials."

| Coverage | Status |
|----------|--------|
| **Overall** | **Not Addressed** |

CIS/STIG roles enforce password rotation (password max age, history) but do not manage
API keys, service account tokens, or other static credentials. IM8 AC-13 targets application-layer
and cloud IAM credentials which require credential management tooling (Vault, AWS STS, etc.).

---

### LM — Logging & Monitoring

#### LM-4: Audit Logging (Level 0 — mandatory)

> "Log management and audit events."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 6.3.1 | `package_aide_installed` | Installs AIDE file integrity monitoring |
| 6.3.2 | `aide_build_database` | Builds initial AIDE database |
| 6.3.3 | `aide_periodic_cron_checking` | Schedules periodic AIDE checks |
| 6.3.4 | `aide_check_audit_tools` | Verifies integrity of audit binaries |

**Gap**: The CIS v3.0.0 auditd section (6.2.x — 50 controls covering syscall auditing,
log file permissions, audit rules) has **zero coverage** in the RedHatOfficial role.
This is the largest gap in the CIS coverage report.

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 17.x | 30+ advanced audit policy subcategories: credential validation, account management, logon/logoff, privilege use, process creation, file share access, policy changes, system integrity |
| 18.9.27.x | Event log sizing: Application 32MB, Security 192MB, System 32MB |

**Windows — `windows_manage_stig`:**

| STIG Section | What It Does |
|-------------|--------------|
| V-254247–V-254258 | 8 audit categories: credential validation, account management, directory service, logon events, object access, policy change, privilege use, system events |
| V-254358–V-254360 | Event log sizes matching CIS |

---

#### LM-7: Host Security Event Logging (Level 1)

> "Log security events on hosts. Include OS security events, authentication, EDR alerts,
> configuration changes, account/access rights changes."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 6.1.1 | `service_systemd_journald_enabled` | Ensures journald is running |
| 6.1.2 | `journald_compress` | Compresses journal logs |
| 6.1.3 | `journald_storage` | Persists journal to disk |
| 6.1.x | `rsyslog_files_permissions`, `rsyslog_files_ownership`, `rsyslog_files_groupownership` | Secures rsyslog file permissions |

**Gap**: No auditd rule configuration in the role — means authentication events, file access,
privilege escalation, and configuration changes are **not logged** by the role.

**Windows**: Both CIS and STIG roles fully cover host security event logging through advanced
audit policies (authentication success/failure, privilege use, process creation, policy changes).

---

#### LM-8: Security Log Retention (Level 1)

> "Retain security logs for at least [N] days."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 6.1.3 | `journald_storage` | Persists logs to disk (prerequisite for retention) |

Log retention period is configured via `journald.conf` (`MaxRetentionSec`) or rsyslog
logrotate — the role ensures persistence but retention duration is a deployment-time setting.

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 18.9.27.x | Configures event log maximum sizes: Application 32MB, Security 192MB, System 32MB |

**Windows — `windows_manage_stig`:**

| STIG Section | What It Does |
|-------------|--------------|
| V-254358–V-254360 | Same log sizing controls |

---

### NS — Network Security

#### NS-3: Deny by Default — Allow by Exception (Level 1)

> "Deny network communications traffic by default and allow network communications
> traffic by exception at managed interfaces."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 4.1.1 | `package_firewalld_installed` | Ensures firewalld is installed |
| 4.1.2 | `service_firewalld_enabled` | Enables firewalld service |
| 4.1.3 | `service_nftables_disabled` | Disables conflicting nftables service |
| 4.1.4 | `firewalld_loopback_traffic_restricted` | Restricts loopback traffic |
| 4.1.4 | `firewalld_loopback_traffic_trusted` | Trusts loopback interface only |
| 3.3.x | `sysctl_net_ipv4_conf_all_accept_redirects` (and 20+ sysctl toggles) | Hardens kernel network stack — disables source routing, redirects, IP forwarding |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 9.1.x–9.3.x | 15 firewall controls across Domain/Private/Public profiles: State=On, Inbound=Block, Outbound=Allow |

**Windows — `windows_manage_stig`:** No firewall controls (covered by CIS role only).

---

### DP — Data Protection

#### DP-2: Data at Rest Encryption (Level 1)

> "Encrypt data at rest."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

CIS/STIG roles do not configure full-disk encryption (LUKS, BitLocker) — that is typically
handled at provisioning time or via dedicated roles.

**Linux**: No coverage. LUKS setup is outside CIS role scope.

**Windows — `windows_manage_stig`:**

| STIG Rule | What It Does |
|-----------|--------------|
| (indirect) | Credential Guard enabled — protects credentials at rest in memory |

BitLocker enforcement requires Group Policy or a dedicated role.

---

#### DP-3: Data in Transit Encryption (Level 1)

> "Encrypt data in transit."

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 5.1.x | `configure_custom_crypto_policy_cis` | Sets system-wide crypto policy (TLS versions, cipher suites) |
| 5.2.x SSH | `sshd_set_loglevel_verbose`, `sshd_set_max_auth_tries`, `sshd_set_maxstartups`, etc. | Secures SSH transport (25+ toggles) |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 2.3.8.x | SMB signing required (client and server) |
| 2.3.6.x | Secure channel encryption and signing |
| 2.3.11.x | NTLMv2 with 128-bit encryption, Kerberos AES |
| 18.x | TLS 1.3 verification (Server 2022+), DNS-over-HTTPS |

**Windows — `windows_manage_stig`:**

| STIG Section | What It Does |
|-------------|--------------|
| V-254285–V-254295 | FIPS-compliant algorithms, TLS minimum 1.2, legacy TLS disabled, .NET strong cryptography |

---

### ST — Security Testing

#### ST-1: Vulnerability Assessment (Level 0 — mandatory)

> "Run regular vulnerability assessment scans for eligible hosts at least every [N] days."

| Coverage | Status |
|----------|--------|
| **Overall** | **Partially Satisfied** |

CIS roles do not perform vulnerability scanning. However, OpenSCAP (used by
`iamgini.compliance`) directly satisfies this control for Linux:

**Linux via `iamgini.compliance`:**
- `oscap_scan` role runs OpenSCAP assessments against CIS/STIG profiles
- Can be scheduled via AAP workflow templates for periodic scans
- Produces ARF/XCCDF reports with pass/fail per rule

**Windows**: No built-in scanning. Requires external tools (Microsoft Defender, Nessus, Qualys).

---

#### ST-5: Vulnerability Management (Level 1)

> "Triage, prioritize, then remediate or risk-accept vulnerabilities within timeframes by severity."

| Coverage | Status |
|----------|--------|
| **Overall** | **Not Addressed** |

Vulnerability management is a process control requiring ticketing, SLA tracking, and approval
workflows. CIS/STIG roles perform hardening (prevention) but do not track or triage
discovered vulnerabilities. AAP workflow templates with approval gates can support the
remediation portion of this control.

---

### CK — Cryptography & Key Management

#### CK-1: Cryptographic Key Establishment (Level 1)

> "Use industry-standard cryptographic key establishment schemes and key derivation methods."
> References NIST SP 800-56A/B/C.

| Coverage | Status |
|----------|--------|
| **Overall** | **Directly Satisfied** |

**Linux — RedHatOfficial CIS role:**

| CIS Rule | Toggle Variable | What It Does |
|-----------|-----------------|--------------|
| 5.1.1 | `configure_custom_crypto_policy_cis` | Enforces system-wide crypto policy with approved algorithms |
| 5.5.4 | `set_password_hashing_algorithm_logindefs` | SHA-512 password hashing |
| 5.5.4 | `set_password_hashing_algorithm_systemauth` | SHA-512 in PAM system-auth |

**Windows — `windows_manage_cis`:**

| CIS Section | What It Does |
|-------------|--------------|
| 2.3.6.x | Secure channel signing with strong session keys |
| 2.3.8.x | SMB signing with strong session keys |
| 2.3.11.x | Kerberos AES-only encryption, NTLMv2 128-bit |

**Windows — `windows_manage_stig`:**

| STIG Section | What It Does |
|-------------|--------------|
| V-254285–V-254295 | FIPS-compliant algorithms, .NET strong cryptography enforcement |

---

## Coverage Matrix

Quick-reference matrix — which role satisfies which IM8 control.

| IM8 Control | Low | Med | High | Linux CIS | Win CIS | Win STIG | Status |
|-------------|:---:|:---:|:----:|:---------:|:-------:|:--------:|--------|
| IS-3 Restricted Admin | L1 | L1 | L0 | Yes | Yes | Yes | Directly Satisfied |
| IS-4 Least Functionality | L1 | L1 | L1 | Yes | Yes | Yes | Directly Satisfied |
| IS-5 Host Hardening | L1 | L1 | L0 | Yes | Yes | Yes | Directly Satisfied |
| IS-9 EOS Assets | L1 | L1 | L1 | Partial | — | Partial | Partially Satisfied |
| IS-10 Time Sync | L1 | L1 | L1 | Yes | — | — | Partially Satisfied |
| AC-1 Least Privilege | L1 | L1 | L0 | Yes | Yes | Yes | Partially Satisfied |
| AC-3 Inactive Accounts | L1 | L0 | L0 | Yes | Yes | Yes | Directly Satisfied |
| AC-5 Endpoint Hardening | L1 | L0 | L0 | Yes | Yes | Yes | Partially Satisfied |
| AC-6 Default Credentials | L1 | L0 | L0 | Yes | Yes | Yes | Directly Satisfied |
| AC-13 Credential Rotation | L2 | L2 | L1 | — | — | — | Not Addressed |
| LM-4 Audit Logging | L1 | L0 | L0 | Partial | Yes | Yes | Partially Satisfied |
| LM-7 Host Event Logging | L1 | L1 | L0 | Partial | Yes | Yes | Partially Satisfied |
| LM-8 Log Retention | L1 | L1 | L0 | Partial | Yes | Yes | Directly Satisfied |
| NS-3 Deny by Default | L1 | L1 | L1 | Yes | Yes | — | Directly Satisfied |
| DP-2 Data at Rest Encryption | L1 | L1 | L1 | — | — | Partial | Partially Satisfied |
| DP-3 Data in Transit Encryption | L1 | L1 | L1 | Yes | Yes | Yes | Directly Satisfied |
| ST-1 Vulnerability Assessment | L1 | L0 | L0 | Via OpenSCAP | — | — | Partially Satisfied |
| ST-5 Vulnerability Management | L1 | L1 | L0 | — | — | — | Not Addressed |
| CK-1 Crypto Key Establishment | L2 | L1 | — | Yes | Yes | Yes | Directly Satisfied |

Profile levels: **L0** = mandatory, **L1** = hygiene (should-have), **L2** = best practice (good-to-have).

## Key Gaps

1. **Linux auditd** — 50 CIS v3.0.0 controls (section 6.2) have zero coverage in the
   RedHatOfficial role. This impacts LM-4 and LM-7 for Linux hosts.

2. **Full-disk encryption** — Neither CIS nor STIG roles configure LUKS or BitLocker.
   DP-2 requires separate provisioning-time or dedicated-role automation.

3. **API credential rotation** — AC-13 targets cloud/application credentials, outside OS
   hardening scope entirely.

4. **Vulnerability management process** — ST-5 is a process control (SLA tracking, triage,
   approval) not satisfiable by hardening roles alone.

5. **Windows time sync** — Covered by `infra.windows_ops.windows_manage_time` (not assessed),
   not by the CIS/STIG roles.

## References

- [Singapore IM8 Control Catalog](https://info.standards.tech.gov.sg/control-catalog/)
- [IM8 OSCAL Repository](https://github.com/GovTechSG/tech-standards)
- [CIS RHEL 9 Coverage Report](CIS-RHEL9-Coverage-Report.md)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [infra.windows_ops](https://github.com/redhat-cop/infra.windows_ops)
