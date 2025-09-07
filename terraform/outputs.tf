output "bastion_host_ip" {
  description = "Public IP of the bastion host"
  value       = module.ec2_instances.bastion_host_ip
}

output "private_instance_ip" {
  description = "Private IP of the instance in the private subnet"
  value       = module.ec2_instances.private_instance_ip
}