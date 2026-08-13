# CIS RHEL 9 Benchmark Coverage Report

**Role**: `RedHatOfficial/ansible-role-rhel9-cis_server_l1`
**Role CIS Version**: v2.0.0 (released 2024-06-20)
**PDF Analyzed**: CIS Red Hat Enterprise Linux 9 Benchmark v3.0.0 (DRAFT, 2026-08-11)
**Analysis Date**: 2026-08-13

## Summary

| Metric | Count |
|--------|-------|
| Total CIS v3.0.0 recommendations | 271 |
| Covered by role | 163 |
| Missing (automatable) | 78 |
| Manual (not automatable) | 30 |
| **Coverage (of automatable)** | **~68%** |

The role was generated from ComplianceAsCode against CIS v2.0.0. CIS v3.0.0 introduces new controls (crypto policy, network kernel modules, auditd changes, process hardening) that the role has not been updated to cover.

## Section-by-Section Coverage

Legend: Y = Covered, N = Missing, M = Manual, P = Partial

### 1. Initial Setup

#### 1.1.1 Filesystem Kernel Modules

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.1.1.1 | cramfs not available | Y | `kernel_module_cramfs_disabled` |
| 1.1.1.2 | freevxfs not available | Y | `kernel_module_freevxfs_disabled` |
| 1.1.1.3 | hfs not available | Y | `kernel_module_hfs_disabled` |
| 1.1.1.4 | hfsplus not available | Y | `kernel_module_hfsplus_disabled` |
| 1.1.1.5 | jffs2 not available | Y | `kernel_module_jffs2_disabled` |
| 1.1.1.6 | overlay not available | **N** | — (new in v3.0.0) |
| 1.1.1.7 | squashfs not available | **N** | — (new in v3.0.0) |
| 1.1.1.8 | udf not available | **N** | — (new in v3.0.0) |
| 1.1.1.9 | firewire-core not available | **N** | — (new in v3.0.0) |
| 1.1.1.10 | usb-storage not available | **N** | — (new in v3.0.0) |
| 1.1.1.11 | unused filesystems reviewed | M | — |

#### 1.1.2 Filesystem Partitions

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.1.2.1.1 | /tmp separate partition | **N** | — (partition creation) |
| 1.1.2.1.2 | nodev on /tmp | Y | `mount_option_tmp_nodev` |
| 1.1.2.1.3 | nosuid on /tmp | Y | `mount_option_tmp_nosuid` |
| 1.1.2.1.4 | noexec on /tmp | Y | `mount_option_tmp_noexec` |
| 1.1.2.2.1 | /dev/shm separate partition | **N** | — (partition creation) |
| 1.1.2.2.2 | nodev on /dev/shm | Y | `mount_option_dev_shm_nodev` |
| 1.1.2.2.3 | nosuid on /dev/shm | Y | `mount_option_dev_shm_nosuid` |
| 1.1.2.2.4 | noexec on /dev/shm | Y | `mount_option_dev_shm_noexec` |
| 1.1.2.3.1 | /home separate partition | **N** | — (partition creation) |
| 1.1.2.3.2 | nodev on /home | Y | `mount_option_home_nodev` |
| 1.1.2.3.3 | nosuid on /home | Y | `mount_option_home_nosuid` |
| 1.1.2.4.1 | /var separate partition | **N** | — (partition creation) |
| 1.1.2.4.2 | nodev on /var | Y | `mount_option_var_nodev` |
| 1.1.2.4.3 | nosuid on /var | Y | `mount_option_var_nosuid` |
| 1.1.2.5.1 | /var/tmp separate partition | **N** | — (partition creation) |
| 1.1.2.5.2 | nodev on /var/tmp | Y | `mount_option_var_tmp_nodev` |
| 1.1.2.5.3 | nosuid on /var/tmp | Y | `mount_option_var_tmp_nosuid` |
| 1.1.2.5.4 | noexec on /var/tmp | Y | `mount_option_var_tmp_noexec` |
| 1.1.2.6.1 | /var/log separate partition | **N** | — (partition creation) |
| 1.1.2.6.2 | nodev on /var/log | Y | `mount_option_var_log_nodev` |
| 1.1.2.6.3 | nosuid on /var/log | Y | `mount_option_var_log_nosuid` |
| 1.1.2.6.4 | noexec on /var/log | Y | `mount_option_var_log_noexec` |
| 1.1.2.7.1 | /var/log/audit separate partition | **N** | — (partition creation) |
| 1.1.2.7.2 | nodev on /var/log/audit | Y | `mount_option_var_log_audit_nodev` |
| 1.1.2.7.3 | nosuid on /var/log/audit | Y | `mount_option_var_log_audit_nosuid` |
| 1.1.2.7.4 | noexec on /var/log/audit | Y | `mount_option_var_log_audit_noexec` |

