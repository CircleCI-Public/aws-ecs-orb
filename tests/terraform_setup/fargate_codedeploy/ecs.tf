resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.aws_resource_prefix}-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_dfn" {
  family = "${var.aws_resource_prefix}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "portMappings": [{
      "containerPort": ${var.container_port},
      "hostPort": ${var.host_port}
    }],
    "environment": [{
      "name": "SECRET",
      "value": "KEY"
    }],
    "essential": true,
    "image": "nginx:latest",
    "memory": 128,
    "memoryReservation": 64,
    "name": "${var.aws_resource_prefix}-service"
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  name          = "${var.aws_resource_prefix}"
  cluster       = "${aws_ecs_cluster.ecs_cluster.id}"
  desired_count = 2
  task_definition = "${aws_ecs_task_definition.ecs_task_dfn.arn}"
  launch_type = "FARGATE"

  deployment_controller {
      type = "CODE_DEPLOY"
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.blue.id
    container_name   = "${var.aws_resource_prefix}-service"
    container_port   = var.container_port
  }

  depends_on = [aws_alb_listener.front_end_blue, aws_iam_role_policy_attachment.ecs_task_execution_role]

}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html
resource "aws_iam_role" "codedeployrole" {
  name = "${var.aws_resource_prefix}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = "${aws_iam_role.codedeployrole.name}"
}

resource "aws_codedeploy_app" "codedeployapp" {
  compute_platform = "ECS"
  name             = "${var.aws_resource_prefix}-codedeployapp"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = "${aws_codedeploy_app.codedeployapp.name}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.aws_resource_prefix}-codedeploygroup"
  service_role_arn       = "${aws_iam_role.codedeployrole.arn}"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = "${aws_ecs_cluster.ecs_cluster.name}"
    service_name = "${aws_ecs_service.ecs_service.name}"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_alb_listener.front_end_blue.arn}"]
      }

      target_group {
        name = "${aws_alb_target_group.blue.name}"
      }

      target_group {
        name = "${aws_alb_target_group.green.name}"
      }
    }
  }
}
