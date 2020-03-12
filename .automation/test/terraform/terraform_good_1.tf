resource "aws_instance" "good" {
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t2.small"
}
