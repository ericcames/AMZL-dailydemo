# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project aims
to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- CI: the `ansible-lint` gate failed on every run because `amazon.aws.s3_bucket`
  (`playbooks/provision_vm_aws.yml`) and `ansible.controller.project_update`
  (`tools/sync_project.yml`) were missing from `mock_modules` in `.ansible-lint`.
  CI lints `--offline` (collections not installed), so unmocked external modules
  fail syntax-check. (#6)

### Added

- `docs/loading-aap.md` — a step-by-step walkthrough for a new Ansible user to
  load every AAP object as config-as-code, from ordering the RHDP environment
  through launching the workflow. Enumerates the objects `load.yml` creates and
  includes a troubleshooting table.

### Documentation

- README: corrected the Quickstart and Prerequisites. Removed the obsolete manual
  `aws s3 mb` step (node 1 now auto-creates the state bucket) and stopped listing
  "build the EE" as a prerequisite — the EE is public and pinned, so new users
  consume it directly. Added a pointer to `docs/loading-aap.md` and fixed the repo
  layout to show roles under `playbooks/roles/`.
- ROADMAP: marked Phase 5 complete (all 5 workflow nodes verified end-to-end) and
  moved the now-shipped teardown JT/schedule out of the deferred list.
- Talk track: refreshed the setup checklist (idempotent load, project sync, public
  EE), described the target-release survey as a drop-down defaulting to a pinned
  release, and replaced the stale "no teardown yet" reset section with the shipped
  Teardown JT + nightly schedule.

### Changed

- Terraform AMI: pinned to AL2023 release `2023.12.20260608` (via `aws_ami`
  data source + `al2023_release` variable) instead of always fetching the
  latest AMI from SSM. This ensures the patch playbook has room to demonstrate
  `dnf update --releasever` moving the host forward to the survey-selected
  release. Previously the latest AMI was already at or past the target release,
  making the patch a no-op.

- Patch JT survey: changed from free-text to multiplechoice matching the
  workflow survey — prevents typos that would 404 the AL2023 mirror.

- Survey defaults: both the workflow and patch JT now default to
  `2023.12.20260622` instead of `latest`, and the `2023.12.20260608` choice
  is removed (it matches the AMI baseline and would be a no-op).

### Fixed

- `devops_user` role: hash the devops password on the target host with `openssl
  passwd -6` instead of the `password_hash('sha512')` Jinja filter. The filter
  runs controller-side in the EE, whose Python has neither `crypt` nor
  `passlib`, so it failed with "Unable to encrypt nor hash, passlib must be
  installed". Hashing on the target sidesteps the EE entirely — no rebuild.

- Role resolution: moved `roles/` → `playbooks/roles/` so the role-based
  playbooks (hardening, devops user, docker web) find their roles via Ansible's
  automatic `<playbook_dir>/roles` search. Previously they failed from AAP with
  "the role '…' was not found" because repo-root `roles/` isn't on the search
  path when the playbook lives in `playbooks/`, and this repo (by rule) ships no
  project-local `ansible.cfg` to set `roles_path`.

### Changed

- Project CaC: set `scm_update_on_launch: false` (explicitly, since the CaC role
  only changes fields it's given) — the project no longer syncs from git before
  every workflow node. Sync explicitly (manual or a project_update step) for
  deterministic runs without per-node sync overhead.

- Workflow survey: "Target release" is now a `multiplechoice` dropdown
  (`latest` + the most recent AL2023 point releases) instead of free text — a
  mistyped `releasever` no longer sails through to 404 the AL2023 mirror and
  fail the patch node. List is the newest releases because `dnf update` only
  moves forward; refresh it from the AL2023 release notes as new builds ship.

### Added

- `tools/` operator helpers: `sync_project.yml` (manual AAP project sync, needed
  now that `scm_update_on_launch` is off) and `get_job.yml` (fetch a job's status
  + stdout via the API for debugging). Both read creds from the environment.

- `playbooks/provision_vm_aws.yml`: idempotent guard task
  (`amazon.aws.s3_bucket`) that ensures the Terraform state bucket exists before
  `terraform init`, so node 1 is self-sufficient — no manual `aws s3 mb`
  prerequisite. Managed in Ansible (not the Terraform stack that uses it as a
  backend) to avoid the backend chicken-and-egg; enables versioning and blocks
  public access. Teardown must not delete this bucket (shared, long-lived state).

- Config-as-code: baseline AAP settings applied by the dispatch run, following
  the dc1.azure pattern.
  - `aap_config/files/gateway_settings.yml` — AAP **pre-login message**
    (`custom_login_info`); it's a gateway setting on AAP 2.6. Scope limited to
    the login banner so loading the demo doesn't alter auth/proxy/password
    policy on a shared AAP. Banner text is generic and committed.
  - `aap_config/files/controller_settings.yml` — enables **Automation
    Analytics** (`INSIGHTS_TRACKING_STATE`) with **service-account** auth
    (`SUBSCRIPTIONS_CLIENT_ID`/`SUBSCRIPTIONS_CLIENT_SECRET`); legacy
    `REDHAT_USERNAME`/`REDHAT_PASSWORD` explicitly cleared. Creds resolve from
    env vars (`REDHAT_SUBSCRIPTIONS_CLIENT_ID`/`_SECRET`) and the role runs with
    secure logging on so the client secret never lands in job output.
  - `docs/dev-environment.sh.example` updated with the service-account vars.

- Docs: `docs/dev-environment.sh.example` (env template — AAP, AWS, S3 bucket,
  SSH keys, DEVOPS_PASSWORD, EE overrides) and `docs/demo-talk-track.md`.

- Config-as-code (`aap_config/`): `load.yml` (basic-auth dispatch, no token),
  `requirements.yml`, `group_vars/all.yml`, and object files — organization,
  a `Secrets` custom credential type + 4 credentials, project, inventory, the
  public quay EE, 5 job templates, and the 5-node `Provision and Configure`
  workflow with a single survey. yamllint + ansible-lint pass.

- Workflow playbooks (`playbooks/`): `provision_vm_aws.yml` (Terraform wrapper +
  AAP host registration), `patch_amzl.yml` (dnf `--releasever` pin), plus
  `security_hardening.yml`, `create_devops_user.yml`, `deploy_docker_webserver.yml`.
- Roles: `security_hardening` (chrony, firewalld, SSH banners/PermitRootLogin,
  dnf-automatic), `devops_user` (wheel+docker, NOPASSWD sudo, authorized key),
  `docker_webserver` (Docker + UBI9 httpd container, ported daily-demo index.html).
  yamllint + ansible-lint (production profile) pass.

- Terraform stack (`terraform/`) for an Amazon Linux 2023 EC2 instance: VPC +
  public subnet + IGW + security group + SSH key pair, AL2023 AMI resolved from
  the AWS SSM public parameter, t-shirt sizing (small/medium/large), and S3
  remote-state backend. `terraform validate` passes.

- Execution Environment definition (`execution-environment.yml`) — RHEL9 minimal
  base + Terraform 1.15.6 CLI; collections `amazon.aws`, `ansible.posix`,
  `community.docker`, `ansible.controller` (`collections/requirements.yml`).

- Initial repository scaffold: community standards (LICENSE, CONTRIBUTING,
  CODE_OF_CONDUCT, CODEOWNERS, SECURITY, issue/PR templates), lint config
  (`.yamllint`, `.ansible-lint`, CI lint workflow), `galaxy.yml`, `README.md`,
  `ROADMAP.md`, and repo-specific `CLAUDE.md`.
