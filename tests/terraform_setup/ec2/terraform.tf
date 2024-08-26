terraform {
  required_providers {
    aws = {
      version = "~> 4.63.0"
    }
  }
  backend "s3" {
    bucket         = "aws-ecs-terraform-state-bucket-ec2"
    key            = "tf/state"
    region         = "us-west-2"
    dynamodb_table = "aws-ecs-terraform-state-lock-db-ec2"
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
  # The name of the CloudFormation stack to be created for the VPC and related resources
  aws_vpc_stack_name = "${var.aws_resource_prefix}-vpc-stack"

  # The name of the CloudFormation stack to be created for the ECS service and related resources
  aws_ecs_service_stack_name = "${var.aws_resource_prefix}-svc-stack"

  # The name of the ECR repository to be created
  aws_ecr_repository_name = var.aws_resource_prefix

  # The name of the ECS cluster to be created
  aws_ecs_cluster_name = "${var.aws_resource_prefix}-cluster"

  # The name of the ECS service to be created
  aws_ecs_service_name = "${var.aws_resource_prefix}-service"

  # The name of the ECS task definition family to be created
  aws_ecs_family_name = "${var.aws_resource_prefix}-family"
}

resource "aws_ecr_repository" "demo-app-repository" {
  name = local.aws_ecr_repository_name
  force_delete = true
}

resource "aws_cloudformation_stack" "vpc" {
  name          = local.aws_vpc_stack_name
  template_body = file("cloudformation-templates/public-vpc.yml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]
  parameters = {
    InstanceType    = "t2.large"
    DesiredCapacity = "2"
    MaxSize         = "4"
    ClusterName     = local.aws_ecs_cluster_name
  }
}

# Note: creates task definition and task definition family with the same name as the ServiceName parameter value
resource "aws_cloudformation_stack" "ecs_service" {
  name          = local.aws_ecs_service_stack_name
  template_body = file("cloudformation-templates/public-service.yml")
  depends_on = [
    aws_cloudformation_stack.vpc,
    aws_ecr_repository.demo-app-repository,
    aws_iam_role.parameter_store_read_role
  ]

  parameters = {
    TaskCpu       = 1024
    TaskMemory    = 2048
    ContainerPort = 80
    StackName     = local.aws_vpc_stack_name
    ServiceName   = local.aws_ecs_service_name
    FamilyName    = local.aws_ecs_family_name
    Role          = aws_iam_role.parameter_store_read_role.arn
    SecretArn     = aws_ssm_parameter.test_container_secret.arn
    # Note: Since ImageUrl parameter is not specified, the Service
    # will be deployed with the 1st container using the
    # nginx image when created
  }
}

resource "aws_ssm_parameter" "test_container_secret" {
  name  = var.aws_resource_prefix
  type  = "String"
  value = "test_value"
}

resource "aws_ssm_parameter" "test_container_secret_toupdate" {
  name  = "${var.aws_resource_prefix}-update"
  type  = "String"
  value = "test_value_updated"
}

resource "aws_iam_role" "parameter_store_read_role" {
  name = "parameter-store-read-role-${var.aws_resource_prefix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "parameter_store_read_policy" {
  name         = "secret-read-policy-${var.aws_resource_prefix}"
  description  = "Allows to read from parameter store"
  policy       = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*",
        ],
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })   
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.parameter_store_read_role.name
  policy_arn = aws_iam_policy.parameter_store_read_policy.arn
}