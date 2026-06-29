output "iam_user_name" {
  value = aws_iam_user.academy.name
}

output "iam_access_key" {
  value = aws_iam_access_key.academy_keys.id
}

output "iam_secret_key" {
  value     = aws_iam_access_key.academy_keys.secret
  sensitive = true
}

output "s3_user_access_key" {
  description = "Access Key for s3_user"
  value       = aws_iam_access_key.s3_user_key.id
}

output "s3_user_secret_key" {
  description = "Secret Key for s3_user"
  value       = aws_iam_access_key.s3_user_key.secret
  sensitive   = true
}
