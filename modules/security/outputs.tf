###############################################################################
# modules/security/outputs.tf
###############################################################################

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = aws_security_group.app.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group (null if not created)."
  value       = var.create_bastion_sg ? aws_security_group.bastion[0].id : null
}

output "ec2_ssm_role_arn" {
  description = "ARN of the EC2 SSM IAM role."
  value       = aws_iam_role.ec2_ssm.arn
}

output "ec2_ssm_instance_profile_name" {
  description = "Name of the EC2 SSM instance profile."
  value       = aws_iam_instance_profile.ec2_ssm.name
}