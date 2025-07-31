resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "frontend-oac"
  description                       = "Access control for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  origin {
    domain_name              = "file-upload-frontend-tony.s3.us-east-1.amazonaws.com"
    origin_id                = "file-upload-frontend-tony.s3-website-us-east-1.amazonaws.com-mdcrqdmir38"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    target_origin_id       = "file-upload-frontend-tony.s3-website-us-east-1.amazonaws.com-mdcrqdmir38"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimized
    compress         = true
    default_ttl      = 0
    max_ttl          = 0
    min_ttl          = 0

    grpc_config {
      enabled = false
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Name = "filt-upload"
  }
}
