# Loading AMZL-dailydemo into AAP

A step-by-step walkthrough that takes a **new Ansible user** from nothing to a
fully loaded Ansible Automation Platform (AAP) — every project, inventory,
credential, job template, and the 5-node workflow created as **config-as-code** —
and then launches the demo.

You run **one playbook** (`aap_config/load.yml`) from your workstation. It talks
to the AAP API and builds every object for you. You do **not** build an execution
environment, and you do **not** create the AWS state bucket by hand — both are
handled for you (details below).

> New to the whole flow? Read top to bottom once. Already have AAP + AWS from
> RHDP and just want the commands? Jump to [Step 4](#step-4-load-every-aap-object).

---

## What you'll end up with

Running `load.yml` creates all of this in AAP, in the **`IT Service Automation`**
organization:

| Object type | Names |
|-------------|-------|
| Project | `AMZL Daily Demo` (this Git repo) |
| Execution Environment | `AMZL Daily Demo - EE` → public image `quay.io/zigfreed/amzl-dailydemo-ee` |
| Inventories | `amzl-dailydemo` (the provisioned host), `amzl-dailydemo-control` (localhost jobs) |
| Credentials | `AMZL Daily Demo - AWS`, `- Machine`, `- Controller`, `- Secrets` |
| Job templates | `1 Provision VM (AWS)` · `2 Patch to Release` · `3 Security Hardening` · `4 Create devops User` · `5 Deploy Docker Webserver` · `Teardown (AWS)` |
| Workflow | **`AMZL Daily Demo - Provision and Configure`** (the 5-node story you launch) |
| Schedule | `Nightly Teardown (6 PM AZ)` — destroys the EC2 instance each evening to save cost |
| Settings | Pre-login banner + Automation Analytics enablement |

Re-running `load.yml` is **idempotent** — safe to run as many times as you like.

---

## Prerequisites at a glance

| # | You need | Where it comes from |
|---|----------|---------------------|
| 1 | An AAP 2.6 instance + an AWS "open environment" | RHDP catalog item (Step 1) |
| 2 | An Automation Hub offline token in `~/.ansible.cfg` | console.redhat.com (Step 2) |
| 3 | The CaC collections installed locally | `ansible-galaxy` (Step 3) |
| 4 | Your credentials exported as env vars | `docs/dev-environment.sh` (Step 3) |

The custom execution environment is **already built and published publicly**, so
there is nothing for you to build — AAP pulls it straight from quay.io. (Building
it is a maintainer task only; see [Rebuilding the EE](#appendix-rebuilding-the-ee-maintainers-only).)

---

## Step 1 — Order the RHDP environment

This demo targets the **Ansible Product Demos** catalog item on the Red Hat Demo
Platform (RHDP): [demo.redhat.com](https://demo.redhat.com). It provisions **AAP
2.6 on OpenShift** plus an **AWS open environment** in one order.

1. Log in to **demo.redhat.com** and order **Ansible Product Demos**.
2. Wait for the provisioning email / the catalog item to go green. Two things
   from it matter to you:
   - **AAP access** — the Controller/Gateway URL, the `admin` username, and its
     password. You'll find these on the order's detail page.
   - **AWS access** — the open environment gives you an **AWS Access Key ID** and
     **Secret Access Key** (and a region). These let Terraform create the EC2
     instance.

> Keep this page open — you'll copy these values into `dev-environment.sh` in
> Step 3. **Never commit any of them.**

---

## Step 2 — Put your Automation Hub token in `~/.ansible.cfg`

The CaC uses Red Hat **certified** collections (`infra.aap_configuration`,
`ansible.platform`, `ansible.controller`). Downloading them needs an offline
token in your **home** Ansible config.

```bash
# Only if you don't already have ~/.ansible.cfg:
cp ansible.cfg.example ~/.ansible.cfg
$EDITOR ~/.ansible.cfg     # paste your token where it says REPLACE_ME...
```

Get the token from
<https://console.redhat.com/ansible/automation-hub/token>. Paste the **same**
token into both the `rh_certified` and `rh_validated` galaxy_server sections.

> **Do not** create a project-local `ansible.cfg` in this repo. Ansible loads
> only one config file; a local one would shadow your home config and break the
> certified-content download. This repo intentionally ships none.

---

## Step 3 — Configure your credentials

All secrets resolve from **environment variables** at runtime — nothing
sensitive is ever committed. Copy the template and fill it in with the values
from Step 1.

```bash
cp docs/dev-environment.sh.example docs/dev-environment.sh   # gitignored
$EDITOR docs/dev-environment.sh
```

What to fill in:

| Variable | Value |
|----------|-------|
| `AAP_HOSTNAME` | The Controller URL from RHDP, **no trailing slash** |
| `AAP_CONTROLLER_PASSWORD` | The `admin` password from RHDP |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | From the AWS open environment |
| `AWS_DEFAULT_REGION` | Your open-env region (e.g. `us-east-1`) |
| `AWS_TF_STATE_BUCKET` | A **globally unique** S3 bucket name for Terraform state — you don't create it; node 1 does |
| `LINUX_SSH_PRIVATE_KEY` / `LINUX_SSH_PUBLIC_KEY` | An SSH key pair (defaults to `~/.ssh/id_rsa[.pub]`) |
| `DEVOPS_PASSWORD` | The password set on the provisioned `devops` user |

Automation Analytics (`REDHAT_SUBSCRIPTIONS_CLIENT_*`) is optional — leave blank
to skip uploads. Then load the variables into your shell:

```bash
source docs/dev-environment.sh
```

> **Why no `aws s3 mb`?** Earlier versions asked you to create the S3 state
> bucket by hand. You no longer do — node 1 of the workflow has an idempotent
> guard that creates the bucket if it's missing. Just pick a unique
> `AWS_TF_STATE_BUCKET` name. (Teardown never deletes it — it's long-lived shared
> state.)

---

## Step 4 — Load every AAP object

Install the CaC collections locally, then run the loader:

```bash
ansible-galaxy collection install -r aap_config/requirements.yml

source docs/dev-environment.sh && \
  ansible-playbook aap_config/load.yml 2>&1 | tee /tmp/load-$(date +%Y%m%d-%H%M%S).log
```

What happens:

- `load.yml` authenticates to AAP with **basic auth** (`AAP_CONTROLLER_USERNAME`
  / `AAP_CONTROLLER_PASSWORD`) — no token is minted, so there's nothing to clean
  up afterward.
- It hands every file in `aap_config/files/` to the
  `infra.aap_configuration.dispatch` role, which creates or updates each object.
- It's **idempotent** — re-run any time (e.g. after you change something in
  `aap_config/`).

A clean run ends with `failed=0`. Open AAP and you'll see the project, the four
credentials, both inventories, the six job templates, and the workflow.

---

## Step 5 — Sync the project, then launch the workflow

The project is set to **`scm_update_on_launch: false`** on purpose, so pull the
latest repo contents into AAP once after loading:

1. In AAP → **Automation Execution → Projects**, select **`AMZL Daily Demo`** and
   click **Sync**. (Or use `tools/sync_project.yml`.)
2. Go to **Templates**, open the workflow **`AMZL Daily Demo - Provision and
   Configure`**, and click **Launch**.
3. Answer the survey (VM size, target release). Watch the 5 nodes run in order:

   ```
   provision → patch → harden → devops_user → docker_web
   ```

   Any node failing stops the chain. When node 5 finishes, the provisioned host
   is serving the demo web page from a Docker container.

You only re-run `load.yml` when you change something under `aap_config/`. After
an ordinary code change, just **Sync** the project.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `ansible-galaxy` 401 / can't find `infra.aap_configuration` | Token missing/expired in `~/.ansible.cfg` (Step 2), or a stray project-local `ansible.cfg` is shadowing it. |
| `load.yml` 401 against AAP | `AAP_HOSTNAME` has a trailing slash, or the password is wrong. Re-`source` after editing. |
| Node 1 fails needing `AWS_TF_STATE_BUCKET` | You didn't `source docs/dev-environment.sh`, or the bucket name is blank. |
| Node 1 fails on `terraform`/AWS auth | AWS keys are wrong/expired, or `AWS_DEFAULT_REGION` doesn't match your open environment. |
| Objects load but the workflow uses stale playbooks | You skipped the project **Sync** in Step 5. |

---

## Appendix — Rebuilding the EE (maintainers only)

**New users can ignore this.** The execution environment is already public and
pinned (`quay.io/zigfreed/amzl-dailydemo-ee:v1.0.0`); AAP pulls it directly, so
loading the demo requires no build.

To cut a new EE version (maintainers):

```bash
ansible-builder build -f execution-environment.yml \
  --build-arg PYCMD=/usr/bin/python3.11 \
  -t quay.io/zigfreed/amzl-dailydemo-ee:<new-version>
```

`PYCMD=/usr/bin/python3.11` is required — the base image points
`/usr/bin/python3` at Python 3.9 (no pip), which breaks the assemble step.
`~/.ansible.cfg` must be a real file (not a symlink) because `ansible-builder`'s
`COPY` doesn't follow symlinks. After pushing, bump `ee_version` in
`aap_config/group_vars/all.yml` and re-run `load.yml`.
