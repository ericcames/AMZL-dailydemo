# AMZL-dailydemo — Demo Talk Track

A ~10-minute customer walkthrough of end-to-end Amazon Linux 2023 automation on
Ansible Automation Platform. Everything you see was defined as config-as-code and
loaded with a single `load.yml`.

## Setup (before the customer joins)

1. `source docs/dev-environment.sh`
2. Confirm the EE is published: `quay.io/zigfreed/amzl-dailydemo-ee:v1.0.0`
3. `ansible-playbook aap_config/load.yml` — creates the org, credentials, project,
   inventory, EE, 5 job templates, and the workflow.
4. In AAP, open **Templates → AMZL Daily Demo - Provision and Configure**.

## The story

> "Our customer wants to take a bare Amazon Linux 2023 VM and make it
> production-ready: patched to a known release, hardened, with a real user they
> can log in as, running a containerized app. Let's do all of it from one
> workflow."

### 1. Launch the workflow
Launch **AMZL Daily Demo - Provision and Configure**. The single survey asks two
questions:
- **VM size** (small / medium / large)
- **Target release** (an AL2023 version, or `latest`)

### 2. Node 1 — Provision (Terraform)
> "Step one provisions the VM with **Terraform**, running inside AAP. Same IaC
> tool your teams already use — AAP just orchestrates it."

Point out the VPC, security group, and EC2 instance being created, and that the
new host is automatically **registered into the AAP inventory** for the next
steps.

### 3. Node 2 — Patch to a certain release
> "AL2023 supports deterministic upgrades, so we can pin the box to an exact
> release — not just 'latest'. That's how you get reproducible fleets."

### 4. Node 3 — Security hardening
> "Best practices, natively: time sync with chrony, a host firewall, SSH login
> banners, root SSH login disabled, and unattended security updates turned on."

### 5. Node 4 — Create the devops user
> "A real, reusable account: member of sudo and docker, our team's standard
> password, passwordless sudo, and my SSH key authorized."

Live proof: `ssh devops@<public-ip>` from your workstation, then `sudo -n id`
(no password prompt).

### 6. Node 5 — Deploy the Docker webserver
> "Finally we pull a Red Hat UBI httpd image and run the app in a container —
> and the devops user can manage it because they're in the docker group."

Live proof: browse to `http://<public-ip>/` — the daily-demo page renders,
showing the host it's running on.

## Close

> "From one workflow: provisioned, patched to a known release, hardened,
> user-ready, and running a container — all defined as code, reusable by any
> teammate who orders the same environment and runs `load.yml`."

## Reset between runs

There is no teardown workflow yet (fast-follow). To reset manually:
`cd terraform && terraform destroy` (with the same `-backend-config` init), then
remove the host from the `amzl-dailydemo` inventory.
