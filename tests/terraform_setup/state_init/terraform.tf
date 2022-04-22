provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  version    = "~> 2.7"
}

# terraform state file setup
# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3-ec2" {
  bucket = "aws-ecs-terraform-state-bucket-ec2"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "terraform-state-storage-s3-fargate" {
  bucket = "aws-ecs-orb-terraform-state-bucket-fargate"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "terraform-state-storage-s3-codedeploy-fargate" {
  bucket = "aws-ecs-orb-terraform-state-bucket-codedeploy-fargate"
  force_destroy = true
  versioning {
    enabled = true
  }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-ec2" {
  name           = "aws-ecs-terraform-state-lock-db-ec2"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-fargate" {
  name           = "aws-ecs-orb-terraform-state-lock-db-fargate"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-codedeploy-fargate" {
  name           = "aws-ecs-orb-terraform-state-lock-db-codedeploy-fargate"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
