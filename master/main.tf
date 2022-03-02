//Version pinning for the TF block
terraform {
  required_version = "1.1.5"
}

//Version pinning for the Provider block
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
}

