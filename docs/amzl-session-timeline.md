---
doc-type: reference
status: active
owner: jason
updated: 2026-07-14
---

# AMZL-dailydemo — Session Timeline

## Cloud Use Cases

The customer's use case — the four cloud operations this demo automates end to
end:

- **Patch our AMZL2023 VMs to a certain release**
- **Create users** — add to the sudoers group, set the password, and add an SSH
  public key
- **Initial system configuration** — security best practices, chrony and other
  utils, admin user setup, initial patching
- **Deploy a Docker app** — ensure the user belongs to the docker group; pull and
  deploy a Docker image

A single **5-node workflow** (`AMZL Daily Demo - Provision and Configure`)
satisfies all four — provision → patch → harden → create user → deploy Docker:

![AMZL Daily Demo — workflow visualizer (start → provision → patch)](images/workflow-visualizer.png)

![AMZL Daily Demo — workflow visualizer (harden → devops_user → docker_web)](images/workflow-visualizer-2.png)

### Discovery

Questions to explore with the customer, to anchor the demo to their reality:

- **Why this use case?** What triggered it — a new cloud footprint, an
  audit/compliance driver, a migration off hand-built VMs, developer-onboarding
  pain?
- **What does it look like today?** How are AMZL2023 VMs currently provisioned,
  patched, hardened, and handed to developers — what's manual, what's scripted,
  who owns each step, and where does it break down?

_(Capture the customer's answers here.)_

## Phase 1 — Foundation — stand up every layer

1. Scaffold repo — community standards + governance
   - In AWX, the platform holds your config — in AAP, the Git repo IS the system of record
   - Without structure (CODEOWNERS, linting, PR templates), teams lose the governance AAP is built around
   - This is the single biggest mindset shift: if it's not in the repo, it doesn't exist reproducibly

2. Add Execution Environment definition
   - Replaces "ssh into the control node and pip install" — the #1 source of drift in AWX environments
   - EEs are container images: pinned dependencies, portable across dev/stage/prod
   - AWX users who skip this will fight dependency mismatches on every upgrade

3. Add Terraform stack for Amazon Linux 2023

4. Add workflow playbooks and roles (nodes 1–5)
   - AAP workflows chain job templates — each node is a discrete, testable, reusable unit
   - AWX users often put everything in one big playbook; AAP rewards decomposition

5. Add AAP config-as-code (5 job templates + 5-node workflow)
   - Every AAP object — credentials, projects, templates, workflows — defined in YAML, not clicked in the UI
   - Promotion across environments becomes a Git merge instead of manually recreating objects
   - AWX users who configure via UI will lose reproducibility and audit trail

6. Add dev-environment template and demo talk track
7. Fix EE build: require `PYCMD=/usr/bin/python3.11`
8. Roadmap: EE built + pushed public; mark load as NEXT

## Phase 2 — Config-as-code & platform baseline

9. Baseline settings as code: pre-login banner + Automation Analytics
   - Even platform-level settings (banners, analytics opt-in) are code — nothing is UI-only anymore
   - This is what "everything as code" actually means in AAP vs. AWX

10. Provision node: guard that ensures the Terraform state bucket exists

11. Survey: make Target release a dropdown of recent AL2023 releases
    - Surveys in AAP are defined in the CaC YAML — versioned, reviewable, consistent across environments
    - In AWX, survey changes are UI clicks with no audit trail

![Launch survey — VM size and target AL2023 release as config-as-code dropdowns](images/launch-survey.png)

## Phase 3 — Debug to green — the real engineering

12. Fix role resolution (move roles under `playbooks/`) + drop on-launch sync
    - AAP's project structure expectations differ from AWX — role paths must align with the repo layout
    - This is a common migration gotcha: what worked in AWX breaks silently in AAP

13. Project CaC: explicitly disable `scm_update_on_launch`
    - AAP gives you fine-grained Git sync control per project — AWX defaults mask this
    - Understanding when the platform pulls from Git prevents unexpected mid-run changes

14. Fix devops user: hash password on target, not in the EE
    - EEs are immutable containers — anything that depends on target state must run on the target
    - AWX users used to control-node execution will hit this pattern repeatedly

15. Roadmap: mark Phase 5 in progress; log decisions
16. Add `tools/` operator helpers: project sync and job fetch

17. Fix Docker SDK install: virtualenv to avoid RPM conflict on AL2023
    - EEs isolate Python dependencies — but the target node still needs its own dependency management
    - virtualenv on target prevents the RPM-vs-pip conflicts that AWX users hack around with sudo pip

## Phase 4 — Operations, polish & docs to tested state

18. Enhance webserver page: Ansible logo, release version, URL in job log
19. Add nightly teardown: job template + 6 PM Arizona schedule
    - Schedules are config-as-code too — repeatable, version-controlled, no UI-only cron jobs
    - AWX users manually create schedules per environment; AAP loads them from the repo

20. Replace inline SVG with AAP logo PNG from brand assets

21. Add control inventory for localhost-only job templates
    - AAP separates "where to run" from "what to run" more strictly than AWX
    - Localhost jobs need an explicit control inventory — AWX was more forgiving here

22. Fix teardown: guard host deregistration against empty Terraform state
23. Pin AMI to AL2023 2023.12.20260608 so patching demo can move forward

24. Add new-user AAP load guide; correct README/ROADMAP to tested state
    - Onboarding docs in the repo mean any team member can stand up the full environment from scratch
    - In AWX, tribal knowledge lives in people's heads; AAP pushes it into the repo

25. Fix broken in-page anchor links in loading-aap guide
26. Update demo talk track to tested state

## Demo — the running result

The workflow completing successfully, and the app it deploys:

![Workflow job "AMZL Daily Demo - Provision and Configure" — completed successfully in 6m 18s](images/workflow-run-success.png)

![Deployed webserver — the daily-demo page served from the Docker container the workflow pulled and deployed](images/webserver-page.png)
