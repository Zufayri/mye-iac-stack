output "instance_id" { value = aws_instance.main.id }
output "public_ip" { value = aws_instance.main.public_ip }
output "private_ip" { value = aws_instance.main.private_ip }
output "eip" { value = var.allocate_eip ? aws_eip.main[0].public_ip : ""}
