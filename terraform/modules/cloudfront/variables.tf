variable "bucket_website_endpoint" {
  type        = string
  description = "The S3 bucket website endpoint for the frontend origin"
}

variable "springboot_lb_dns_name" {
  type        = string
  description = "The DNS name of the Spring Boot ECS load balancer for the backend origin"
}

variable "domain_name" {
  type        = string
  description = "The root domain name for Route 53"
  default     = "shlomi.com"
}

variable "subdomain" {
  type        = string
  description = "The subdomain for the alternate domain name"
  default     = "ecs.shlomi.com"
}
