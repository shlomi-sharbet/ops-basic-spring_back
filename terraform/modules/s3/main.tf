resource "aws_s3_bucket" "static_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket     = aws_s3_bucket.static_bucket.id
  depends_on = [aws_s3_bucket.static_bucket]

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket     = aws_s3_bucket.static_bucket.id
  depends_on = [aws_s3_bucket.static_bucket]

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.static_bucket.id
  depends_on = [
    aws_s3_bucket.static_bucket,
    aws_s3_bucket_public_access_block.public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_bucket.arn}/*"
      }
    ]
  })
}
