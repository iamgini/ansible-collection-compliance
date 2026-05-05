# CLAUDE.md — Compliance-as-Code Framework

## Project overview

This project builds a service-ready, AAP-native Compliance-as-Code framework.
It uses OpenSCAP + ComplianceAsCode/content to automate security scanning and
remediation for enterprise customers across RHEL (Phase 1–3) and Windows (Phase 4+).

All execution happens inside Red Hat Ansible Automation Platform (AAP). No
ansible-core CLI. No oscap-ssh. Everything runs through AAP job templates and
workflow templates.

---

## Repository structure

```
compliance-as-code-framework/
├── CLAUDE.md                         ← this file
├── execution-environment/
│   ├── execution-environment.yml     ← EE definition (ansible-builder)
│   └── requirements.yml              ← Python + Ansible collection deps
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml                   ← global defaults (profile, scan schedule)
│   │   └── rhel_cis_l2/             ← per-profile group vars
│   └── host_vars/
│       └── <hostname>.yml            ← per-host exceptions (see exception schema)
├── playbooks/
│   ├── scan.yml                      ← Phase 1: run oscap, fetch results
│   ├── parse_failures.yml            ← Phase 2: extract failed rules to JSON
│   ├── generate_remediation.yml      ← Phase 2: oscap generate fix → playbook
│   ├── commit_playbook.yml           ← Phase 2: git commit generated playbook
│   ├── remediate.yml                 ← Phase 3: wrapper that applies generated playbook
│   └── rescan.yml                    ← Phase 3: post-remediation validation scan
├── roles/
│   ├── report_server/                ← Phase 1: nginx setup, dir structure
│   ├── oscap_scan/                   ← Phase 1: install oscap, run eval, fetch
│   ├── parse_results/                ← Phase 2: ARF XML parser
│   ├── generate_fix/                 ← Phase 2: oscap generate fix wrapper
│   └── exception_handler/            ← Phase 3: reads host_vars, injects skip tags
├── profiles/
│   ├── upstream/                     ← symlinks or copies of SSG profiles
│   └── overlay/                      ← customer-specific and ASEAN regulatory profiles
│       ├── mas-trm-rhel9.profile
│       ├── ojk-rhel9.profile
│       └── <customer>-rhel9.profile
├── generated/                        ← Git-committed remediation playbooks (auto-created)
│   └── <customer>/
│       └── <hostname>/
│           └── <date>-<profile>/
│               └── remediation.yml
├── reports/                          ← local copy structure (mirrored on report server)
└── tests/
    ├── molecule/                     ← role testing
    └── lint/                         ← ansible-lint, yamllint configs
```

---

## Key architecture decisions

### No oscap-ssh
`oscap-ssh` bypasses AAP credential management. All scanning runs OpenSCAP
locally on the target host via standard Ansible SSH (managed by AAP).
Pattern: install oscap on target → run locally → `ansible.builtin.fetch` results.

### Two OpenSCAP deployment modes (slide 23 from Red Hat One 2026 deck)
- **Centralized generation** (default): OpenSCAP on report server only.
  `oscap xccdf generate fix` runs on report server using stored result XML.
  Managed nodes need only `openscap-scanner` + `scap-security-guide` for scanning.
- **Per-system audit**: OpenSCAP on target. Used when per-host tailored results
  are needed. Both modes are supported; centralized is the default.

### Exceptions and deviations — per-host AND per-group
Exceptions are supported at two levels, evaluated in this order (most specific wins):

- **Group level** (`group_vars/{group_name}.yml`): rules that don't apply to an entire
  host group (e.g. all DB servers exempt from a rule). Defined once, applied to all
  members of the group automatically.
- **Host level** (`host_vars/{hostname}.yml`): rules specific to one host that differ
  from its group. Overrides or extends group-level exceptions.

The `exception_handler` role merges both levels before applying skip tags.
Host-level exceptions take precedence over group-level for the same rule ID.

