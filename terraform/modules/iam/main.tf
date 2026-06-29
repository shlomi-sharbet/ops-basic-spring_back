# 1. Academy admin user
resource "aws_iam_user" "academy" {
  name = "academy"
}

# Attach AdministratorAccess policy to the user (as per instructions: "admin credentials")
resource "aws_iam_user_policy_attachment" "academy_admin" {
  user       = aws_iam_user.academy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create programmatic access keys
resource "aws_iam_access_key" "academy_keys" {
  user = aws_iam_user.academy.name
}

# 2. S3 access user
resource "aws_iam_user" "s3_user" {
  name = "s3_user"
  path = "/"

  tags = {
    Name = "s3_user"
  }
}

# Create programmatic access keys for S3 user
resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

# Attach S3 Full Access policy to the S3 user
resource "aws_iam_user_policy_attachment" "s3_full_access" {
  user       = aws_iam_user.s3_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