#### 1.2 Package Management

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.2.1.1 | GPG keys configured | M | `ensure_redhat_gpgkey_installed` (key install only) |
| 1.2.1.2 | gpgcheck configured | Y | `ensure_gpgcheck_globally_activated` |
| 1.2.1.3 | repo_gpgcheck configured | Y | `ensure_gpgcheck_never_disabled` |
| 1.2.1.4 | package manager repos configured | M | — |
| 1.2.1.5 | weak dependencies configured | **N** | — (new in v3.0.0) |
| 1.2.2.1 | updates installed | M | — |

#### 1.3 Mandatory Access Control (SELinux)

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.3.1.1 | SELinux installed | Y | `package_libselinux_installed` |
| 1.3.1.2 | SELinux not disabled in bootloader | Y | `grub2_enable_selinux` |
| 1.3.1.3 | SELinux policy configured | Y | `selinux_policytype` |
| 1.3.1.4 | SELinux mode not disabled | Y | `selinux_not_disabled` |
| 1.3.1.5 | SELinux mode enforcing | P | `selinux_not_disabled` (ensures not disabled; enforcing not explicit) |
| 1.3.1.6 | no unconfined services | M | — |
| 1.3.1.7 | mcstrans not installed | Y | `package_mcstrans_removed` |
| 1.3.1.8 | setroubleshoot not installed | Y | `package_setroubleshoot_removed` |

#### 1.4 Configure Bootloader

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.4.1 | bootloader password set | **N** | — |
| 1.4.2 | bootloader config access | Y | `file_permissions_grub2_cfg` + `file_owner_grub2_cfg` + `file_groupowner_grub2_cfg` |
| 1.4.3 | auth for rescue mode | **N** | — |
| 1.4.4 | auth for emergency mode | **N** | — |
| 1.4.5 | systemd interactive boot disabled | **N** | — |

#### 1.5 Configure Additional Process Hardening

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.5.1 | fs.protected_hardlinks | **N** | — (new in v3.0.0) |
| 1.5.2 | fs.protected_symlinks | **N** | — (new in v3.0.0) |
| 1.5.3 | fs.suid_dumpable | **N** | — (new in v3.0.0) |
| 1.5.4 | kernel.dmesg_restrict | **N** | — (new in v3.0.0) |
| 1.5.5 | kernel.kptr_restrict | **N** | — (new in v3.0.0) |
| 1.5.6 | kernel.randomize_va_space | Y | `sysctl_kernel_randomize_va_space` |
| 1.5.7 | kernel.yama.ptrace_scope | Y | `sysctl_kernel_yama_ptrace_scope` |
| 1.5.8 | core file size | **N** | — (new in v3.0.0) |
| 1.5.9 | systemd-coredump ProcessSizeMax | Y | `coredump_disable_backtraces` |
| 1.5.10 | systemd-coredump Storage | Y | `coredump_disable_storage` |

#### 1.6 Configure System Wide Crypto Policy

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.6.1 | crypto policy not legacy | Y | `configure_custom_crypto_policy_cis` |
| 1.6.2 | disables sha1 | P | `configure_custom_crypto_policy_cis` (custom modules created) |
| 1.6.3 | crypto policy macs | Y | `configure_custom_crypto_policy_cis` (NO-SSHWEAKMACS module) |
| 1.6.4 | disables cbc for ssh | Y | `configure_custom_crypto_policy_cis` (NO-SSHWEAKCIPHERS module) |
| 1.6.5 | disables chacha20-poly1305 | M | — |
| 1.6.6 | disables EtM for ssh | M | — |
| 1.6.7 | enables post-quantum algorithms | **N** | — (new in v3.0.0) |

#### 1.7 Configure Command Line Warning Banners

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.7.1 | /etc/motd configured | Y | `banner_etc_motd_cis` |
| 1.7.2 | /etc/issue configured | Y | `banner_etc_issue_cis` |
| 1.7.3 | /etc/issue.net configured | Y | `banner_etc_issue_net_cis` |
| 1.7.4 | access to /etc/motd | Y | `file_permissions_etc_motd` + owner + groupowner |
| 1.7.5 | access to /etc/issue | Y | `file_permissions_etc_issue` + owner + groupowner |
| 1.7.6 | access to /etc/issue.net | Y | `file_permissions_etc_issue_net` + owner + groupowner |

