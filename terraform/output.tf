output "alb_dns" {
  value = aws_lb.app_alb.dns_name
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}
