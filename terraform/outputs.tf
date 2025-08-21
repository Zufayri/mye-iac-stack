//output "alb_dns_name"      { value = module.alb.alb_dns_name }
output "bastion_public_ip" { value = module.bastion.public_ip }
output "bastion_eip"       { value = module.bastion.eip}
output "nginx_private_ip"  { value = module.nginx.private_ip }
output "webapp_private_ip" { value = module.webapp.private_ip }
output "db_private_ip"     { value = module.db.private_ip }
