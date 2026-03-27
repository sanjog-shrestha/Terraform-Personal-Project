############################################################
# outputs.tf - Root outputs
############################################################

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

# ----- Networking ----------------------------------
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