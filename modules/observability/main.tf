###############################################################################
# modules/observability/main.tf
# CloudWatch Log Group
###############################################################################
# ── CloudWatch Log Group ──────────────────────────────────────────────────
# Central log destination for all application instances.
# Retention is configurable — shorter in dev to reduce storage cost.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project_name}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${var.project_name}-${var.environment}-log-group"
  }
}