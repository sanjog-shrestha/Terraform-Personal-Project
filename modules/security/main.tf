###############################################################################
# modules/security/main.tf
###############################################################################

# ----- Lock down the VPC default security group ----------------------------------
resource "aws_default_security_group" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-default-sg-locked"
  }
}

# ----- Application Security Group ----------------------------------
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Application tier - HTTP/HTTPS inbound, all outbound"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-egress"
  }
}

# ----- Bastion Security Group ----------------------------------
resource "aws_security_group" "bastion" {
  count       = var.create_bastion_sg ? 1 : 0
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Bastion host - SSH inbound from trusted CIDR only"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  count             = var.create_bastion_sg ? 1 : 0
  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow SSH from trustd CIDR"
  cidr_ipv4         = var.trusted_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_all_out" {
  count             = var.create_bastion_sg ? 1 : 0
  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-egress"
  }
}

# ----- IAM Role for EC2 (SSM access) ----------------------------------
resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ----- IAM Instance Profile ----------------------------------
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  }
}