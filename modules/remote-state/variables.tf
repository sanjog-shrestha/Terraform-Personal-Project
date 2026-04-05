###############################################################################
# modules/remote-state/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}