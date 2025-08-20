output "key_name" {
  value = length(var.public_key_path) > 0 ? aws_key_pair.main[0].key_name : var.key_name
}