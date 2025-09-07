output "public_instance_ids" {
  value = aws_instance.public[*].id
}

output "public_instance_ips" {
  value = aws_instance.public[*].public_ip
}

output "private_instance_id" {
  value = aws_instance.private.id
}

output "private_instance_ip" {
  value = aws_instance.private.private_ip
}

output "bastion_host_ip" {
  description = "Public IP of the first public instance to be used as a bastion"
  value       = aws_instance.public[0].public_ip
}