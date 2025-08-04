resource "aws_route53_zone" "this" {
  name = "tonyyang972.com"
}

# Backend 子域名 - 指向 ALB（你已经手动创建过，可 terraform import）
resource "aws_route53_record" "alb_subdomain" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "api.tonyyang972.com"
  type    = "A"

  alias {
    name                   = "dualstack.file-upload-alb-964713733.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K" # us-east-1 的 ALB Hosted Zone ID，AWS 官方文档固定值
    evaluate_target_health = false
  }
}

# Optional: frontend 子域名 - 指向 CloudFront（如果你 frontend 想用子域名访问）
resource "aws_route53_record" "frontend_subdomain" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "fileupload.tonyyang972.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "lookup_subdomain" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "lookup.tonyyang972.com"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.lookup_custom_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.lookup_custom_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

