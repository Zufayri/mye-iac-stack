output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  value = [for nat in aws_nat_gateway.nat : nat.id]
  //value  = aws_nat_gateway.nat.id
}

output "nat_gateway_eips" {
  value = [for eip in aws_eip.nat : eip.public_ip]
}