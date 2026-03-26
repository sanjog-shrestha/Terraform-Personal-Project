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