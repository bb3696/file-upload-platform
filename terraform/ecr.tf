resource "aws_ecr_repository" "backend_repo" {
  name = "file-upload-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "file-upload-backend"
  }
}