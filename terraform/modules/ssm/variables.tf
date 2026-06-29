variable "rds_endpoint" {
  type        = string
  description = "The connection endpoint of the RDS database"
}

variable "db_user" {
  type        = string
  description = "The username for the students application"
  default     = "students_staging_ecs"
}

variable "db_password" {
  type        = string
  description = "The password for the students application"
  default     = "students_staging_ecs"
}
