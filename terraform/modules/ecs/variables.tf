variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository"
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
