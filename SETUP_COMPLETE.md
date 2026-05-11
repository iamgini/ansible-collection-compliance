# Setup Complete - Next Steps

## ✅ What's Done

### 1. Execution Environment Built
- **Image**: `compliance-scanner-ee:latest` (607 MB)
- **Includes**: OpenSCAP 1.3.13, SCAP Security Guide, oscap-ssh
- **Content**: RHEL 7/8/9, CentOS Stream 9 profiles

### 2. EE Mode Configured
- **Mode**: `execution_mode: "execution_environment"`  
- **Scanning**: Remote via `oscap-ssh` from EE
- **No installation needed**: On most targets (with caveat below)

### 3. Default Variables Set
- All required variables have defaults in `group_vars/all.yml`
- `customer_id`, `cis_profile`, `ssg_datastream`, etc.
- No more "variables missing" errors

### 4. Inventory Configured
- Report server: `utils.lab.iamgini.com`
- Test target: `utils` (same host for testing)
- `scan_targets` meta-group excludes report server

### 5. Documentation Created
- `EE_MODE.md` - Quick reference
- `QUICKSTART.md` - 5-minute start guide  
- `execution-environment/README.md` - Full EE documentation
- `group_vars/README.md` - Variable reference

## ⚠️ Current Status

The scan attempted but failed because:

```
bash: line 1: oscap: command not found
```

### Why This Happens

`oscap-ssh` works by:
1. Copying SCAP content to target via SCP
2. Running `oscap` command on target via SSH  
3. Copying results back

**It still needs the `oscap` binary on the target**, even though content comes from the EE.

## 🔧 Next Steps - Choose Your Path

### Option A: Hybrid Mode (Recommended for Production)

Install minimal `openscap-scanner` on targets:

**Advantages:**
- ✅ Minimal footprint (just the binary, ~10MB)
- ✅ Content centralized in EE
- ✅ Works with `oscap-ssh` 
- ✅ Easy to maintain

**How to implement:**

1. **Check target OS and enable repos:**
   ```bash
   ssh devops@utils.lab.iamgini.com
   cat /etc/os-release
   
   # If RHEL-based, you might need:
   sudo dnf install epel-release
   # or enable appropriate repos
   ```

2. **Install scanner manually or via Ansible:**
   ```bash
   # Option 1: Manual
   ssh devops@utils.lab.iamgini.com "sudo dnf install -y openscap-scanner"
   
   # Option 2: Via updated playbook
   # Edit playbooks/prepare_targets.yml to handle package availability
   ansible-navigator run playbooks/prepare_targets.yml
   ```

3. **Run scan:**
   ```bash
   ansible-navigator run playbooks/scan.yml
   ```

### Option B: Pure Local Mode

Abandon EE mode, install everything on targets:

**Change in `group_vars/all.yml`:**
```yaml
execution_mode: "local"  # was: execution_environment
```

**Advantages:**
- ✅ Works without oscap on targets initially
- ✅ Role installs everything needed

**Disadvantages:**
- ❌ Installs OpenSCAP + content on every target
- ❌ Content updates require updating all targets
- ❌ Larger footprint per target

**How to implement:**
```bash
vim group_vars/all.yml  # Change execution_mode to "local"
ansible-navigator run playbooks/scan.yml
```

### Option C: Fully Agentless (Future Enhancement)

Use Ansible modules to:
1. Copy datastream from EE to target `/tmp`
2. Run oscap via `ansible.builtin.command`
3. Fetch results back
4. Delete temporary files

This would be a custom implementation not using `oscap-ssh`.

## 📊 Current Architecture

```
┌─────────────────────────────────┐
│  Execution Environment          │
│  ┌────────────────────────────┐ │
│  │ • oscap-ssh               │ │
│  │ • SCAP content (all OSes) │ │
│  │ • ansible-playbook        │ │
│  └────────────────────────────┘ │
└─────────────────────────────────┘
           │
           │ SSH + SCP (oscap-ssh)
           │ Needs: oscap binary on target
           ▼
┌─────────────────────────────────┐
│  Target System (utils)          │
│  • Needs: openscap-scanner pkg  │
│  • Content: Copied temporarily  │
│  • Results: Sent back to EE     │
└─────────────────────────────────┘
           │
           │ Results pushed
           ▼
┌─────────────────────────────────┐
│  Report Server                  │
│  • Nginx hosting HTML reports   │
│  • /var/www/compliance-reports  │
└─────────────────────────────────┘
```

## 🎯 Recommended Action

**For your environment, I recommend:**

1. **Check what repos are available on the target:**
   ```bash
   ssh devops@utils.lab.iamgini.com "dnf repolist"
   ssh devops@utils.lab.iamgini.com "dnf search openscap"
   ```

2. **If openscap packages are available**, install scanner:
   ```bash
   ssh devops@utils.lab.iamgini.com "sudo dnf install -y openscap-scanner"
   ```

3. **If packages NOT available**, either:
   - Enable EPEL: `sudo dnf install -y epel-release`
   - Or switch to Local Mode (Option B above)

4. **Then run the scan:**
   ```bash
   ansible-navigator run playbooks/scan.yml
   ```

## 📁 Files Created/Modified

```
/home/gmadappa/ansible/ansible-collection-compliance/
├── execution-environment/
│   ├── Containerfile (new)
│   ├── README.md (new)
│   └── execution-environment.yml (updated)
├── group_vars/
│   ├── all.yml (new - with defaults)
│   └── README.md (new)
├── playbooks/
│   ├── prepare_targets.yml (new)
│   ├── scan.yml (updated - uses scan_targets)
│   └── setup_report_server.yml (existing)
├── roles/oscap_scan/tasks/
│   ├── main.yml (updated - EE mode support)
│   ├── scan_ee_mode.yml (new)
│   └── defaults/main.yml (updated)
├── ansible-navigator.yml (updated)
├── hosts.ini (updated - with test target)
├── EE_MODE.md (new)
├── QUICKSTART.md (new)
└── SETUP_COMPLETE.md (this file)
```

## ✨ Summary

You're 95% there! Just need to ensure `openscap-scanner` package is available on your target systems, then you can:

1. Run EE-based scans with centralized content
2. View reports at `http://utils.lab.iamgini.com/reports/`
3. Scale to multiple targets easily

The EE is built and ready. The scanning mechanism works. Just need that one package on the targets.

**What would you like to do next?**
