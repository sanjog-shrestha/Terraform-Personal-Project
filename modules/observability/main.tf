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

# ── SNS Topic ─────────────────────────────────────────────────────────────
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"

  tags = {
    Name = "${var.project_name}-${var.environment}-alarms"
  }
}

# ── SNS Email Subscription (optional) ─────────────────────────────────────
resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ── ASG Scaling Policy — Scale Out ────────────────────────────────────────
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = var.asg_name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scaling_cooldown
}

# ── ASG Scaling Policy — Scale In ────────────────────────────────────────
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = var.asg_name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scaling_cooldown
}