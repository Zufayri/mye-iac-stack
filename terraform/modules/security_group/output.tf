output "alb_sg_id" { value = aws_security_group.alb_sg.id }
output "nginx_sg_id" { value = aws_security_group.nginx_sg.id }
output "webapp_sg_id" { value = aws_security_group.webapp_sg.id }
