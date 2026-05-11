# Execution Environment Mode - Quick Reference

This project is configured to run **agentless compliance scanning** from an Execution Environment (EE) without installing OpenSCAP on target systems.

## How It Works

```
┌─────────────────────────────────────────────────────┐
│  Execution Environment (Container)                  │
│  ┌───────────────────────────────────────────────┐  │
│  │ • ansible-playbook                            │  │
│  │ • oscap-ssh (scans via SSH)                   │  │
│  │ • scap-security-guide (content)               │  │
│  │ • Results stored in /tmp/oscap_fetched/       │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
                      │
                      │ SSH (oscap-ssh)
                      ▼
         ┌────────────────────────┐
         │  Target System         │
         │  • No oscap installed  │
         │  • Just SSH access     │
         └────────────────────────┘
                      │
                      │ Results
                      ▼
         ┌────────────────────────┐
         │  Report Server         │
         │  • HTML/XML reports    │
         │  • Nginx hosting       │
         └────────────────────────┘
```

## Configuration

### Current Settings (group_vars/all.yml)

```yaml
# Scan from EE without installing on targets
execution_mode: "execution_environment"

# Generate fixes in EE (not on report server)
generate_fix_mode: "execution_environment"
```

## Build the EE

```bash
cd execution-environment/
ansible-builder build -t compliance-scanner-ee:latest
```

## Run Scans

### Option 1: With ansible-navigator (Development/Testing)

```bash
# Configure inventory first
cp hosts.ini.example hosts.ini
vim hosts.ini  # Add your target servers

# Run scan
ansible-navigator run playbooks/scan.yml \
  --eei compliance-scanner-ee:latest \
  -m stdout
```

### Option 2: With Ansible Automation Platform

1. Build and push EE to registry
2. Configure EE in AAP
3. Create job template using this EE
4. Run!

## What Happens During a Scan

1. **EE starts** with oscap-ssh and SCAP content already installed
2. **oscap-ssh connects** to target via SSH (uses ansible_user and ansible_host)
3. **Scan runs** remotely, reading system state via SSH
4. **Results saved** in EE at `/tmp/oscap_fetched/<hostname>/`
5. **Reports pushed** to report server
6. **HTML report** available at `http://<report-server>/reports/<customer_id>/<hostname>/<date>/`

## Requirements

### On Targets
- ✅ SSH access (that's it!)
- ❌ No oscap installation needed
- ❌ No scap-security-guide needed

### In the EE (already configured)
- ✅ openscap-scanner
- ✅ openscap-utils (includes oscap-ssh)
- ✅ scap-security-guide
- ✅ Python lxml

### On Report Server
- ✅ Nginx for hosting reports
- ✅ Write access to report directory

## Testing

### Test the EE Locally

```bash
# Build
ansible-builder build -t compliance-scanner-ee:test

# Verify contents
podman run -it --rm compliance-scanner-ee:test /bin/bash
[container]# oscap --version
[container]# oscap-ssh --help
[container]# ls /usr/share/xml/scap/ssg/content/
```

### Test Scanning Localhost

Edit `hosts.ini`:
```ini
[rhel9_cis_l2]
localhost ansible_connection=local
```

Run:
```bash
ansible-navigator run playbooks/scan.yml \
  --eei compliance-scanner-ee:latest \
  -m stdout
```

## Switching Modes

### Switch to Local Mode (install on targets)

Edit `group_vars/all.yml`:
```yaml
execution_mode: "local"
```

### Why Use EE Mode?
- ✅ No package installation on targets
- ✅ Consistent scanning environment
- ✅ Easier to update SCAP content (rebuild EE)
- ✅ Better for cloud/immutable infrastructure
- ✅ Works with AAP automation

### Why Use Local Mode?
- ✅ Targets can't be reached via SSH from EE
- ✅ Network segmentation requires local execution
- ✅ Testing/development without container infrastructure

## Troubleshooting

### "oscap-ssh: command not found"
- Rebuild EE: `ansible-builder build -t compliance-scanner-ee:latest`
- Verify: `openscap-utils` is in `execution-environment/bindep.txt`

### "SSH connection refused"
- Check `ansible_host` in inventory
- Test SSH manually: `ssh ansible_user@ansible_host`
- Verify SSH keys are configured

### "SCAP content not found"
- Check `ssg_datastream` path in `group_vars/all.yml`
- Verify in EE: `ls /usr/share/xml/scap/ssg/content/`

### "No hosts matched"
- Ensure `scan_targets` group exists in inventory
- Verify target hosts are defined
- Use `-e "target_hosts=rhel9_cis_l2"` to specify group

## Next Steps

1. ✅ Configure your inventory (`hosts.ini`)
2. ✅ Build the EE (`ansible-builder build`)
3. ✅ Set up report server (`ansible-playbook playbooks/setup_report_server.yml`)
4. ✅ Run your first scan!

For detailed documentation:
- EE building: [execution-environment/README.md](execution-environment/README.md)
- Quick start: [QUICKSTART.md](QUICKSTART.md)
- Full documentation: [README.md](README.md)
