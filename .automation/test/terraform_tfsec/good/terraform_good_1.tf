resource "aws_alb_listener" "my-valid-alb-listener"{
    port     = "80"
    protocol = "HTTPS"
}