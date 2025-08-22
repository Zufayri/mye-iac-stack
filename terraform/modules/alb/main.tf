# Variables
variable "vpc_id"           { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id"        { type = string }

resource "aws_lb" "alb" {
  name               = "mye-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]
  tags = { Name = "mye-alb" }
}

resource "aws_lb_target_group" "tg" {
  name     = "mye-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path              = "/health"
    protocol          = "HTTP"
    matcher           = "200-399"
    interval          = 30
    timeout           = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
