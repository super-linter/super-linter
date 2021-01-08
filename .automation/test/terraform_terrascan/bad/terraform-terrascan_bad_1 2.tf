resource "aws_instance" "instanceWithNoVpc" {
  ami           = "some-id"
  instance_type = "t2.micro"
  metadata_options {
    http_endpoint = "disabled"
  }
  tags = {
    Name = "HelloWorld"
  }
}
