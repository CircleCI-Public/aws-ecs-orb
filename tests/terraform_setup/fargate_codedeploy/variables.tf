variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "aws_session_token" {}
variable "aws_region" {
  description = "AWS region e.g. us-east-1 (Please specify a region supported by the Fargate launch type)"
}
variable "aws_resource_prefix" {
  description = "Prefix to be used in the naming of the created AWS resources e.g. ecs-fargate"
}

variable "az_count" {
  default = "2"
}

variable "health_check_path" {
  default = "/"
}

variable "container_port" {
  default = "8080"
}

variable "host_port" {
  default = "8080"
}

variable "app_port" {
  default = "80"
}

variable "app_port_green" {
  default = "8080"
}
