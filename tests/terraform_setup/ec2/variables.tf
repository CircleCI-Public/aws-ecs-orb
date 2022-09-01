variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "aws_session_token" {}
variable "aws_region" {
  description = "AWS region e.g. us-east-1"
}
variable "aws_resource_prefix" {
  description = "Prefix to be used in the naming of the created AWS resources e.g. ecs-ec2"
}
