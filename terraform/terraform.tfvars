# VPC and Subnet
aws_region = "us-east-1"
vpc_cidr = "11.0.0.0/16"
vpc_name = "myvpc"
cidr_public_subnet = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet = ["11.0.3.0/24", "11.0.4.0/24"]
aws_availability_zone = ["us-east-1a", "us-east-1b"]

# Security Group
allowed_ssh_cidr = "0.0.0.0/0"  # Update with admin IP / Bastion Host 
