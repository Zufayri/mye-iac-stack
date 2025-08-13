module "network" {
    source = "./modules/network"
    vpc_cidr = var.vpc_cidr
    vpc_name = var.vpc_name
    cidr_public_subnet = var.cidr_public_subnet
    aws_availability_zone = var.aws_availability_zone
    cidr_private_subnet = var.cidr_private_subnet 
}

module "sg" {
    source = "./modules/security_group"
    vpc_id = module.network.vpc_id
    allowed_ssh = var.allowed_ssh_cidr
}

