# Variable
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "aws_availability_zone" {}
variable "cidr_private_subnet" {}
variable "enable_dns_support" {default = true}
variable "enable_dns_hostnames" {default = false}


# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr    
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = {Name = var.vpc_name}
}

# Subnets
resource "aws_subnet" "public" {
  count                   = length(var.cidr_public_subnet)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_public_subnet[count.index]
  availability_zone       = var.aws_availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {Name = "${var.vpc_name}-public-${count.index + 1}"}
}

resource "aws_subnet" "private" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private_subnet[count.index]
  availability_zone = var.aws_availability_zone[count.index]

  tags = {Name = "${var.vpc_name}-private-${count.index + 1}"}
}



# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {Name = "${var.vpc_name}-igw"}
}

# NAT Gateway (for private egress)
# Elastic IP Allocation
resource "aws_eip" "nat" {
  count = length(aws_subnet.public)  #remove if making one or place to one specific subnet only
  domain = "vpc"
  tags = {Name="nat-eip-${count.index}"}
}

resource "aws_nat_gateway" "nat" {
  count          = length(aws_subnet.public) #remove if making one or place to one specific subnet only
  subnet_id      = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id  #Link elastic IP to NAT
  tags = {Name = "${var.vpc_name}-nat-gw-${count.index+1}"}
  depends_on = [ aws_internet_gateway.igw ]
}



# Public Route Table and Subnet Association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  count = length(aws_subnet.public)

  route {
    cidr_block = "0.0.0.0/0" #0.0.0.0/0 means accessible by the internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {Name = "${var.vpc_name}-public-rt-${count.index + 1}"}
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


# Private Route Table and Subnet Association
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  # 1 NAT per private subnet
  count = length(aws_nat_gateway.nat) #remove if making one or place to one specific subnet only

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_nat_gateway.nat[count.index].id  #aws_nat_gateway.nat[0].id
  }

  tags = {Name = "${var.vpc_name}-private-rt-${count.index + 1}"}
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
