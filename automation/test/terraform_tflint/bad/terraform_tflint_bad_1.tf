resource "aws_instance" "bad" {
  ami           = "ami-0ff8a91507f77f867"
  instance_type =            # invalid type!
}