### oscap generate fix — report server OR EE (configurable)
`oscap xccdf generate fix` can run in two modes, controlled by `generate_fix_mode` variable:

- **`report_server`** (default): runs on the report server using the stored `result.xml`.
  Report server needs `openscap-utils` installed. AAP delegates the task to report server.
  Best for: persistent infrastructure, auditable generation, re-generation without re-scanning.

- **`execution_environment`** (dynamic): runs directly inside the AAP EE during the job.
  EE must have `openscap-utils` baked in (add to `execution-environment.yml`).
  Result XML is fetched to EE temp dir, fix generated in-memory, committed to Git.
  Best for: environments where report server access is restricted, or simpler infrastructure.

Set in `group_vars/all.yml`:
```yaml
generate_fix_mode: "report_server"   # or "execution_environment"
```

The `generate_fix` role handles both modes transparently — callers do not need to
change playbooks when switching modes.

### Git as remediation playbook store — single public repo
This is a **single public Git repository** shared across all customers.
Customer-specific content is separated by directory structure, not by repo or branch.
Generated playbooks committed under `generated/{customer_id}/`.
Profiles and overlays under `profiles/overlay/{customer_id}/`.
AAP projects all point to this same repo with different playbook paths per customer.
Branch per environment (dev/staging/prod), not per customer or host.

**Public repo implications:**
- No customer data (hostnames, IPs, scan results) ever committed — report server only
- No customer-identifying information in `host_vars/` filenames in the public repo —
  use role-based names (`db-server`, `web-server`) not real hostnames
- Exception justifications in `host_vars/` may be sensitive — use a private fork or
  AAP survey variables for customer-specific exception reasons if needed
- `generated/` playbooks contain only rule IDs and Ansible tasks — no host data

---

## Variable schema

### group_vars/all.yml (global defaults)
```yaml
# Profile selection — override per group or host
cis_profile: "xccdf_org.ssgproject.content_profile_cis_level2_server"
ssg_datastream: "/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml"

# Report server
report_server_host: "report-server.internal"
report_server_base_dir: "/var/reports"
report_server_url: "http://report-server.internal/reports"

# Scan settings
scan_date: "{{ ansible_date_time.date }}"
scan_dir: "{{ scan_date }}-{{ cis_profile | regex_replace('.*profile_', '') }}"

# Fix generation mode: "report_server" or "execution_environment"
generate_fix_mode: "report_server"

# Git settings
git_repo_path: "/opt/compliance-playbooks"
git_branch: "main"
git_author_name: "AAP Compliance Bot"
git_author_email: "aap@company.internal"

# Exception defaults (empty — overridden at group or host level)
compliance_skip_rules: []
compliance_exception_reasons: {}
compliance_var_overrides: {}
```

### group_vars/{group_name}.yml (group-level exceptions — applies to all hosts in group)
```yaml
# Example: group_vars/db_servers.yml
# All DB servers in this group share these exceptions
customer_id: "acme-bank"

compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_service_nfs_disabled"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_service_nfs_disabled:
    reason: "All DB servers require NFS v3 for Oracle shared storage"
    approved_by: "security-lead@acme.com"
    approved_date: "2026-04-01"
    review_date: "2026-10-01"
```

### host_vars/{hostname}.yml (host-level exceptions — extends group exceptions)
```yaml
# Example: host_vars/pxe-server-01.yml
# Extends group exceptions — host-level rules merged with group_vars rules
# Host-level takes precedence if same rule ID appears in both

# Additional rules skipped only on this specific host
compliance_skip_rules:
  - "xccdf_org.ssgproject.content_rule_package_tftp_removed"

compliance_exception_reasons:
  xccdf_org.ssgproject.content_rule_package_tftp_removed:
    reason: "PXE boot server — TFTP required for provisioning"
    approved_by: "infra-lead@acme.com"
    approved_date: "2026-04-01"
    review_date: "2026-10-01"

# Optional: override profile-level SSG variables for this host only
compliance_var_overrides:
  var_password_pam_minlen: "16"
  var_accounts_maximum_age_login_defs: "60"
```

