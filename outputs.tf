###############################################################################
# outputs.tf – Root outputs
###############################################################################

output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "project_name" {
  description = "Project name."
  value       = var.project_name
}

output "environment" {
  description = "Active environment."
  value       = var.environment
}

# ── Networking ────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = module.networking.nat_gateway_id
}

# ── Security ──────────────────────────────────────────────────────────────
output "app_security_group_id" {
  description = "ID of the application security group."
  value       = module.security.app_security_group_id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group."
  value       = module.security.bastion_security_group_id
}

output "ec2_ssm_instance_profile_name" {
  description = "EC2 SSM instance profile name."
  value       = module.security.ec2_ssm_instance_profile_name
}

# ── Compute ───────────────────────────────────────────────────────────────
output "launch_template_id" {
  description = "ID of the launch template."
  value       = module.compute.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template."
  value       = module.compute.launch_template_latest_version
}

output "ami_id" {
  description = "AMI ID in use (latest Amazon Linux 2023)."
  value       = module.compute.ami_id
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = module.compute.instance_id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = module.compute.instance_private_ip
}