# Variables
variable "vpc_id" {type = string}
variable "allowed_ssh" {type = string}

# EC2-Bastion: SSH from internet/allowed ip
resource "aws_security_group" "bastion_sg" {
    name = "bastion-sg"
    vpc_id = var.vpc_id
    description = "Bastion SG: SSH Entry"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.allowed_ssh]
    }
}

# ALB : HTTP/HTTPS from internet
resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    vpc_id = var.vpc_id
    description = "ALB SG: HTTP/HTTPS from internet"

    # Firewall Rules
    ingress {
        description = "Allow HTTP from everywhere"
        from_port = 80 
        to_port = 80 
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow HTTPS from everywhere"
        from_port = 443 
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow outgoing request"
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { Name = "alb-sg"} 
}

# EC2-Nginx: allow 80 from ALB; SSH only via bastion
resource "aws_security_group" "nginx_sg" {
    name = "nginx-sg"
    vpc_id = var.vpc_id
    description = "Nginx SG: 80 from ALB; SSH via bastion"

    # Firewall Rules
    ingress {
        description = "Allow HTTP from ALB"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id] #call from terraform resource named alb_sg
        }
    ingress {
        description = "Allow SSH from allowed_ssh IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id] //["x.x.x.x/32"]
        }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } 
    tags = {Name = "nginx-sg"}
}

# EC2-Webapp: Allow 5000 from nginx; SSH via bastion
resource "aws_security_group" "webapp_sg" {
    name = "webapp-sg"
    vpc_id = var.vpc_id
    description = "Webapp-SG: Allow 5000 from nginx; SSH via bastion"

    #Firewall rules
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        security_groups = [aws_security_group.nginx_sg.id]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {Name = "webapp-sg"}
}

# EC2-DB: Allow 5432 from webapp; SSH via bastion
resource "aws_security_group" "db_sg" {
    name = "db-sg"
    vpc_id = var.vpc_id

    ingress{
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.webapp_sg.id]
    }
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {Name="db-sg"}
} 



