
output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.awspro_bastion.id
}

output "bastion_public_ip" {
  description = "Bastion public IP address"
  value       = aws_instance.awspro_bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.awspro_bastion_sg.id
}
