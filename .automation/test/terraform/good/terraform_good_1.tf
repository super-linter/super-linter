resource "aws_instance" "good" {
  ami                         = "ami-0ff8a91507f77f867"
  instance_type               = "t2.small"
  associate_public_ip_address = false

  vpc_security_group_ids = ["sg-12345678901234567"]

  ebs_block_device {
    encrypted = true
  }
}
