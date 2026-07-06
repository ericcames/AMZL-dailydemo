# tools/

Local operator helpers for the AMZL daily demo. They run from your workstation
(not from AAP) and read AAP creds from the environment — `source
docs/dev-environment.sh` first.

| Playbook | Purpose |
|----------|---------|
| `sync_project.yml` | Trigger the AAP project sync and wait. The project runs with `scm_update_on_launch: false`, so run this after pushing playbook/role changes before launching the workflow. |
| `get_job.yml` | Fetch a job's status + full stdout via the API for debugging a failed node. `-e job_id=<n>`; stdout is written to `/tmp/amzl-job-<n>-stdout.txt`. |

```bash
source docs/dev-environment.sh
ansible-playbook tools/sync_project.yml
ansible-playbook tools/get_job.yml -e job_id=18
```
