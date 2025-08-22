# Network
module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  cidr_public_subnet = var.cidr_public_subnet
  aws_availability_zone = var.aws_availability_zone
  cidr_private_subnet = var.cidr_private_subnet 
  enable_dns_support = true
  enable_dns_hostnames = false
}

# Security Group
module "sg" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id
  allowed_ssh = var.allowed_ssh_cidr
}

# Public ALB (internet-facing)
module "alb" {
  source           = "./modules/alb"
  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id        = module.sg.alb_sg_id
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

# Key
module "bastion_key" {
  source = "./modules/keypair"
  key_name = "mye-bastion-key"
  public_key_path = "~/.ssh/mye-bastion-key.pub"
}

# Instances
module "bastion" {
  source = "./modules/ec2"
  name = "bastion"
  subnet_id = module.network.public_subnet_ids[0] //module.network.public_subnet_ids[count.index]
  instance_type = "t3.micro"
  key_name = module.bastion_key.key_name
  security_group_ids = [module.sg.bastion_sg_id]
  associate_public_ip = true
  ami_id = data.aws_ami.ubuntu_latest.id
  allocate_eip = true #Allocate elastic IP
}

module "nginx" {
  source = "./modules/ec2"
  count = length(module.network.private_subnet_ids)
  subnet_id = module.network.private_subnet_ids[count.index]
  instance_type = "t3.micro"
  key_name = module.bastion_key.key_name
  security_group_ids = [module.sg.nginx_sg_id] #[module.sg.nginx_sg_id]
  associate_public_ip = false # Change to false if utilizing private subnet 
  ami_id = data.aws_ami.ubuntu_latest.id  #Insert AMI ID
  
  name = "${var.vpc_name}-nginx-${count.index + 1}"
}

module "webapp" {
  source = "./modules/ec2"
  count = length(module.network.private_subnet_ids)
  subnet_id = module.network.private_subnet_ids[count.index]
  instance_type = "t3.micro"
  key_name = module.bastion_key.key_name
  security_group_ids = [module.sg.webapp_sg_id]
  associate_public_ip = false
  ami_id = data.aws_ami.ubuntu_latest.id

  name = "${var.vpc_name}-webapp-${count.index + 1}"
}

module "db" {
  #Postgres via Docker
  source = "./modules/ec2"
  count = length(module.network.private_subnet_ids)
  subnet_id = module.network.private_subnet_ids[count.index]
  instance_type = "t3.micro"
  key_name = module.bastion_key.key_name
  security_group_ids = [module.sg.db_sg_id]
  associate_public_ip = false
  ami_id = data.aws_ami.ubuntu_latest.id

  name = "${var.vpc_name}-db-${count.index + 1}"
}
