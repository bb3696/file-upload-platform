resource "aws_lambda_function" "notify_on_upload" {
  function_name = "notifyOnUploadFunction"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10

  filename         = "${path.module}/../backend/lambda/notify_on_upload/notify_on_upload.zip"
  source_code_hash = filebase64sha256("${path.module}/../backend/lambda/notify_on_upload/notify_on_upload.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notify_topic.arn
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logs]
}

resource "aws_lambda_event_source_mapping" "dynamodb_to_lambda" {
  event_source_arn  = aws_dynamodb_table.file_metadata.stream_arn
  function_name     = aws_lambda_function.notify_on_upload.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}
