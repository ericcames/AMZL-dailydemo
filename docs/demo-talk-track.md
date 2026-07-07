# AMZL-dailydemo — Demo Talk Track

A ~10-minute customer walkthrough of end-to-end Amazon Linux 2023 automation on
Ansible Automation Platform. Everything you see was defined as config-as-code and
loaded with a single `load.yml`.

## Setup (before the customer joins)

First time loading this into AAP? Follow **[loading-aap.md](loading-aap.md)**.
Once it's loaded, the pre-demo checklist is:

1. `source docs/dev-environment.sh`
2. `ansible-playbook aap_config/load.yml` — idempotently creates the org,
   credentials, project, both inventories, EE, 6 job templates, the workflow, and
   the nightly-teardown schedule. (The EE is the public
   `quay.io/zigfreed/amzl-dailydemo-ee:v1.0.0` image — nothing to build.)
3. In AAP, **Sync** the `AMZL Daily Demo` project so it has the latest playbooks.
4. Open **Templates → AMZL Daily Demo - Provision and Configure**.

## The story

> "Our customer wants to take a bare Amazon Linux 2023 VM and make it
> production-ready: patched to a known release, hardened, with a real user they
> can log in as, running a containerized app. Let's do all of it from one
> workflow."

### 1. Launch the workflow
Launch **AMZL Daily Demo - Provision and Configure**. The single survey asks two
questions, both drop-downs:
- **VM size** (small / medium / large)
- **Target release** — a menu of tested AL2023 releases (or `latest`), defaulting
  to a **pinned point release** so every run lands on the same known build

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

A **Teardown (AWS)** job template runs `terraform destroy` and deregisters the
host from the `amzl-dailydemo` inventory. It's wired to a schedule —
**Nightly Teardown (6 PM AZ)** — so the demo EC2 instance is destroyed every
evening to avoid overnight cost. To reset on demand, just launch the teardown job
template. (It never deletes the shared S3 state bucket.)

> Optional talking point: "The same platform that stood this up tears it down on a
> schedule — cost control is automation too."
