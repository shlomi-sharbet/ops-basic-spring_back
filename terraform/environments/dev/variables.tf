variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "students"
}

variable "db_username" {
  type        = string
  description = "The username for the database master user"
  default     = "admin"
}

variable "db_password" {
  type        = string
  description = "The password for the database master user"
  default     = "Unix11!!"
  sensitive   = true
}

variable "init_db_sql_path" {
  type        = string
  description = "The path to the init-db.sql script for initializing the database"
  default     = ""
}

variable "app_db_user" {
  type        = string
  description = "The database user name for the app"
  default     = "students_staging_ecs"
}

variable "app_db_password" {
  type        = string
  description = "The database user password for the app"
  default     = "students_staging_ecs"
}

variable "bucket_name" {
  type        = string
  description = "The static website S3 bucket name"
  default     = "shlomi.backend.students"
}

variable "container_name" {
  type        = string
  description = "The ECS container name"
  default     = "student-ecs-container"
}

variable "cluster_name" {
  type        = string
  description = "The ECS Cluster name"
  default     = "ecs-stage-cluster"
}

variable "service_name" {
  type        = string
  description = "The ECS Service name"
  default     = "ecs-stage-service"
}
