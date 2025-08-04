resource "aws_apigatewayv2_api" "lookup_api" {
  name          = "lookup-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]  # 或你的前端域名 https://fileupload.tonyyang972.com
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lookup_integration" {
  api_id                 = aws_apigatewayv2_api.lookup_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lookup_files.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lookup_route" {
  api_id    = aws_apigatewayv2_api.lookup_api.id
  route_key = "GET /api/files/lookup"
  target    = "integrations/${aws_apigatewayv2_integration.lookup_integration.id}"
}

resource "aws_apigatewayv2_stage" "lookup_stage" {
  api_id      = aws_apigatewayv2_api.lookup_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_lookup_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lookup_files.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lookup_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_domain_name" "lookup_custom_domain" {
  domain_name = "lookup.tonyyang972.com"

  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-1:896520308122:certificate/ac6a14f8-bc08-47b7-a983-e02a529b906e"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "lookup_mapping" {
  api_id      = aws_apigatewayv2_api.lookup_api.id
  domain_name = aws_apigatewayv2_domain_name.lookup_custom_domain.id
  stage       = aws_apigatewayv2_stage.lookup_stage.id
}