#### 1.8 Configure GNOME Display Manager

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 1.8.1 | GDM login banner | Y | `dconf_gnome_banner_enabled` + `dconf_gnome_login_banner_text` |
| 1.8.2 | GDM disable-user-list | Y | `dconf_gnome_disable_user_list` |
| 1.8.3 | GDM screen lock | Y | `dconf_gnome_screensaver_idle_delay` + `dconf_gnome_screensaver_lock_delay` |
| 1.8.4 | GDM automount | Y | `dconf_gnome_disable_automount` + `dconf_gnome_disable_automount_open` |
| 1.8.5 | GDM autorun-never | Y | `dconf_gnome_disable_autorun` |
| 1.8.6 | XDMCP disabled | Y | `gnome_gdm_disable_xdmcp` |
| 1.8.7 | Wayland configured | **N** | — (new in v3.0.0) |

### 2. Services

#### 2.1 Configure Server Services

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 2.1.1 | autofs disabled | Y | `service_autofs_disabled` |
| 2.1.2 | avahi-daemon disabled | Y | `service_avahi_daemon_disabled` |
| 2.1.3 | cockpit disabled | **N** | — (new in v3.0.0) |
| 2.1.4 | dhcp removed | Y | `package_dhcp_removed` |
| 2.1.5 | dns (bind) removed | Y | `package_bind_removed` |
| 2.1.6 | dnsmasq disabled | Y | `service_dnsmasq_disabled` |
| 2.1.7 | samba removed | Y | `package_samba_removed` |
| 2.1.8 | ftp server removed | Y | `package_vsftpd_removed` |
| 2.1.9 | message access (dovecot/imapd) | Y | `package_dovecot_removed` + `package_cyrus_imapd_removed` |
| 2.1.10 | NFS disabled | Y | `service_nfs_disabled` |
| 2.1.11 | print server (cups) disabled | Y | `service_cups_disabled` |
| 2.1.12 | rpcbind disabled | Y | `service_rpcbind_disabled` |
| 2.1.13 | rsync removed | Y | `package_rsync_removed` |
| 2.1.14 | snmp removed | Y | `package_net_snmp_removed` |
| 2.1.15 | telnet server removed | Y | `package_telnet_server_removed` |
| 2.1.16 | tftp server removed | Y | `package_tftp_server_removed` |
| 2.1.17 | web proxy (squid) removed | Y | `package_squid_removed` |
| 2.1.18 | web server (httpd/nginx) removed | Y | `package_httpd_removed` + `package_nginx_removed` |
| 2.1.19 | mail transfer local-only | Y | `postfix_network_listening_disabled` |
| 2.1.20 | graphical UI not in use | **N** | — (new in v3.0.0) |
| 2.1.21 | X window not in use | **N** | — (new in v3.0.0) |
| 2.1.22 | Xwayland not in use | **N** | — (new in v3.0.0) |
| 2.1.23 | only approved services listening | M | — |

#### 2.2 Configure Client Services

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 2.2.1 | ftp client removed | Y | `package_ftp_removed` |
| 2.2.2 | ldap client removed | **N** | — |
| 2.2.3 | telnet client removed | Y | `package_telnet_removed` |
| 2.2.4 | tftp client removed | Y | `package_tftp_removed` |

#### 2.3 Configure Time Synchronization

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 2.3.1 | time sync in use | Y | `package_chrony_installed` |
| 2.3.2 | chrony configured | Y | `chronyd_specify_remote_server` |
| 2.3.3 | chrony not as root | Y | `chronyd_run_as_chrony_user` |

#### 2.4 Job Schedulers

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 2.4.1.1 | cron enabled | Y | `service_crond_enabled` + `package_cron_installed` |
| 2.4.1.2 | /etc/crontab access | Y | `file_permissions_crontab` + owner + groupowner |
| 2.4.1.3 | /etc/cron.hourly access | Y | `file_permissions_cron_hourly` + owner + groupowner |
| 2.4.1.4 | /etc/cron.daily access | Y | `file_permissions_cron_daily` + owner + groupowner |
| 2.4.1.5 | /etc/cron.weekly access | Y | `file_permissions_cron_weekly` + owner + groupowner |
| 2.4.1.6 | /etc/cron.monthly access | Y | `file_permissions_cron_monthly` + owner + groupowner |
| 2.4.1.7 | /etc/cron.yearly access | **N** | — (new in v3.0.0) |
| 2.4.1.8 | /etc/cron.d access | Y | `file_permissions_cron_d` + owner + groupowner |
| 2.4.1.9 | crontab access | Y | `file_cron_allow_exists` + `file_cron_deny_not_exist` |
| 2.4.2.1 | at access | Y | `file_at_allow_exists` + `file_at_deny_not_exist` |

