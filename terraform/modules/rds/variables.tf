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
  sensitive   = true
}

variable "init_db_sql_path" {
  type        = string
  description = "The path to the init-db.sql script for initializing the database"
}
