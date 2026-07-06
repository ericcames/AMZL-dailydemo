# Roadmap — AMZL-dailydemo

A reusable Amazon Linux 2023 daily demo on AAP: provision → patch → harden →
create `devops` user → deploy a Docker webserver, all as config-as-code.

**Target:** customer-facing demo, Wed **Jul 8 2026, 9:30 PST**.

## Phases

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Repo scaffold + community standards | ✅ Complete |
| 1 | Execution Environment (Terraform CLI + collections) — build & push to quay.io | ✅ Complete — built, verified, pushed public: `quay.io/zigfreed/amzl-dailydemo-ee:v1.0.0` |
| 2 | Terraform stack for AL2023 + `provision_vm_aws.yml` (node 1) | ✅ Complete |
| 3 | Playbooks: patch, harden, create devops user, deploy Docker web (nodes 2–5) | ✅ Complete |
| 4 | `aap_config/` CaC — 5 job templates + 5-node workflow + credentials/inventory/EE | ✅ Complete |
| 5 | Load CaC + end-to-end dry run against the live AWS open env | ⬜ **NEXT** — `source docs/dev-environment.sh` → `aws s3 mb` state bucket → `ansible-playbook aap_config/load.yml` → launch the workflow |

## Decisions Log

- **2026-07-06** — Provisioning via **Terraform** (mirrors the
  `aap.lightspeed.patching` pattern), not native `amazon.aws`. Terraform CLI ships
  in the custom EE.
- **2026-07-06** — Runs on the **Ansible Product Demos** RHDP catalog item (AAP
  2.6 on OpenShift + AWS open environment), already provisioned.
- **2026-07-06** — Patching is a **dedicated workflow node** (5-node workflow),
  ordered provision → patch → harden → user → docker.
- **2026-07-06** — Repo **scaffolded from `aap.lightspeed.patching`** (community
  standards + CaC) and reuses roles from `aap.dailydemo.F5`.
- **2026-07-06** — **New custom EE** required — the stock/Lightspeed EE lacks
  `community.docker`. EE pushed to public **quay.io/zigfreed/amzl-dailydemo-ee**.
- **2026-07-06** — Docker webserver image: **registry.access.redhat.com/ubi9/httpd-24**
  (anonymous-pullable, on-brand, no entitlement needed at demo time).
- **2026-07-06** — Terraform state bucket: **amzl-dailydemo-tfstate-eca**.
- **2026-07-06** — AL2023 is not RHEL: hardening uses **native** modules (chrony,
  sshd, banners, security `dnf` updates), NOT `redhat.rhel_system_roles`.
- **2026-07-06** — EE build **requires `--build-arg PYCMD=/usr/bin/python3.11`**
  (base `ee-minimal-rhel9` points `/usr/bin/python3` at Python 3.9, which has no
  pip → assemble fails). This is a base-image property, independent of
  `rhel_system_roles`. Build verified clean: the `~/.ansible.cfg` Hub token lands
  only in the intermediate galaxy stage and is **NOT** in the final image, so the
  public quay push carries no secret.

## Deferred / fast-follow

- Teardown workflow (`terraform destroy` + inventory cleanup).
- Post-load CaC validation play.
- Retro-file GitHub Issues if teammates start contributing.
