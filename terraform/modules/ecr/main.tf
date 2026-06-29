resource "aws_ecr_repository" "students_ecs" {
  name                 = "students-ecs"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