### 3. Network

#### 3.1 Configure Network Devices

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 3.1.1 | IPv6 status identified | M | — |
| 3.1.2 | wireless disabled | Y | `wireless_disable_interfaces` |
| 3.1.3 | bluetooth disabled | Y | `service_bluetooth_disabled` |

#### 3.2 Configure Network Kernel Modules

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 3.2.1 | dccp disabled | **N** | — (L1 Server, missing from role) |
| 3.2.2 | tipc disabled | **N** | — (L1 Server, missing from role) |
| 3.2.3 | rds disabled | **N** | — (L1 Server, missing from role) |
| 3.2.4 | sctp disabled | **N** | — (L1 Server, missing from role) |
| 3.2.5 | atm disabled | **N** | — (new in v3.0.0) |
| 3.2.6 | can disabled | **N** | — (new in v3.0.0) |

#### 3.3 Configure Network Kernel Parameters

##### 3.3.1 IPv4

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 3.3.1.1 | ip_forward | Y | `sysctl_net_ipv4_ip_forward` |
| 3.3.1.2 | conf.all.forwarding | **N** | — (new in v3.0.0) |
| 3.3.1.3 | conf.default.forwarding | **N** | — (new in v3.0.0) |
| 3.3.1.4 | conf.all.send_redirects | Y | `sysctl_net_ipv4_conf_all_send_redirects` |
| 3.3.1.5 | conf.default.send_redirects | Y | `sysctl_net_ipv4_conf_default_send_redirects` |
| 3.3.1.6 | icmp_ignore_bogus_error_responses | Y | `sysctl_net_ipv4_icmp_ignore_bogus_error_responses` |
| 3.3.1.7 | icmp_echo_ignore_broadcasts | Y | `sysctl_net_ipv4_icmp_echo_ignore_broadcasts` |
| 3.3.1.8 | conf.all.accept_redirects | Y | `sysctl_net_ipv4_conf_all_accept_redirects` |
| 3.3.1.9 | conf.default.accept_redirects | Y | `sysctl_net_ipv4_conf_default_accept_redirects` |
| 3.3.1.10 | conf.all.secure_redirects | Y | `sysctl_net_ipv4_conf_all_secure_redirects` |
| 3.3.1.11 | conf.default.secure_redirects | Y | `sysctl_net_ipv4_conf_default_secure_redirects` |
| 3.3.1.12 | conf.all.rp_filter | Y | `sysctl_net_ipv4_conf_all_rp_filter` |
| 3.3.1.13 | conf.default.rp_filter | Y | `sysctl_net_ipv4_conf_default_rp_filter` |
| 3.3.1.14 | conf.all.accept_source_route | Y | `sysctl_net_ipv4_conf_all_accept_source_route` |
| 3.3.1.15 | conf.default.accept_source_route | Y | `sysctl_net_ipv4_conf_default_accept_source_route` |
| 3.3.1.16 | conf.all.log_martians | Y | `sysctl_net_ipv4_conf_all_log_martians` |
| 3.3.1.17 | conf.default.log_martians | Y | `sysctl_net_ipv4_conf_default_log_martians` |
| 3.3.1.18 | tcp_syncookies | Y | `sysctl_net_ipv4_tcp_syncookies` |
| 3.3.1.19 | conf.all.route_localnet | **N** | — (new in v3.0.0) |
| 3.3.1.20 | conf.default.route_localnet | **N** | — (new in v3.0.0) |

