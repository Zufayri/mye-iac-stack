# Variables
variable "vpc_id" {type = string}
variable "public_subnet_id" {type = string}
variable "alb_sg_id" {type = string}

resource "aws_lb" "alb" {
    name = "my-alb"
    load_balancer_type = "application"
    subnets = [var.public_subnet_id]
    security_groups = [var.alb_sg_id]
    tags =  {Name = "my-alb"}
}

