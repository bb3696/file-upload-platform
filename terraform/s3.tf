resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "file-upload-frontend-tony"
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontAccess",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::file-upload-frontend-tony/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::896520308122:distribution/${aws_cloudfront_distribution.frontend_cdn.id}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "frontend_public_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "upload_bucket" {
  bucket = "tony-upload-bucket"
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "upload_bucket_policy" {
  bucket = aws_s3_bucket.upload_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowECSPut",
        Effect = "Allow",
        Principal = "*", # 你也可以限定成 ECS Task Role 的 ARN
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::tony-upload-bucket/uploads/*"
      }
    ]
  })
}
