terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  // This is only here so we can destroy the bucket as part of automated tests. You should not copy this for production
  // usage
  force_destroy = true
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  } 

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
    backend "s3" {
        bucket = "nec-registry"
        key = "master/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "nec-tfstate-ddb"
        encrypt = "true"
    }
}

resource "aws_instance" "app" {
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  ami               = "ami-04505e74c0741db8d"

  user_data = <<-EOF
              #!/bin/bash
              sudo service apache2 start
              EOF
}

