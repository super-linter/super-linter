resource "aws_instance" "good" {
  ami                         = "ami-0ff8a91507f77f867"
  associate_public_ip_address = false
  ebs_optimized               = true
  iam_instance_profile        = "test"
  instance_type               = "t2.small"
  monitoring                  = true
  vpc_security_group_ids      = ["sg-12345678901234567"]

  metadata_options {
    http_endpoint = "disabled"
  }

  ebs_block_device {
    device_name = "name"
    encrypted   = true
  }

  root_block_device {
    encrypted = true
  }
}

terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
