output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "iam_user_name" {
  value = module.iam.iam_user_name
}

output "iam_access_key" {
  value = module.iam.iam_access_key
}

output "iam_secret_key" {
  value     = module.iam.iam_secret_key
  sensitive = true
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_address" {
  value = module.rds.rds_address
}

output "springboot_lb_dns_name" {
  value = module.ecs.springboot_lb_dns_name
}

output "s3_user_access_key" {
  value = module.iam.s3_user_access_key
}

output "s3_user_secret_key" {
  value     = module.iam.s3_user_secret_key
  sensitive = true
}

output "bucket_website_endpoint" {
  value = module.s3.bucket_website_endpoint
}

output "cloudfront_domain_name" {
  value       = module.cloudfront.cloudfront_domain_name
  description = "The domain name of the CloudFront distribution"
}

