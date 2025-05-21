terraform {
  required_providers {
    aws = {
      version = "~> 4.63.0"
    }
  }
  backend "s3" {
    bucket         = "aws-ecs-terraform-state-bucket-codedeploy-fargate"
    key            = "tf/state"
    region         = "us-west-2"
    dynamodb_table = "aws-ecs-terraform-state-lock-db-codedeploy-fargate"
  }
  required_version = ">= 1.1"
}

provider "aws" {
  region     = var.aws_region
}

locals {
  # The name of the ECR repository to be created
  aws_ecr_repository_name = var.aws_resource_prefix
}

resource "aws_ecr_repository" "demo-app-repository" {
  name = local.aws_ecr_repository_name
  force_delete = true
}
