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

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = var.cluster_name
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key
  //dynamodb_table         = var.dynamodb_table
  //dynamodb_table_encrypt = var.dynamodb_table_encrypt

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 10
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
