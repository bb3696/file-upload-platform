resource "aws_dynamodb_table" "file_metadata" {
  name           = "FileMetadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "filename"

  attribute {
    name = "filename"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  tags = {
    Name = "FileMetadata"
  }
}
