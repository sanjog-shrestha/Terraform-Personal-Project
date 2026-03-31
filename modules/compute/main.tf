###############################################################################
# modules/compute/main.tf
###############################################################################

# ---Fetch the latest Amazon Linux 2023 AMI automatically ----------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ---Launch Template ----------------------------------------------
resource "aws_launch_template" "this" {
  name        = "${var.project_name}-${var.environment}-lt"
  description = "Launch template for ${var.project_name} ${var.environment} instances"

  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = [var.security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
    project_name = var.project_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-${var.environment}-volume"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-lt"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---EC2 instances ----------------------------------------------
resource "aws_instance" "this" {
  subnet_id = var.private_subnet_id

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version


  }

  tags = {
    Name = "${var.project_name}-${var.environment}-instance"
  }

  lifecycle {
    ignore_changes = [launch_template]
  }
}

# ---Auto Scaling Group (ASG) ----------------------------------------------
resource "aws_autoscaling_group" "this" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  health_check_type         = "EC2"
  health_check_grace_period = 120

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [launch_template]
  }
}