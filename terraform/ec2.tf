resource "aws_instance" "backend" {
  ami                         = "ami-0150ccaf51ab55a51"
  instance_type               = "t3.micro"
  subnet_id = aws_subnet.private_a.id
  associate_public_ip_address = false
  key_name                    = "Class"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  iam_instance_profile = "EC2DynamoDBAccessRole"

  tags = {
    Name = "file-upload-backend-dev"
  }
}


