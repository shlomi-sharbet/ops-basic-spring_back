resource "aws_ssm_parameter" "students_staging_ecs" {
  name      = "students_staging_ecs"
  type      = "String"
  value     = "jdbc:mysql://${var.rds_endpoint}/students_stage_ecs"
  overwrite = true
}

resource "aws_ssm_parameter" "students_staging_ecs_user" {
  name      = "students_staging_ecs_user"
  type      = "String"
  value     = var.db_user
  overwrite = true
}

resource "aws_ssm_parameter" "students_staging_ecs_password" {
  name      = "students_staging_ecs_password"
  type      = "String"
  value     = var.db_password
  overwrite = true
}
