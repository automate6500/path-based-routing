output "servers" {
  value = { for i in aws_instance.web : i.tags.Name => i.public_ip }
}
