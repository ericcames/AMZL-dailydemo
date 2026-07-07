# ---------------------------------------------------------------------------
# Amazon Linux 2023 AMI — pinned to a specific release so the patch playbook
# can demonstrate "dnf update --releasever=<newer>" moving the host forward.
# Update var.al2023_release in variables.tf to change the baseline.
# ---------------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-${var.al2023_release}*-kernel-*-x86_64"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
