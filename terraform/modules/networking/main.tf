# Variable
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "aws_availability_zone" {}
variable "cidr_private_subnet" {}


# Setup VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr    
    tags = {
      Name = var.vpc_name
    }
}

# Setup Public Subnet
resource "aws_subnet" "public" {
  count                   = length(var.cidr_public_subnet)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_public_subnet[count.index]
  availability_zone       = var.aws_availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
}

# Setup Private Subnet
resource "aws_subnet" "private" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private_subnet[count.index]
  availability_zone = var.aws_availability_zone[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" #0.0.0.0/0 means accessible by the internet
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Public Subnet Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Private Subnet Association
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
