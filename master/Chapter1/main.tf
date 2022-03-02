terraform {
    required_version = "1.1.5"
  required_providers {
    mycloud = {
      source  = "aws"
      version = "~> 4.3"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "app" {
  availability_zone = "us-east-1a"
  ami               = "ami-04505e74c0741db8d"

  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

