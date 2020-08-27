resource "aws_instance" "instanceWithNoVpc" {
  ami           = "some-id"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
