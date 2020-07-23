resource "aws_instance" "bad" {
  ami                         = "ami-0ff8a91507f77f867"
  instance_type               = "t2.small"
  associate_public_ip_address = true

  ebs_block_device {
    encrypted = false
  }
}