**Merge behaviour:** `exception_handler` role combines `group compliance_skip_rules` +
`host compliance_skip_rules` into a unified skip list. Duplicate rule IDs are deduplicated.
Host-level `compliance_exception_reasons` override group-level for the same rule ID.

---

## Report server directory structure

```
/var/reports/
└── {customer_id}/
    └── {hostname}/
        └── {date}-{profile_short_name}/
            ├── result.xml            ← ARF XML (input to oscap generate fix)
            ├── report.html           ← human-readable, served via nginx
            ├── failed-rules.json     ← extracted failures (rule_id, severity, title)
            └── metadata.json         ← scan summary (score, counts, aap_job_id)
```

### metadata.json schema
```json
{
  "customer_id": "acme-bank",
  "hostname": "db-server-01",
  "profile": "cis_level2_server",
  "scan_date": "2026-05-05",
  "aap_job_id": "1234",
  "total_rules": 350,
  "pass_count": 312,
  "fail_count": 38,
  "compliance_score_pct": 89.1,
  "critical_failures": 3,
  "high_failures": 12
}
```

---

## AAP workflow structure (Phase 3)

```
Workflow: compliance_full_cycle
├── Node 1: job_template → scan           (runs scan.yml)
├── Node 2: job_template → parse          (runs parse_failures.yml)
├── Node 3: job_template → generate       (runs generate_remediation.yml)
├── Node 4: approval_node                 (human gate before any changes)
├── Node 5: job_template → remediate      (runs remediate.yml)
└── Node 6: job_template → rescan         (runs rescan.yml, validates improvement)
```

Node 1–3 run on success of previous. Node 5 only runs after Node 4 is approved.
Node 6 runs regardless of Node 5 outcome (always re-scan to capture state).

---

## Phase delivery plan

### Phase 1 (1–2 days) — Foundation
Goal: scan runs, results stored, HTML report browsable.
Files to create:
- `execution-environment/execution-environment.yml`
- `roles/oscap_scan/`
- `roles/report_server/`
- `playbooks/scan.yml`
- `inventory/group_vars/all.yml`

### Phase 2 (2–3 days) — Extraction + generation
Goal: failed-rules.json written, remediation playbook committed to Git.
Files to create:
- `roles/parse_results/`
- `roles/generate_fix/`
- `playbooks/parse_failures.yml`
- `playbooks/generate_remediation.yml`
- `playbooks/commit_playbook.yml`

### Phase 3 (3–4 days) — Full AAP workflow
Goal: end-to-end automated workflow with approval gate and exceptions.
Files to create:
- `roles/exception_handler/`
- `playbooks/remediate.yml`
- `playbooks/rescan.yml`
- AAP workflow template definition (YAML export)
- RBAC setup playbook

### Phase 4 (ongoing) — Service hardening
- ASEAN regulatory profiles under `profiles/overlay/`
- AI-authored internal rules (Claude Code assisted)
- Compliance dashboard
- Windows content track (separate pipeline, no OpenSCAP)

---

## Known limitations and constraints

### OpenSCAP / ComplianceAsCode
- **Windows support removed** from OpenSCAP/SSG. Windows is a separate track (Phase 4+).
  Source of truth for Windows: NIST / DISA / CIS directly, not SSG.
- Some CIS rules don't map 1:1 to SCAP — manual Ansible tasks may be needed.
- Remediation content is strongest on RHEL. Community Linux (Ubuntu, Debian) coverage varies.
- `scap-security-guide` RPM version must match the datastream version — pin explicitly in EE.

