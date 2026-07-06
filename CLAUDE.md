# CLAUDE.md — AMZL-dailydemo

Repo-specific guidance for Claude Code. Global rules in `~/.claude/CLAUDE.md`
still apply (never commit customer data or secrets; one concern per PR; maintain
CHANGELOG; additive only; `ansible.platform` over `ansible.controller` where a
module exists; never ship a project-local `ansible.cfg`).

## What this repo is

A reusable **Amazon Linux 2023** daily demo for AAP. A single **5-node workflow
job template** runs: **provision (Terraform) → patch → harden → create `devops`
user → deploy Docker webserver**. Every AAP object is config-as-code
(`aap_config/load.yml`, via `infra.aap_configuration`). Scaffolded from
`aap.lightspeed.patching`; reuses roles from `aap.dailydemo.F5`.

## Key conventions

- **Secrets come from the environment.** Nothing sensitive is committed. Runtime
  values resolve from env vars via `lookup('ansible.builtin.env', ...)`. The
  template is `docs/dev-environment.sh.example`; the real file
  `docs/dev-environment.sh` is gitignored.
- **The demo runs from AAP**, on a **custom EE** that carries the **Terraform
  CLI** plus `amazon.aws`, `ansible.posix`, `community.docker`, and
  `ansible.controller`. Local `ansible-playbook` is for debugging only.
- **EE image:** `quay.io/zigfreed/amzl-dailydemo-ee` (public). Build with
  `ansible-builder` + `PYCMD=/usr/bin/python3.11` (a `dnf` bindep otherwise
  repoints python3 → 3.9 and breaks assemble). `~/.ansible.cfg` must be a real
  file (not a symlink) — ansible-builder's COPY doesn't follow symlinks.
- **Terraform** provisions AWS infra (`terraform/`), wrapped by
  `playbooks/provision_vm_aws.yml`. Region + AWS creds come from **env vars**
  (`providers.tf` reads them); the AAP AWS credential injects keys but **not** a
  region, so the apply task sets `AWS_DEFAULT_REGION`. State in S3 bucket
  `amzl-dailydemo-tfstate-eca`.
- **Docker webserver:** `registry.access.redhat.com/ubi9/httpd-24`, serving the
  standard daily-demo `index.html` (ported from `aap.dailydemo.F5`
  `roles/website_setup`), via `community.docker.docker_container`.

## AL2023 gotchas (not RHEL!)

- Uses `dnf`; **no RHSM/Insights registration**. Don't port register/unregister
  plays from `aap.lightspeed.patching`.
- "Patch to a certain release" = AL2023 versioned repos:
  `dnf update --releasever=<2023.x.y>`.
- Default admin user is `ec2-user`.
- Hardening uses **native** modules (chrony, sshd config, login banners,
  security-only `dnf` updates) — NOT `redhat.rhel_system_roles`, which assume a
  supported RHEL-family platform. Don't reintroduce them; don't let a
  non-applicable role fail live.

## Layout

`aap_config/` CaC · `terraform/` AWS infra · `playbooks/` the 5 plays ·
`playbooks/roles/` reusable roles (kept **adjacent to the playbooks** so
Ansible's `<playbook_dir>/roles` search finds them with no project-local
`ansible.cfg`) · `execution-environment.yml` EE def · `docs/` env template +
talk track · `tools/` local operator helpers (`sync_project.yml`, `get_job.yml`).

See `ROADMAP.md` for phase status and the Decisions Log.
