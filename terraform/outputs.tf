output "linux_inventory" {
  description = "Linux VM inventory data for AAP host registration."
  value = {
    host           = aws_instance.amzl.public_dns
    ansible_host   = aws_instance.amzl.public_ip
    ansible_user   = var.linux_admin_username
    vm_name        = local.vm_name
    instance_id    = aws_instance.amzl.id
    vm_size_tier   = var.vm_size_tier
    vm_size_chosen = local.instance_type
  }
}
