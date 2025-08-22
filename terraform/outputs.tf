output "alb_dns_name"      { value = module.alb.alb_dns_name }
output "bastion_public_ip" { value = module.bastion.public_ip }
output "bastion_eip"       { value = module.bastion.eip}
output "nginx_private_ips"  { value = [for inst in module.nginx : inst.private_ip] }
output "webapp_private_ips" { value = [for inst in module.webapp : inst.private_ip] }
output "db_private_ips"     { value = [for inst in module.db : inst.private_ip] }


