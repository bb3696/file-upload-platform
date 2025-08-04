resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_dynamodb_stream_policy" {
  name = "lambda-dynamodb-stream-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ],
        Resource = aws_dynamodb_table.file_metadata.stream_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_stream_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_stream_policy.arn
}


resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "LambdaSNSPublishPolicy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.notify_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_scan" {
  name = "LambdaDynamoDBScanPolicy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan"
        ],
        Resource = aws_dynamodb_table.file_metadata.arn
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_s3_policy" {
  name = "ecs-s3-upload-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowS3AccessForUploads",
        Effect: "Allow",
        Action: [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource: "arn:aws:s3:::tony-upload-bucket/uploads/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_s3_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}

resource "aws_iam_policy" "ecs_dynamodb_policy" {
  name = "ecs-dynamodb-put-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowDynamoDBPut",
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = aws_dynamodb_table.file_metadata.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_dynamodb_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_dynamodb_policy.arn
}
