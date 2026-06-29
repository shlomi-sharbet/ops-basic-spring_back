module "ecr" {
  source = "../../modules/ecr"
}

module "rds" {
  source           = "../../modules/rds"
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  init_db_sql_path = var.init_db_sql_path != "" ? var.init_db_sql_path : "${path.module}/init-db.sql"
}

module "ssm" {
  source       = "../../modules/ssm"
  rds_endpoint = module.rds.rds_endpoint
  db_user      = var.app_db_user
  db_password  = var.app_db_password
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = var.bucket_name
}

module "iam" {
  source = "../../modules/iam"
}

module "ecs" {
  source             = "../../modules/ecs"
  ecr_repository_url = module.ecr.ecr_repository_url
  container_name     = var.container_name
  cluster_name       = var.cluster_name
  service_name       = var.service_name
}

module "cloudfront" {
  source = "../../modules/cloudfront"
  # bucket_website_endpoint = module.s3.bucket_website_endpoint
  bucket_website_endpoint = "shlomi.backend.students.s3-website.localhost.localstack.cloud:4566"
  springboot_lb_dns_name  = module.ecs.springboot_lb_dns_name
}

