# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - Unreleased

### Added
- OpenSCAP compliance scanning and remediation framework for Linux
- Roles: `oscap_scan`, `oscap_parse`, `oscap_generate_fix`, `report_server`, `exception_handler`
- Linux playbooks: `oscap_scan`, `oscap_parse`, `oscap_generate_fix`, `oscap_remediate`, `oscap_rescan`, `oscap_site`
- Windows CIS Benchmark hardening via `infra.windows_ops` (`windows_cis.yml`)
- Windows DISA STIG hardening via `infra.windows_ops` (`windows_stig.yml`)
- Exception handling at group and host levels with auditable documentation
- Report server with nginx-based HTML report serving
- Two generation modes: `report_server` and `execution_environment`
- Git-based remediation playbook storage (`commit_reports.yml`)
- Execution Environment definition with OpenSCAP and collection dependencies
- AAP Configuration-as-Code definitions (companion `ansible-aap-cac` repo)
