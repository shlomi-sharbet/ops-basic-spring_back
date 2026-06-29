output "ecr_repository_url" {
  value       = aws_ecr_repository.students_ecs.repository_url
  description = "The URL of the ECR repository"
}
