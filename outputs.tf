output "web" {
  value = { for i in aws_instance.web : i.tags.Name => i.public_ip }
}

output "app" {
  value = { for i in aws_instance.app : i.tags.Name => i.public_ip }
}

output "z_load_balancers" {
  value = { for i in aws_lb.alb : i.name => i.dns_name }
}

