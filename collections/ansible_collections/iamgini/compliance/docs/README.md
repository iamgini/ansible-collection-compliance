# Documentation Index

This directory contains detailed documentation for the `iamgini.compliance` collection.

## Available Documentation

### Core Guides

- **[Exception Management Guide](EXCEPTION_MANAGEMENT.md)** - Comprehensive guide for managing compliance exceptions
  - Creating and organizing exceptions
  - Real-world examples (nginx, PostgreSQL, Docker)
  - Finding rule IDs
  - Best practices and audit reporting

## Quick Links by Use Case

### I need to...

**Create exceptions for nginx web servers**
→ See [Exception Management Guide - nginx Examples](EXCEPTION_MANAGEMENT.md#nginx-web-server-exceptions)
- Group-level exceptions: `inventory/group_vars/nginx_servers.yml` (template included)
- Host-level exceptions: `inventory/host_vars/<hostname>.yml` (template included)

**Create exceptions for database servers**
→ See [Exception Management Guide - Database Examples](EXCEPTION_MANAGEMENT.md#database-server-exceptions)

**Create exceptions for container hosts**
→ See [Exception Management Guide - Container Examples](EXCEPTION_MANAGEMENT.md#container-host-exceptions)

**Find a specific rule ID**
→ See [Exception Management Guide - Finding Rule IDs](EXCEPTION_MANAGEMENT.md#finding-rule-ids)
- From scan report (easiest)
- From command line
- From SSG GitHub

**Understand exception approval process**
→ See [Exception Management Guide - Best Practices](EXCEPTION_MANAGEMENT.md#best-practices)

**Generate audit reports for exceptions**
→ See [Exception Management Guide - Audit and Reporting](EXCEPTION_MANAGEMENT.md#audit-and-reporting)

## Example Files

The collection includes working example files you can copy and modify:

```
collections/ansible_collections/iamgini/compliance/
├── inventory/
│   ├── group_vars/
│   │   ├── nginx_servers.yml          # Complete nginx exception template
│   │   ├── all.yml                     # Global defaults
│   │   ├── linux_cis_l1.yml           # CIS Level 1 profile
│   │   └── linux_cis_l2.yml           # CIS Level 2 profile
│   └── host_vars/
│       ├── nginx-prod-01.example.com.yml  # Detailed host-specific example
│       └── example-host.yml               # Generic host template
```

## Documentation Quick Reference

### Exception File Locations

| Location | Purpose | Scope |
|----------|---------|-------|
| `inventory/group_vars/<group>.yml` | Common exceptions for server type | All hosts in group |
| `inventory/host_vars/<hostname>.yml` | Host-specific exceptions | Single host |
| `inventory/group_vars/all.yml` | Global defaults | All hosts |

### Key Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `compliance_skip_rules` | List of rule IDs to skip | `["xccdf_org.ssgproject.content_rule_..."]` |
| `compliance_exception_reasons` | Justifications for exceptions | See templates |
| `compliance_var_overrides` | SSG variable overrides | `{"var_password_pam_minlen": "16"}` |

### Common Rule Categories

| Category | Example Rules | Typical Exceptions For |
|----------|---------------|------------------------|
| Services | `rule_service_*` | Web servers, databases, NFS |
| Network | `rule_sysctl_net_*` | Reverse proxies, load balancers |
| SELinux | `rule_sebool_*` | Web servers, container hosts |
| Firewall | `rule_firewalld_*` | Custom ports, services |
| SSH | `rule_sshd_*` | Deployment automation, jump hosts |

## Additional Resources

### External Documentation

- [Main README](../../../../../README.md) - Collection overview and quick start
- [ComplianceAsCode Project](https://github.com/ComplianceAsCode/content) - SSG content source
- [OpenSCAP Documentation](https://www.open-scap.org/resources/documentation/) - Scanner documentation
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/) - Security baseline standards

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/iamgini/ansible-collection-compliance/issues)
- **Discussions**: [GitHub Discussions](https://github.com/iamgini/ansible-collection-compliance/discussions)
- **Wiki**: [Project Wiki](https://github.com/iamgini/ansible-collection-compliance/wiki)

## Contributing to Documentation

Documentation improvements are welcome! When adding new documentation:

1. Add the new file to the `docs/` directory
2. Update this README.md index
3. Add cross-references from relevant existing docs
4. Include practical examples
5. Test all code examples before committing

## License

All documentation is licensed under Apache License 2.0, same as the collection code.
