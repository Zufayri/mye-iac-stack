# Network
module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  cidr_public_subnet = var.cidr_public_subnet
  aws_availability_zone = var.aws_availability_zone
  cidr_private_subnet = var.cidr_private_subnet 
}

# Security Group
module "sg" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id
  allowed_ssh = var.allowed_ssh_cidr
}

# AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instances
module "nginx" {
  source = "./modules/ec2"
  name = "nginx"
  subnet_id = module.network.private_subnet_ids[0]
  instance_type = "t3.micro"
  key_name = "my-key"  # This is existing manually created key. Change its name if required.
  security_group_ids = [module.sg.nginx_sg_id] #[module.sg.nginx_sg_id]
  associate_public_ip = true # Change to false if utilizing private subnet 
  ami_id = data.aws_ami.ubuntu_latest.id  #Insert AMI ID
}

module "webapp" {
  source = "./modules/ec2"
  name = "webapp"
  subnet_id = module.network.private_subnet_ids[0]
  instance_type = "t3.micro"
  key_name = "my-key"
  security_group_ids = [module.sg.webapp_sg_id]
  associate_public_ip = false
  ami_id = data.aws_ami.ubuntu_latest.id
}


