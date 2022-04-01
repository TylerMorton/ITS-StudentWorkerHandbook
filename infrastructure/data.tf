

data "aws_ami" "bionic" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "image-id"
    values = ["ami-0519cce8bb5c1229c"]
  }
}