### AAP-specific
- No `oscap-ssh` — AAP cannot inject credentials into subprocess SSH calls.
- Generated playbooks must pass `ansible-lint` before AAP will run them cleanly.
- AAP project syncs on-demand or scheduled — allow 1–2 min sync time after Git commit.
- Approval nodes in workflow templates require AAP 2.4+.

### Report server
- HTML reports are static — no auth by default. Add nginx basic auth or VPN-restrict.
- ARF XML can be 1–5MB per host per scan. Plan storage for: hosts × scan frequency × retention.
- When `generate_fix_mode: "report_server"`, report server needs `openscap-utils` installed.
- When `generate_fix_mode: "execution_environment"`, report server needs only storage + nginx —
  no OpenSCAP required on report server. EE handles generation.

---

## Coding conventions

### Ansible
- Use FQCN (fully qualified collection names) for all modules:
  `ansible.builtin.command`, not `command`
- All tasks must have a `name:` — descriptive, sentence case
- Use `ignore_errors: yes` only on oscap scan task (non-zero exit = findings, not failure)
- Register results with meaningful variable names: `oscap_scan_result`, not `result`
- Use `delegate_to: "{{ report_server_host }}"` for all report server operations
- No hardcoded paths — all paths via variables defined in `group_vars/all.yml`
- Handlers for service restarts only — not for compliance tasks

### File naming
- Playbooks: `verb_noun.yml` (scan.yml, parse_failures.yml, generate_remediation.yml)
- Roles: `noun_noun` (oscap_scan, report_server, parse_results)
- Generated playbooks: `remediation-{date}.yml` inside `generated/{customer}/{host}/{scan_dir}/`

### Variables
- Prefix customer-specific vars with `customer_` or use `customer_id` as namespace key
- Exception vars always in `host_vars/`, never in playbooks or roles
- Profile IDs always use full XCCDF ID string, never short aliases

### Git commits (generated playbooks)
- Commit message format: `[compliance] {customer_id}/{hostname} {date} - {fail_count} rules`
- Never commit result XML or HTML to Git — report server only
- Only `generated/` directory is auto-committed by AAP bot

---

## Testing

### Before running against production
1. Run `ansible-lint playbooks/` — zero warnings required
2. Run `yamllint .` — zero errors required
3. Test scan playbook against a dev RHEL VM first
4. Verify generated playbook syntax: `ansible-playbook --syntax-check generated/.../remediation.yml`
5. Run generated playbook in `--check` mode before live execution

### Molecule (Phase 2+)
- Role-level testing under `tests/molecule/`
- Test `parse_results` role with fixture ARF XML files (sample results, not real customer data)
- Test `exception_handler` role with known skip lists

---

## AI-assisted content authoring (Phase 4)

When using Claude Code to author new ComplianceAsCode rules or internal Ansible tasks:

1. Always read an existing rule first for structure reference:
   `linux_os/guide/{category}/{rule_name}/` in ComplianceAsCode repo
2. Each rule needs: `rule.yml`, `ansible/shared.yml`, `oval/shared.xml`, `bash/shared.sh`
3. AI generates draft — human reviews OVAL logic and tests before committing upstream
4. Internal rules (not upstreamable) go in `profiles/overlay/rules/` as standalone tasks
5. Style must match SSG: FQCN modules, `{{{ rule_title }}}` Jinja2 macros, tags matching rule ID

---

## Reference links

- ComplianceAsCode content: https://github.com/ComplianceAsCode/content
- ComplianceAsCode docs: https://complianceascode.readthedocs.io
- ComplianceAsCode AI skills: https://complianceascode.readthedocs.io/en/latest/manual/developer/12_ai_skills.html
- OpenSCAP user manual: https://static.open-scap.org/openscap-1.3/oscap_user_manual.html
- SSG scanning guide: https://complianceascode.readthedocs.io/en/latest/manual/user/20_scanning.html
- Red Hat AAP docs: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform
- ansible-builder docs: https://ansible-builder.readthedocs.io