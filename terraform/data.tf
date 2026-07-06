# ---------------------------------------------------------------------------
# Amazon Linux 2023 AMI — resolved from the AWS-published SSM public parameter,
# so we always get the latest AL2023 x86_64 image for the region without
# hardcoding an AMI id. (The "patch to a certain release" story is handled at the
# OS level by the patch node, not by pinning the AMI.)
# ---------------------------------------------------------------------------
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}
