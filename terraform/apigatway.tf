resource "aws_apigatewayv2_api" "file_upload_api" {
  name          = "file-upload-api"
  protocol_type = "HTTP"

    cors_configuration {
    allow_origins = ["*"] # 或者你的前端域名：["https://d1024z2yphje03.cloudfront.net"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    expose_headers = ["*"]
    }
}

# ---------- Lambda Integration for /lookup ----------
resource "aws_apigatewayv2_integration" "lookup_integration" {
  api_id                 = aws_apigatewayv2_api.file_upload_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lookup_files.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lookup_route" {
  api_id    = aws_apigatewayv2_api.file_upload_api.id
  route_key = "GET /api/files/lookup"
  target    = "integrations/${aws_apigatewayv2_integration.lookup_integration.id}"
}

resource "aws_lambda_permission" "allow_apigw_invoke_lookup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lookup_files.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.file_upload_api.execution_arn}/*/*"
}

# ---------- HTTP_PROXY Integration for /upload ----------
resource "aws_apigatewayv2_integration" "upload_integration" {
  api_id                 = aws_apigatewayv2_api.file_upload_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://file-upload-alb-1613138135.us-east-1.elb.amazonaws.com/api/files/upload"
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.file_upload_api.id
  route_key = "POST /api/files/upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
}

# ---------- HTTP_PROXY Integration for /delete/{filename} ----------
resource "aws_apigatewayv2_integration" "delete_integration" {
  api_id                 = aws_apigatewayv2_api.file_upload_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://file-upload-alb-1613138135.us-east-1.elb.amazonaws.com/api/files/delete/{filename}"
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.file_upload_api.id
  route_key = "DELETE /api/files/delete/{filename}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_integration.id}"
}

# ---------- Stage ----------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.file_upload_api.id
  name        = "$default"
  auto_deploy = true
}

# ---------- Output ----------
output "api_gateway_url" {
  value = aws_apigatewayv2_api.file_upload_api.api_endpoint
}
