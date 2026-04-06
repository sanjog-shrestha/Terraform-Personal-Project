###############################################################################
# terraform.tfvars – Default variable values 
###############################################################################
aws_region   = "eu-west-2"
project_name = "my-project"
environment  = "dev"

# ----- Networking ----------------------------------
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
availability_zones   = ["eu-west-2a", "eu-west-2b"]
enable_nat_gateway   = true

# ----- Security ----------------------------------
create_bastion_sg = true
trusted_ssh_cidr  = "0.0.0.0/0"

# ----- Compute ----------------------------------
instance_type              = "t3.micro"
root_volume_size           = 30
enable_detailed_monitoring = false
asg_min_size               = 1
asg_max_size               = 3
asg_desired_capacity       = 1

# ----- Observability ----------------------------------
log_retention_days = 14
alarm_email        = "sanjogstudy@gmail.com"
scaling_cooldown   = 120
cpu_high_threshold = 70
cpu_low_threshold  = 20