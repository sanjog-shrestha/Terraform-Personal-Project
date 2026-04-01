###############################################################################
# modules/observability/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs before automatic deletion."
  type        = number
  default     = 14
}