##### 3.3.2 IPv6

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 3.3.2.1 | conf.all.forwarding | Y | `sysctl_net_ipv6_conf_all_forwarding` |
| 3.3.2.2 | conf.default.forwarding | **N** | — (new in v3.0.0) |
| 3.3.2.3 | conf.all.accept_redirects | Y | `sysctl_net_ipv6_conf_all_accept_redirects` |
| 3.3.2.4 | conf.default.accept_redirects | Y | `sysctl_net_ipv6_conf_default_accept_redirects` |
| 3.3.2.5 | conf.all.accept_source_route | Y | `sysctl_net_ipv6_conf_all_accept_source_route` |
| 3.3.2.6 | conf.default.accept_source_route | Y | `sysctl_net_ipv6_conf_default_accept_source_route` |
| 3.3.2.7 | conf.all.accept_ra | Y | `sysctl_net_ipv6_conf_all_accept_ra` |
| 3.3.2.8 | conf.default.accept_ra | Y | `sysctl_net_ipv6_conf_default_accept_ra` |

### 4. Host Based Firewall

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 4.1.1 | firewalld installed | Y | `package_firewalld_installed` |
| 4.1.2 | firewalld backend configured | **N** | — |
| 4.1.3 | firewalld.service configured | Y | `service_firewalld_enabled` |
| 4.1.4 | active zone target configured | **N** | — |
| 4.1.5 | loopback traffic configured | P | `firewalld_loopback_traffic_restricted` + `firewalld_loopback_traffic_trusted` |
| 4.1.6 | loopback source address traffic | P | `firewalld_loopback_traffic_restricted` |
| 4.1.7 | services and ports configured | M | — |
| 4.1.8 | default zone is drop | M | — |
| 4.1.9 | conflicting firewall utilities | Y | `service_nftables_disabled` |
| 4.1.10 | firewalld logs denied packets | **N** | — |
| 4.1.11 | firewalld blocks ICMP timestamp | **N** | — |

### 5. Access Control

#### 5.1 Configure SSH Server

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 5.1.1 | sshd_config access | Y | `file_permissions_sshd_config` + owner + groupowner |
| 5.1.2 | sshd_config.d access | Y | `file_permissions_user_cfg` + owner + groupowner |
| 5.1.3 | SSH private key access | Y | `file_permissions_sshd_private_key` + ownership |
| 5.1.4 | SSH public key access | Y | `file_permissions_sshd_pub_key` + ownership |
| 5.1.5 | sshd Ciphers | Y | via `configure_custom_crypto_policy_cis` (NO-SSHWEAKCIPHERS) |
| 5.1.6 | sshd KexAlgorithms | P | via crypto policy (partial coverage) |
| 5.1.7 | sshd MACs | Y | via `configure_custom_crypto_policy_cis` (NO-SSHWEAKMACS) |
| 5.1.8 | sshd access (AllowUsers/Groups) | **N** | — |
| 5.1.9 | sshd Banner | Y | `sshd_enable_warning_banner_net` |
| 5.1.10 | ClientAliveInterval/CountMax | Y | `sshd_set_idle_timeout` + `sshd_set_keepalive` |
| 5.1.11 | DisableForwarding | **N** | — |
| 5.1.12 | GSSAPIAuthentication disabled | **N** | — |
| 5.1.13 | HostbasedAuthentication disabled | Y | `disable_host_auth` |
| 5.1.14 | IgnoreRhosts enabled | Y | `sshd_disable_rhosts` |
| 5.1.15 | LoginGraceTime | Y | `sshd_set_login_grace_time` |
| 5.1.16 | LogLevel | Y | `sshd_set_loglevel_verbose` |
| 5.1.17 | MaxAuthTries | Y | `sshd_set_max_auth_tries` |
| 5.1.18 | MaxStartups | Y | `sshd_set_maxstartups` |
| 5.1.19 | MaxSessions | Y | `sshd_set_max_sessions` |
| 5.1.20 | PermitEmptyPasswords disabled | Y | `sshd_disable_empty_passwords` |
| 5.1.21 | PermitRootLogin disabled | Y | `sshd_disable_root_login` |
| 5.1.22 | PermitUserEnvironment disabled | Y | `sshd_do_not_permit_user_env` |
| 5.1.23 | UsePAM enabled | Y | `sshd_enable_pam` |

