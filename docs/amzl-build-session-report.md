---
doc-type: reference
status: active
owner: jason
updated: 2026-07-14
---

# AMZL-dailydemo — Build Session Report

**Build Session Report · Config-as-Code Demo**

## How `AMZL-dailydemo` was built in a single afternoon

A reusable **Amazon Linux 2023** daily demo for Ansible Automation Platform — provisioned, patched, hardened, and served, entirely as config-as-code. **26 commits, one 5 1/4-hour session, 100% AI co-authored.**

| Commits | Duration | AI Co-authored | Workflow Nodes |
|---------|----------|----------------|----------------|
| **26** (one day) | **5h 15m** (13:06 → 18:21 PDT) | **100%** | **5** (all green) |

---

## 01 — Executive Summary

**Pipeline:**

`provision` → `patch` → `harden` → `devops user` → `docker web`

**AMZL-dailydemo** delivers a single **5-node workflow job template** that runs the pipeline above end-to-end. Every AAP object — credentials, project, inventory, job templates, the workflow itself — is config-as-code loaded by `aap_config/load.yml` via `infra.aap_configuration`. It runs from AAP on a custom public execution environment (`quay.io/zigfreed/amzl-dailydemo-ee`) bundling the Terraform CLI plus `amazon.aws`, `ansible.posix`, `community.docker`, and `ansible.controller`.

Scaffolded from `aap.lightspeed.patching` and reusing roles from `aap.dailydemo.F5`, it was built to hit a customer demo on **Wed Jul 8, 2026, 9:30 PST**. Status at session end: **complete and demo-ready** — all five workflow nodes verified against a live AWS environment, secrets kept out of git via env-var lookups, and a nightly teardown job controlling EC2 cost.

---

## 02 — AI Involvement

Every one of the 26 commits carries a **Co-Authored-By: Claude** trailer. This was a Claude Code pair-programming session — the developer directed and owns each commit; the AI did the hands-on production across two model versions.

### Model Breakdown

| Model | Commits | Scope |
|-------|---------|-------|
| **Claude Opus 4.8** | 19 | Scaffold, EE, Terraform stack, playbooks & roles, the CaC layer, baseline settings, docs. |
| **Claude Opus 4.6** | 7 | A mid-session run: Docker SDK fix, webserver page, teardown JT, control inventory, AMI pin. |

### Roles Played

- **Generation** — Stood up every layer in the opening 23-minute burst — scaffold, EE, Terraform, 5 playbooks, 3 roles, full CaC.
- **Runtime debugging** — Cracked the AL2023-specific failures: EE python `PYCMD`, target-side password hashing, the pip-vs-RPM conflict, role-path resolution.
- **Pattern reuse** — Ported proven conventions from sibling repos — login banner, service-account analytics, teardown guards, control inventory.
- **Governance** — Kept README / ROADMAP / CHANGELOG in sync and verified no secrets or customer data ever landed in a tracked file.

---

## 03 — Session Timeline

*2026-07-06 · PDT (−0700)*

**Legend:** Opus 4.8 · Opus 4.6 · Author: Eric Ames \<ericcames@msn.com\>

### Phase 1 — Foundation — stand up every layer (13:06 – 13:47)

| Time | Model | Commit | Description |
|------|-------|--------|-------------|
| 13:06 | 4.8 | `5ab9f2c` | **Scaffold repo — community standards + governance** |
| 13:12 | 4.8 | `167b10b` | Add Execution Environment definition |
| 13:14 | 4.8 | `943556d` | Add Terraform stack for Amazon Linux 2023 |
| 13:22 | 4.8 | `279a5fe` | Add workflow playbooks and roles (nodes 1–5) |
| 13:28 | 4.8 | `3ad746d` | Add AAP config-as-code (5 job templates + 5-node workflow) |
| 13:29 | 4.8 | `a80fff8` | Add dev-environment template and demo talk track |
| 13:42 | 4.8 | `b42e525` | Fix EE build: require `PYCMD=/usr/bin/python3.11` **[FIX]** |
| 13:47 | 4.8 | `1e84ef8` | Roadmap: EE built + pushed public; mark load as NEXT |

> *~2h gap — offline EE build & push, first CaC load against live AAP*

### Phase 2 — Config-as-code & platform baseline (15:47 – 16:03)

| Time | Model | Commit | Description |
|------|-------|--------|-------------|
| 15:47 | 4.8 | `7ff44db` | Baseline settings as code: pre-login banner + Automation Analytics |
| 15:57 | 4.8 | `f54c8cd` | Provision node: guard that ensures the Terraform state bucket exists |
| 16:03 | 4.8 | `2d53bdc` | Survey: make Target release a dropdown of recent AL2023 releases |

### Phase 3 — Debug to green — the real engineering (16:21 – 16:46)

| Time | Model | Commit | Description |
|------|-------|--------|-------------|
| 16:21 | 4.8 | `2861a9a` | Fix role resolution (move roles under `playbooks/`) + drop on-launch sync **[FIX]** |
| 16:25 | 4.8 | `5cc49f9` | Project CaC: explicitly disable `scm_update_on_launch` |
| 16:34 | 4.8 | `a1e2d81` | Fix devops user: hash password on target, not in the EE **[FIX]** |
| 16:36 | 4.8 | `2d088d9` | Roadmap: mark Phase 5 in progress; log decisions |
| 16:38 | 4.8 | `b03244b` | Add `tools/` operator helpers: project sync and job fetch |
| 16:46 | 4.6 | `64f77d5` | Fix Docker SDK install: virtualenv to avoid RPM conflict on AL2023 **[FIX]** |

### Phase 4 — Operations, polish & docs to tested state (16:55 – 18:21)

| Time | Model | Commit | Description |
|------|-------|--------|-------------|
| 16:55 | 4.6 | `f7babb2` | Enhance webserver page: Ansible logo, release version, URL in job log |
| 16:55 | 4.6 | `46a65ea` | Add nightly teardown: job template + 6 PM Arizona schedule |
| 17:02 | 4.6 | `97b8ac7` | Replace inline SVG with AAP logo PNG from brand assets |
| 17:12 | 4.6 | `13840d2` | Add control inventory for localhost-only job templates |
| 17:15 | 4.6 | `c47b81a` | Fix teardown: guard host deregistration against empty Terraform state **[FIX]** |
| 17:39 | 4.6 | `a33364d` | Pin AMI to AL2023 2023.12.20260608 so patching demo can move forward |
| 18:13 | 4.8 | `3de6a77` | Add new-user AAP load guide; correct README/ROADMAP to tested state |
| 18:16 | 4.8 | `41486c6` | Fix broken in-page anchor links in loading-aap guide **[FIX]** |
| 18:21 | 4.8 | `5b32fcd` | **Update demo talk track to tested state — HEAD** |

---

**Repo:** AMZL-dailydemo · **Author:** Eric Ames · **Branch:** main

*Generated from git history · 2026-07-14*
