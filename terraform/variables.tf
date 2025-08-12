# Network Module
variable "aws_region" {
  type = string
  description = "Region of the AWS"
}

variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "aws_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

# Security Group Module
variable "allowed_ssh_cidr" {
  type = string
  description = "Admin IP"  
}