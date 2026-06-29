output "springboot_lb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.springboot_lb.dns_name
}
