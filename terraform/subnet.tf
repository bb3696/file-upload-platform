resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"  # ✅ 改成不冲突的网段
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}