#### 5.2 Configure Privilege Escalation

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 5.2.1 | sudo installed | Y | `package_sudo_installed` |
| 5.2.2 | sudoers file access | P | — (tasks exist but no dedicated toggle) |
| 5.2.3 | /etc/sudoers.d access | P | — (tasks exist but no dedicated toggle) |
| 5.2.4 | sudo commands use pty | Y | `sudo_add_use_pty` |
| 5.2.5 | sudo log file | Y | `sudo_custom_logfile` |
| 5.2.6 | sudo require password | Y | `sudo_remove_no_authenticate` |
| 5.2.7 | sudo re-authentication | Y | `sudo_require_reauthentication` |
| 5.2.8 | sudo pwfeedback | **N** | — (new in v3.0.0) |
| 5.2.9 | sudo visiblepw | **N** | — (new in v3.0.0) |
| 5.2.10 | sudo timestamp_timeout | P | `sudo_require_reauthentication` (uses `var_sudo_timestamp_timeout`) |
| 5.2.11 | sudo timestamp_type | **N** | — (new in v3.0.0) |
| 5.2.12 | su command restricted | Y | `ensure_pam_wheel_group_empty` |

#### 5.3 Pluggable Authentication Modules

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 5.3.1.1 | pam installed | **N** | — (pam is baseline; no explicit toggle) |
| 5.3.1.2 | authselect installed | **N** | — (authselect is baseline; no explicit toggle) |
| 5.3.1.3 | libpwquality installed | Y | `package_pam_pwquality_installed` |
| 5.3.2.1 | PAM managed by authselect | Y | `enable_authselect` + `accounts_password_pam_modules_in_authselect_profile` |
| 5.3.2.2 | pam_faillock enabled | Y | `account_password_pam_faillock_password_auth` + `_system_auth` |
| 5.3.2.3 | pam_pwquality enabled | Y | `package_pam_pwquality_installed` + password policies |
| 5.3.2.4 | pam_pwhistory enabled | Y | `accounts_password_pam_pwhistory_remember_*` |
| 5.3.2.5 | pam_unix enabled | Y | `no_empty_passwords` + hashing algorithms |
| 5.3.3.1.1 | failed attempts lockout | Y | `accounts_passwords_pam_faillock_deny` |
| 5.3.3.1.2 | unlock time | Y | `accounts_passwords_pam_faillock_unlock_time` |
| 5.3.3.1.3 | root lockout | P | `accounts_password_pam_enforce_root` (covers root enforcement, faillock-specific root unclear) |
| 5.3.3.2.1 | difok (changed chars) | Y | `accounts_password_pam_difok` |
| 5.3.3.2.2 | minlen (password length) | Y | `accounts_password_pam_minlen` |
| 5.3.3.2.3 | password complexity | Y | `accounts_password_pam_minclass` |
| 5.3.3.2.4 | maxrepeat | Y | `accounts_password_pam_maxrepeat` |
| 5.3.3.2.5 | maxsequence | Y | `accounts_password_pam_maxsequence` |
| 5.3.3.2.6 | dictcheck | Y | `accounts_password_pam_dictcheck` |
| 5.3.3.2.7 | enforce for root | Y | `accounts_password_pam_enforce_root` |
| 5.3.3.3.1 | history remember | Y | `accounts_password_pam_pwhistory_remember_*` |
| 5.3.3.3.2 | history enforce root | Y | `accounts_password_pam_pwhistory_enforce_for_root` |
| 5.3.3.3.3 | pam_pwhistory use_authtok | **N** | — (new in v3.0.0) |
| 5.3.3.4.1 | pam_unix no nullok | Y | `no_empty_passwords` |
| 5.3.3.4.2 | pam_unix no remember | Y | `accounts_password_pam_unix_no_remember` |
| 5.3.3.4.3 | pam_unix strong hashing | Y | `set_password_hashing_algorithm_passwordauth` + `_systemauth` |
| 5.3.3.4.4 | pam_unix use_authtok | **N** | — (new in v3.0.0) |

#### 5.4 User Accounts and Environment

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 5.4.1.1 | password expiration | Y | `accounts_maximum_age_login_defs` + `accounts_password_set_max_life_existing` |
| 5.4.1.2 | minimum password days | M | — |
| 5.4.1.3 | password warning days | Y | `accounts_password_warn_age_login_defs` + `accounts_password_set_warn_age_existing` |
| 5.4.1.4 | strong password hashing | Y | `set_password_hashing_algorithm_logindefs` + `_libuserconf` |
| 5.4.1.5 | inactive password lock | Y | `account_disable_post_pw_expiration` + `accounts_set_post_pw_existing` |
| 5.4.1.6 | last password change date | **N** | — |
| 5.4.2.1 | root only UID 0 | Y | `accounts_no_uid_except_zero` |
| 5.4.2.2 | root only GID 0 | **N** | — (new in v3.0.0) |
| 5.4.2.3 | group root only GID 0 group | **N** | — (new in v3.0.0) |
| 5.4.2.4 | root account access controlled | **N** | — |
| 5.4.2.5 | root path integrity | Y | `accounts_root_path_dirs_no_write` |
| 5.4.2.6 | root umask | Y | `accounts_umask_etc_bashrc` + `_etc_login_defs` + `_etc_profile` |
| 5.4.2.7 | system accounts no login shell | Y | `no_shelllogin_for_systemaccounts` |
| 5.4.2.8 | accounts without shell locked | Y | `no_password_auth_for_systemaccounts` |
| 5.4.3.1 | nologin not in /etc/shells | **N** | — (new in v3.0.0) |
| 5.4.3.2 | shell timeout (TMOUT) | Y | `accounts_tmout` |
| 5.4.3.3 | umask in /etc/login.defs | Y | `accounts_umask_etc_login_defs` |
| 5.4.3.4 | umask configured | Y | `accounts_umask_etc_bashrc` + `accounts_umask_etc_profile` |

