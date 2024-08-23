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
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
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

resource "aws_ssm_parameter" "test_container_secret" {
  name  = var.aws_resource_prefix
  type  = "String"
  value = "test_value"
}

output "arn_secret" {
  value = aws_ssm_parameter.test_container_secret.arn
}