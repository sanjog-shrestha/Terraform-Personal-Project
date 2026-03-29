###############################################################################
# modules/compute/outputs.tf
###############################################################################

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest version number of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "ami_id" {
  description = "AMI ID resolved by the data source (latest Amazon Linux 2023)."
  value       = data.aws_ami.al2023.id
}