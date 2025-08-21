# Variables
variable "name" {type =string}
variable "subnet_id" {type=string}
variable "instance_type" {type= string}
variable "key_name" {type=string}
variable "security_group_ids" {type=list(string)}
variable "associate_public_ip" {
    type = bool
    default = false
}
variable "ami_id" {type = string}
variable "allocate_eip" {
    type = string
    default = "false"
}


resource "aws_instance" "main" {
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = var.associate_public_ip
    key_name = var.key_name
    ami = var.ami_id 
    tags = {Name = var.name}
}

