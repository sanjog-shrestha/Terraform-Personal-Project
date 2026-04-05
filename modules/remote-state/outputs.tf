###############################################################################
# modules/remote-state/outputs.tf
###############################################################################

output "bucket_name" {
  description = "Name of the S3 state bucket — copy into the backend block in main.tf."
  value       = aws_s3_bucket.state.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB lock table — copy into the backend block in main.tf."
  value       = aws_dynamodb_table.lock.name
}