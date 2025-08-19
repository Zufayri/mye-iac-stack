# Variables
variable "vpc_id" {type = string}
variable "allowed_ssh" {type = string}

# ALB Security Group (Inbound:80,443 , Outbound:ALL)
resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    vpc_id = var.vpc_id
    description = "ALB SG: Inbound:80,443 , Outbound:ALL "

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

# EC2/Nginx Security Group
resource "aws_security_group" "nginx_sg" {
    name = "nginx-sg"
    vpc_id = var.vpc_id
    description = "Nginx SG"

    # Firewall Rules
    ingress {
        description = "Allow HTTP from ALB"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id] #call from terraform resource named alb_sg
        }

    # SECURITY NOTE: SSH is currently open to the internet (0.0.0.0/0) for convenience. 
    # For production, it is strongly recommended to use a bastion host:
    # - Update `allowed_ssh_cidr` in root variables to the bastion host's SG or IP.
    # - Place this server in a private subnet.
    ingress {
        description = "Allow SSH from allowed_ssh IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.allowed_ssh]
        }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    tags = {Name = "nginx-sg"}

}

# EC2/Webapp Security Group
resource "aws_security_group" "webapp_sg" {
    name = "webapp-sg"
    vpc_id = var.vpc_id
    description = "Webapp-SG: Inbound:5000 , Outbound:ALL"

    #Firewall rules
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        security_groups = [aws_security_group.nginx_sg.id] #call from terraform resource named nginx_sg
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {Name = "webapp-sg"}
}



