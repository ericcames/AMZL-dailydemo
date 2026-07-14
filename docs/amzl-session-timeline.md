---
doc-type: reference
status: active
owner: jason
updated: 2026-07-14
---

# AMZL-dailydemo — Session Timeline

## Phase 1 — Foundation — stand up every layer

1. Scaffold repo — community standards + governance
2. Add Execution Environment definition
3. Add Terraform stack for Amazon Linux 2023
4. Add workflow playbooks and roles (nodes 1–5)
5. Add AAP config-as-code (5 job templates + 5-node workflow)
6. Add dev-environment template and demo talk track
7. Fix EE build: require `PYCMD=/usr/bin/python3.11`
8. Roadmap: EE built + pushed public; mark load as NEXT

## Phase 2 — Config-as-code & platform baseline

9. Baseline settings as code: pre-login banner + Automation Analytics
10. Provision node: guard that ensures the Terraform state bucket exists
11. Survey: make Target release a dropdown of recent AL2023 releases

## Phase 3 — Debug to green — the real engineering

12. Fix role resolution (move roles under `playbooks/`) + drop on-launch sync
13. Project CaC: explicitly disable `scm_update_on_launch`
14. Fix devops user: hash password on target, not in the EE
15. Roadmap: mark Phase 5 in progress; log decisions
16. Add `tools/` operator helpers: project sync and job fetch
17. Fix Docker SDK install: virtualenv to avoid RPM conflict on AL2023

## Phase 4 — Operations, polish & docs to tested state

18. Enhance webserver page: Ansible logo, release version, URL in job log
19. Add nightly teardown: job template + 6 PM Arizona schedule
20. Replace inline SVG with AAP logo PNG from brand assets
21. Add control inventory for localhost-only job templates
22. Fix teardown: guard host deregistration against empty Terraform state
23. Pin AMI to AL2023 2023.12.20260608 so patching demo can move forward
24. Add new-user AAP load guide; correct README/ROADMAP to tested state
25. Fix broken in-page anchor links in loading-aap guide
26. Update demo talk track to tested state
