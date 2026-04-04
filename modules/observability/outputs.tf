###############################################################################
# modules/observability/outputs.tf
###############################################################################

output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.app.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.app.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS alarm topic."
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "Name of the SNS alarm topic."
  value       = aws_sns_topic.alarms.name
}

output "scale_out_policy_arn" {
  description = "ARN of the scale-out ASG policy — referenced by the CPU high alarm in Phase 5d."
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale-in ASG policy — referenced by the CPU low alarm in Phase 5d."
  value       = aws_autoscaling_policy.scale_in.arn
}

output "cpu_high_alarm_arn" {
  description = "ARN of the CPU high CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "ARN of the CPU low CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}