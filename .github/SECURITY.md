# Security Policy

## Scope

This is a public repository that demonstrates Day-0/Day-1/Day-2 automation for
**Amazon Linux 2023** on AWS using **Ansible Automation Platform (AAP)** — a
config-as-code workflow that provisions (Terraform), patches, hardens, creates a
`devops` user, and deploys a Docker webserver. It contains **patterns,
playbooks, roles, Terraform, CaC object definitions, and docs only** — no live
credentials, tokens, or environment-specific values.

## What Should Never Be Committed

- AAP tokens, AWS keys, SSH private keys, or the `devops` account password
- Customer or company names, RHDP deployment URLs, cluster/instance IDs, or other
  identifying details (committed files use generic placeholders; real values live
  only in the gitignored `docs/dev-environment.sh`)
- Terraform state (lives in S3; never in git), `*.tfstate`, or `.terraform/`
- Passwords, private keys, or session cookies

Per-developer secrets belong in `docs/dev-environment.sh` (gitignored). Commit
only `docs/dev-environment.sh.example` with placeholder values.

If any of the above is committed by mistake, rotate the affected credential
immediately and open an issue so it can be removed from history.

## Supported Versions

Only the latest commit on `main` is maintained.

## Reporting a Vulnerability

Open a public GitHub issue for general security concerns. If you believe
disclosure would cause active harm, contact the maintainer directly.
