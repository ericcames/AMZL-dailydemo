# AMZL-dailydemo

A reusable **Amazon Linux 2023** daily demo for **Ansible Automation Platform
(AAP)**. One workflow job template takes a customer from nothing to a running,
hardened, Docker-hosting web server on AWS — every AAP object defined as
**config-as-code**, every secret resolved from the environment at runtime.

## The workflow

The demo runs as a single **5-node workflow job template**. Each node is its own
job template so the story is visible step by step:

```
1. Provision AMZL2023 VM (Terraform)     ← EC2 on AWS, registered into AAP inventory
     └─►success─► 2. Patch to a target release   ← dnf --releasever pin
          └─►success─► 3. Security hardening       ← chrony, sshd, banners, security updates
               └─►success─► 4. Create devops user  ← wheel + docker, NOPASSWD sudo, SSH key
                    └─►success─► 5. Deploy Docker webserver  ← ubi9/httpd-24, standard index.html
```

Any node failing stops the chain.

## What it demonstrates (customer use cases)

- **Patch** AMZL2023 VMs to a specific release
- **Create users** — add to sudoers, set password, install SSH public key
- **Initial system configuration** — security best practices, chrony + utilities,
  admin/`devops` user setup, initial patching
- **Deploy a Docker app** — ensure the user is in the `docker` group, pull and run
  a container image serving a web page

## Architecture

| Layer | Tool |
|-------|------|
| Provisioning | Terraform (`terraform/`), wrapped by `playbooks/provision_vm_aws.yml`, run **from AAP** |
| Configuration | Ansible playbooks + roles, run **from AAP** on a custom Execution Environment |
| Orchestration | AAP workflow job template (5 nodes) |
| Definition | Config-as-code via `infra.aap_configuration` (`aap_config/load.yml`) |
| State | Terraform remote state in S3 |

> **Note — Amazon Linux 2023 is not RHEL.** No RHSM/Insights registration; the
> box uses `dnf`. Hardening is done with **native** modules (chrony, sshd config,
> login banners, security updates) rather than `redhat.rhel_system_roles`, which
> assume a supported RHEL-family platform — this keeps the demo from failing live
> on AL2023.

## Prerequisites

- An AAP 2.6 environment (this demo targets the **Ansible Product Demos** RHDP
  catalog item, which provides AAP on OpenShift + an AWS open environment)
- An AWS account/open environment with an S3 bucket for Terraform state
- `~/.ansible.cfg` with an Automation Hub offline token (see `ansible.cfg.example`)
- Collections installed locally for running CaC: `ansible-galaxy collection install -r aap_config/requirements.yml`
- The custom Execution Environment built and pushed (see `execution-environment.yml`)

## Quickstart

```bash
# 1. Configure your environment (never committed)
cp docs/dev-environment.sh.example docs/dev-environment.sh
$EDITOR docs/dev-environment.sh          # AAP host, AWS keys, S3 bucket, SSH keys, DEVOPS_PASSWORD
source docs/dev-environment.sh

# 2. One-time: create the Terraform state bucket
aws s3 mb s3://$AWS_TF_STATE_BUCKET --region $AWS_DEFAULT_REGION

# 3. Load every AAP object as config-as-code
ansible-galaxy collection install -r aap_config/requirements.yml
ansible-playbook aap_config/load.yml

# 4. In AAP, launch the workflow job template:
#    "AMZL Daily Demo - Provision and Configure"
```

## Repo layout

```
aap_config/        Config-as-code — projects, inventory, credentials, JTs, workflow, EE
terraform/         AWS VPC + AL2023 EC2 stack (S3 remote state, t-shirt sizing)
playbooks/         The 5 workflow playbooks + supporting plays
roles/             Reusable roles (security_hardening, devops_user, docker_webserver)
execution-environment.yml   ansible-builder definition (Terraform CLI + collections)
collections/       Collections baked into the EE / used at runtime
docs/              dev-environment.sh.example, talk track
```

## Secrets & reusability

No secrets are ever committed. Every sensitive value is read from an environment
variable at runtime (see `docs/dev-environment.sh.example`). A teammate reuses
this demo by ordering the same RHDP catalog item, filling in their own
`docs/dev-environment.sh`, and running `aap_config/load.yml`.

## License

[Apache-2.0](LICENSE)
