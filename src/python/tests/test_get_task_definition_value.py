import unittest
import json
import subprocess
from get_task_definition_value import run
from jsondiff import diff


class TestGetTaskDefinitionValue(unittest.TestCase):

    task_dfn = '{ "taskDefinition": { "volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:123456:task-definition/sleep360:19", "containerDefinitions": [ { "environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": [ "sleep", "360" ], "memory": 10, "essential": true, "volumesFrom": [] } ], "family": "sleep360", "revision": 1 } }'
    task_dfn_execution_role_arn = '{"taskDefinition":{"containerDefinitions":[{"command":[],"entryPoint":["sh","-c"],"essential":true,"image":"httpd:2.4","logConfiguration":{"logDriver":"awslogs","options":{"awslogs-group":"/ecs/fargate-task-definition","awslogs-region":"us-east-1","awslogs-stream-prefix":"ecs"}},"name":"sample-fargate-app","portMappings":[{"containerPort":80,"hostPort":80,"protocol":"tcp"}]}],"cpu":"256","executionRoleArn":"arn:aws:iam::012345678910:role/ecsTaskExecutionRole","family":"fargate-task-definition","memory":"512","networkMode":"awsvpc","requiresCompatibilities":["FARGATE"]}}'
    task_dfn_task_role_arn = '{"taskDefinition": {"containerDefinitions":[{"name":"sample-app","image":"123456789012.dkr.ecr.us-west-2.amazonaws.com/aws-nodejs-sample:v1","memory":200,"cpu":10,"essential":true}],"family":"example_task_3","taskRoleArn":"arn:aws:iam::123456789012:role/AmazonECSTaskS3BucketRole"}}'
    task_dfn_volumes = '{"taskDefinition": {"family": "web-timer", "containerDefinitions": [ { "name": "web", "image": "nginx:v0", "cpu": 99, "memory": 100, "portMappings": [{ "containerPort": 80, "hostPort": 80 }], "essential": true, "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/usr/share/nginx/html", "readOnly": true }] }, { "name": "timer", "image": "busybox:v1", "cpu": 10, "memory": 20, "entryPoint": ["sh", "-c"], "command": ["while true; do date > /nginx/index.html; sleep 1; done"], "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/nginx/" }] }], "volumes": [{ "name": "webdata", "host": { "sourcePath": "/ecs/webdata" }} ] }}'
    task_dfn_placement_constraints = '{"taskDefinition":{"volumes":[],"placementConstraints":[{"expression":"attribute:ecs.instance-type =~ t2.*","type":"memberOf"}],"taskDefinitionArn":"arn:aws:ecs:us-east-1:123456:task-definition/sleep360:19","containerDefinitions":[{"environment":[],"name":"sleep","mountPoints":[],"image":"busybox","cpu":10,"portMappings":[],"command":["sleep","360"],"memory":10,"essential":true,"volumesFrom":[]}],"family":"sleep360","revision":1}}'
    task_dfn_ec2_fargate_compatibilities = '{"taskDefinition":{"containerDefinitions":[{"command":[],"entryPoint":["sh","-c"],"essential":true,"image":"httpd:2.4","logConfiguration":{"logDriver":"awslogs","options":{"awslogs-group":"/ecs/fargate-task-definition","awslogs-region":"us-east-1","awslogs-stream-prefix":"ecs"}},"name":"sample-fargate-app","portMappings":[{"containerPort":80,"hostPort":80,"protocol":"tcp"}]}],"cpu":"256","executionRoleArn":"arn:aws:iam::012345678910:role/ecsTaskExecutionRole","family":"fargate-task-definition","memory":"512","networkMode":"awsvpc","requiresCompatibilities":["EC2", "FARGATE"]}}'

    def test_get_task_role(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value('taskRoleArn', TestGetTaskDefinitionValue.task_dfn_task_role_arn,
                               'arn:aws:iam::123456789012:role/AmazonECSTaskS3BucketRole')
        self.get_literal_value('taskRoleArn', TestGetTaskDefinitionValue.task_dfn,
                               '')

    def test_get_execution_role(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value('executionRoleArn', TestGetTaskDefinitionValue.task_dfn_execution_role_arn,
                               'arn:aws:iam::012345678910:role/ecsTaskExecutionRole')
        self.get_literal_value('executionRoleArn', TestGetTaskDefinitionValue.task_dfn,
                               '')

    def test_get_network_mode(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value(
            'networkMode', TestGetTaskDefinitionValue.task_dfn_execution_role_arn, 'awsvpc')
        self.get_literal_value(
            'networkMode', TestGetTaskDefinitionValue.task_dfn, '')

    def test_get_volumes(self):
        """Gets the correct value from a task definition"""
        self.get_json_value('volumes', TestGetTaskDefinitionValue.task_dfn_volumes,
                            '[{ "name": "webdata", "host": { "sourcePath": "/ecs/webdata" }}]')
        self.get_json_value('volumes',
                            TestGetTaskDefinitionValue.task_dfn_execution_role_arn, '[]')

    def test_get_placement_constraints(self):
        """Gets the correct value from a task definition"""
        self.get_json_value('placementConstraints', TestGetTaskDefinitionValue.task_dfn_placement_constraints,
                            '[{"expression":"attribute:ecs.instance-type =~ t2.*","type":"memberOf"}]')
        self.get_json_value('placementConstraints',
                            TestGetTaskDefinitionValue.task_dfn, '[]')

    def test_get_requires_compatibilities(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value('requiresCompatibilities',
                               TestGetTaskDefinitionValue.task_dfn_ec2_fargate_compatibilities, 'EC2 FARGATE')
        self.get_literal_value('requiresCompatibilities',
                               TestGetTaskDefinitionValue.task_dfn_execution_role_arn, 'FARGATE')
        self.get_literal_value('requiresCompatibilities',
                               TestGetTaskDefinitionValue.task_dfn, '')

    def test_get_cpu(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value(
            'cpu', TestGetTaskDefinitionValue.task_dfn_execution_role_arn, '256')
        self.get_literal_value(
            'cpu', TestGetTaskDefinitionValue.task_dfn_placement_constraints, '')

    def test_get_memory(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value(
            'memory', TestGetTaskDefinitionValue.task_dfn_execution_role_arn, '512')
        self.get_literal_value(
            'memory', TestGetTaskDefinitionValue.task_dfn, '')

    def test_get_value(self):
        """Gets the correct value from a task definition"""
        self.get_literal_value(
            'family', TestGetTaskDefinitionValue.task_dfn_volumes, 'web-timer')
        self.get_literal_value(
            'doesntexist', TestGetTaskDefinitionValue.task_dfn_volumes, '')

    def test_invalid_task_definitions(self):
        self.assertRaises(Exception,
                          run, '', '')
        self.assertRaises(Exception,
                          run, 'a', '{}')

    def get_literal_value(self, element_name, task_dfn, expected_val):
        self.assertEqual(run(element_name, task_dfn), expected_val)

    def get_json_value(self, element_name, task_dfn, expected_val):
        self.assertFalse(
            diff(json.loads(run(element_name, task_dfn)), json.loads(expected_val)))

    def test_stdout_output(self):
        """Script results are printed out"""
        output = self.execute_script(
            "python get_task_definition_value.py 'networkMode' '{\"taskDefinition\": {\"networkMode\": \"awsvpc\"}}'", 0)
        self.assertIn(b"awsvpc", output)

    def test_error_message_output(self):
        """An error message is output to stderr when an exception occurs"""
        output = self.execute_script(
            "python get_task_definition_value.py 'a' '{}'", 1)
        self.assertIn(b"No valid task definition found:", output)

    def execute_script(self, command, result_item_index):
        process = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        return process.communicate()[result_item_index]
