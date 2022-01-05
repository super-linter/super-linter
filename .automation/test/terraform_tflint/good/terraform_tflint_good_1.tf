resource "aws_instance" "good" {
  ami                         = "ami-0ff8a91507f77f867"
  instance_type               = "t2.small"
  associate_public_ip_address = false

  vpc_security_group_ids = ["sg-12345678901234567"]
  metadata_options {
    http_endpoint = "disabled"
  }

  ebs_block_device {
    encrypted = true
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "2.11.1"

  bucket = "test-bucket"
}

module "good_relative_reference" {
  source = "../modules/ec2_instance"
}
