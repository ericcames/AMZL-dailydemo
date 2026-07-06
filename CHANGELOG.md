# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project aims
to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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