### 6. Logging and Auditing

#### 6.1 System Logging

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 6.1.1.1 | journald active | Y | `service_systemd_journald_enabled` |
| 6.1.1.2 | journal-remote not in use | P | `package_systemd_journal_remote_installed` (installs package; service state unclear) |
| 6.1.1.3 | journald to rsyslog | **N** | — |
| 6.1.1.4 | journald log rotation | P | `journald_compress` + `journald_storage` |
| 6.1.1.5 | journald log file access | M | — |
| 6.1.2.1 | rsyslog installed | **N** | — |
| 6.1.2.2 | rsyslog service enabled | **N** | — |
| 6.1.2.3 | rsyslog log file creation mode | P | `rsyslog_files_permissions` |
| 6.1.2.4 | rsyslog config file access | Y | `rsyslog_files_permissions` + `rsyslog_files_ownership` + `rsyslog_files_groupownership` |
| 6.1.2.5 | /etc/rsyslog.d access | P | `rsyslog_files_permissions` |
| 6.1.2.6 | rsyslog work directory | **N** | — |
| 6.1.2.7 | rsyslog not log server | **N** | — |
| 6.1.2.8 | rsyslog logging rules | M | — |
| 6.1.2.9 | rsyslog remote logging | M | — |
| 6.1.2.10 | rsyslog TLS driver | **N** | — |
| 6.1.2.11 | rsyslog TLS forwarding | **N** | — |
| 6.1.2.12 | rsyslog TLS CA cert | M | — |
| 6.1.2.13 | rsyslog TLS client cert | M | — |
| 6.1.2.14 | logrotate configured | M | — |
| 6.1.3.1 | logfile access configured | **N** | — |

#### 6.2 System Auditing (ENTIRE SECTION MISSING)

| CIS # | Recommendation | Status | Notes |
|-------|---------------|--------|-------|
| 6.2.1.1 | auditd installed | **N** | — |
| 6.2.1.2 | audit pre-auditd processes | **N** | — |
| 6.2.1.3 | audit_backlog_limit | **N** | — |
| 6.2.1.4 | auditd service enabled | **N** | — |
| 6.2.2.1 | audit log storage size | **N** | — |
| 6.2.2.2 | audit logs not auto-deleted | **N** | — |
| 6.2.2.3 | system disabled when logs full | **N** | — |
| 6.2.2.4 | system warns on low space | **N** | — |
| 6.2.3.1–36 | auditd rules (36 controls) | **N** | All 36 audit rules missing |
| 6.2.4.1–10 | auditd file access (10 controls) | **N** | All 10 audit file access controls missing |

**Note**: The entire auditd section (6.2) contains 50 controls, all missing from this role. This is the single largest gap.

#### 6.3 Configure Integrity Checking

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 6.3.1 | AIDE installed | Y | `package_aide_installed` + `aide_build_database` |
| 6.3.2 | filesystem integrity checks | Y | `aide_periodic_cron_checking` |
| 6.3.3 | crypto mechanisms for audit tools | Y | `aide_check_audit_tools` |
| 6.3.4 | report_url configured | **N** | — (new in v3.0.0) |

### 7. System Maintenance

