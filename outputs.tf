output "servers" {
  value = { for i in aws_instance.instance : i.tags.Name => i.public_ip }
}
