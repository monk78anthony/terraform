terraform {
  required_version = "1.3.1"
  required_providers {
    aws = {
      source  = "aws"
      version = "~> 4.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "nec-registry"
    key    = "modules-prod/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "nec-tfstate-ddb"
    encrypt        = "true"
  }
}

resource "aws_db_instance" "prod" {
  identifier_prefix   = "prod"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = var.db_name
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true
}