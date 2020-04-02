// https://github.com/terraform-linters/tflint/blob/master/docs/guides/config.md
config {
  module = true
  deep_check = false
  force = false

  // aws_credentials = {
  //   access_key = "AWS_ACCESS_KEY"
  //   secret_key = "AWS_SECRET_KEY"
  //   region     = "us-east-1"
  // }

  // ignore_module = {
  //   "github.com/terraform-linters/example-module" = true
  // }

  // varfile = ["example1.tfvars", "example2.tfvars"]

  // variables = ["foo=bar", "bar=[\"baz\"]"]
}

rule "aws_instance_invalid_type" {
  enabled = false
}

rule "aws_instance_previous_type" {
  enabled = false
}

// plugin "example" {
//   enabled = true
// }
