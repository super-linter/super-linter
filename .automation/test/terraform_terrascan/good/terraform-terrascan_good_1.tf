resource "aws_instance" "instanceWithVpc" {
  ami           = "some-id"
  instance_type = "t2.micro"
  monitoring = true

  vpc_security_group_ids = ["sg-12345678901234567"]
  subnet_id = "subnet-12345678901234567"
  metadata_options {
    http_endpoint = "disabled"
  }
  tags = {
    Name = "HelloWorld"
  }
}
