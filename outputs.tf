output "web" {
  value = { for i in aws_instance.web : i.tags.Name => i.public_ip }
}

output "app" {
  value = { for i in aws_instance.app : i.tags.Name => i.public_ip }
}

output "z_external" {
  value = aws_lb.ext.dns_name
}