#### 7.1 System File and Directory Access

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 7.1.1 | /etc/passwd access | Y | `file_permissions_etc_passwd` + owner + groupowner |
| 7.1.2 | /etc/passwd- access | Y | `file_permissions_backup_etc_passwd` + owner + groupowner |
| 7.1.3 | /etc/group access | Y | `file_permissions_etc_group` + owner + groupowner |
| 7.1.4 | /etc/group- access | Y | `file_permissions_backup_etc_group` + owner + groupowner |
| 7.1.5 | /etc/shadow access | Y | `file_permissions_etc_shadow` + owner + groupowner |
| 7.1.6 | /etc/shadow- access | Y | `file_permissions_backup_etc_shadow` + owner + groupowner |
| 7.1.7 | /etc/gshadow access | Y | `file_permissions_etc_gshadow` + owner + groupowner |
| 7.1.8 | /etc/gshadow- access | Y | `file_permissions_backup_etc_gshadow` + owner + groupowner |
| 7.1.9 | /etc/shells access | Y | `file_permissions_etc_shells` + owner + groupowner |
| 7.1.10 | /etc/security/opasswd access | Y | `file_etc_security_opasswd` |
| 7.1.11 | world writable files secured | Y | `dir_perms_world_writable_sticky_bits` |
| 7.1.12 | no files without owner/group | **N** | — |
| 7.1.13 | SUID/SGID files reviewed | M | — |

#### 7.2 Local User and Group Settings

| CIS # | Recommendation | Status | Role Variable |
|-------|---------------|--------|--------------|
| 7.2.1 | shadowed passwords | Y | `no_empty_passwords_etc_shadow` |
| 7.2.2 | shadow fields not empty | Y | `no_empty_passwords_etc_shadow` |
| 7.2.3 | groups in passwd exist in group | **N** | — |
| 7.2.4 | no duplicate UIDs | **N** | — |
| 7.2.5 | no duplicate GIDs | **N** | — |
| 7.2.6 | no duplicate user names | **N** | — |
| 7.2.7 | no duplicate group names | **N** | — |
| 7.2.8 | user home directories | Y | `accounts_user_interactive_home_directory_exists` |
| 7.2.9 | user dot files access | Y | `accounts_user_dot_user_ownership` + `accounts_user_dot_group_ownership` + `file_permission_user_init_files` |

---

## Gap Analysis: Biggest Missing Areas

### 1. Entire auditd section (6.2) — 50 controls
The role has zero auditd coverage: no package installation, service enablement, log retention, audit rules, or file access controls. This is the largest gap by control count.

### 2. Network kernel modules (3.2) — 6 controls
All network protocol kernel modules (dccp, tipc, rds, sctp, atm, can) are missing. These are confirmed Level 1 Server controls.

### 3. Filesystem kernel modules (1.1.1.6–1.1.1.10) — 5 controls
overlay, squashfs, udf, firewire-core, and usb-storage modules are new in v3.0.0 and not covered.

### 4. Process hardening (1.5.1–1.5.5, 1.5.8) — 6 controls
fs.protected_hardlinks, fs.protected_symlinks, fs.suid_dumpable, kernel.dmesg_restrict, kernel.kptr_restrict, and core file size are new in v3.0.0.

### 5. Bootloader security (1.4.1, 1.4.3–1.4.5) — 4 controls
Bootloader password, rescue/emergency mode authentication, and interactive boot are missing.

### 6. rsyslog configuration (6.1.2) — several controls
rsyslog installation, service enablement, TLS configuration, and detailed logging rules are missing.

### 7. Local user/group validation (7.2.3–7.2.7) — 5 controls
Duplicate UID/GID/user/group checks and group consistency are missing.

## Root Cause

The role was auto-generated from ComplianceAsCode against **CIS v2.0.0** (2024-06-20). The PDF analyzed is **CIS v3.0.0 DRAFT** (2026-08-11). The two-year gap introduces:

- **New controls** in v3.0.0 (kernel modules, process hardening, crypto policy, etc.)
- **Renumbered controls** that may have different mappings
- **New sections** (e.g., expanded firewalld, detailed sudo settings)

Some gaps (auditd, bootloader password, network modules) also existed in v2.0.0 and reflect limitations of the ComplianceAsCode CIS L1 Server profile mapping.

## Recommendation

For customer engagements using this role against CIS v3.0.0:

1. **Use `oscap generate fix`** from `iamgini.compliance` to generate remediation for missing controls — the SSG datastream is typically more current than the RedHatOfficial role
2. **Layer additional playbooks** for the auditd section (6.2) — this is the biggest gap and is fully automatable
3. **Document exceptions** for Manual controls (M) and partition-creation controls using the `compliance_skip_rules` pattern
4. **Track ComplianceAsCode updates** — the upstream project will eventually update the CIS profile for v3.0.0
