import unittest
import json
import subprocess
from update_container_defs import run
from jsondiff import diff


class TestContainerDefinitionsUpdate(unittest.TestCase):
    maxDiff = None

    task_dfn_multi_containers_with_env_vars = '{"taskDefinition": {"family": "web-timer", "containerDefinitions": [ { "name": "web", "image": "nginx:v0", "cpu": 99, "memory": 100, "portMappings": [{ "containerPort": 80, "hostPort": 80 }],  "environment": [{ "name": "hostname", "value": "localhost" }, { "name": "port", "value": "8000" }, { "name": "protocol", "value": "http" }], "essential": true, "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/usr/share/nginx/html", "readOnly": true }] }, { "name": "timer", "image": "busybox:v1", "environment": [{ "name": "version", "value": "1" }, { "name": "scheduled", "value": "false" }, { "name": "year", "value": "2018" }], "cpu": 10, "memory": 20, "entryPoint": ["sh", "-c"], "command": ["while true; do date > /nginx/index.html; sleep 1; done"], "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/nginx/" }] }], "volumes": [{ "name": "webdata", "host": { "sourcePath": "/ecs/webdata" }} ] }}'
    task_dfn_multi_containers = '{"taskDefinition": {"family": "web-timer", "containerDefinitions": [ { "name": "web", "image": "nginx:v0", "cpu": 99, "memory": 100, "portMappings": [{ "containerPort": 80, "hostPort": 80 }], "essential": true, "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/usr/share/nginx/html", "readOnly": true }] }, { "name": "timer", "image": "busybox:v1", "cpu": 10, "memory": 20, "entryPoint": ["sh", "-c"], "command": ["while true; do date > /nginx/index.html; sleep 1; done"], "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/nginx/" }] }], "volumes": [{ "name": "webdata", "host": { "sourcePath": "/ecs/webdata" }} ] }}'
    task_dfn_multi_containers_no_tags = '{"taskDefinition": {"family": "web-timer", "containerDefinitions": [ { "name": "web", "image": "nginx", "cpu": 99, "memory": 100, "portMappings": [{ "containerPort": 80, "hostPort": 80 }], "essential": true, "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/usr/share/nginx/html", "readOnly": true }] }, { "name": "timer", "image": "busybox", "cpu": 10, "memory": 20, "entryPoint": ["sh", "-c"], "command": ["while true; do date > /nginx/index.html; sleep 1; done"], "mountPoints": [{ "sourceVolume": "webdata", "containerPath": "/nginx/" }] }], "volumes": [{ "name": "webdata", "host": { "sourcePath": "/ecs/webdata" }} ] }}'
    task_dfn_no_volumes_key = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_empty_volumes = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": [], "volumes": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_no_placement_constraints_key = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_empty_placement_constraints = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": [], "placementConstraints": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_no_requires_compatibilities_key = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_empty_requires_compatibilities = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19", "containerDefinitions": [{"environment": [], "name": "sleep", "mountPoints": [], "image": "busybox", "cpu": 10, "portMappings": [], "command": ["sleep", "360"], "memory": 10, "essential": true, "volumesFrom": [], "requiresCompatibilities": []}], "family": "sleep360", "revision": 1}}'
    task_dfn_invalid = '{}'
    task_dfn_invalid_no_container_definitions = '{"taskDefinition": {"volumes": [], "taskDefinitionArn": "arn:aws:ecs:us-east-1:111:task-definition/sleep360:19"}'

    def test_container_not_set_update_param(self):
        """Exception is raised when using undefined container"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_empty_volumes]
        for task_dfn in task_dfns:
            self.assertRaises(ValueError, run, task_dfn,
                              'image-and-tag=ruby', '')

    def test_invalid_image_update_param_container(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(ValueError,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          'acontainer=web,container=timer,image-and-tag=golang', '')

    def test_invalid_image_update_param(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(ValueError,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          'container=web,container=timer,image-and-tag=golang', '')

    def test_another_invalid_image_update_param(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(Exception,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          'container=web', '')

    def test_invalid_env_var_update_param(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(ValueError,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          '', 'container=web,name=host,name=protocol,container=timer')

    def test_invalid_env_var_update_param_key(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(ValueError,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          '', 'acontainer=web,name=host,name=protocol,container=timer')

    def test_another_invalid_env_var_update_param(self):
        """Exception is raised when using an incorrectly formatted image update param value"""
        self.assertRaises(Exception,
                          run, TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                          '', 'container=web,name=a')

    def test_update_invalid_task_definition(self):
        """Exception is raised when trying to update an invalid task definition"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_invalid,
                     TestContainerDefinitionsUpdate.task_dfn_invalid_no_container_definitions]
        for task_dfn in task_dfns:
            self.assertRaises(Exception,
                              run, task_dfn,
                              'container=web,image-and-tag=golang', 'container=web,name=a,value=b')

    def test_update_non_existent_container(self):
        """Exception is raised when trying to update a non-existent container"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_empty_volumes]
        for task_dfn in task_dfns:
            self.assertRaises(ValueError, run, task_dfn,
                              'container=doesntexist,image-and-tag=ruby', '')

    def test_update_mix_of_existent_and_non_existent_containers(self):
        """Exception is raised when trying to update a non-existent container"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_empty_volumes]
        for task_dfn in task_dfns:
            new_images = ['ruby:latest', 'python:latest']
            image_update_param = 'container=web,image-and-tag=%s, container=doesntexist,image-and-tag=%s' % (
                new_images[0], new_images[1])
            self.assertRaises(ValueError,
                              run, task_dfn,
                              image_update_param, '')

    def test_multi_containers_full_image_name_update_to_1_container(self):
        """Image names are correctly updated"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags]
        for task_dfn in task_dfns:
            new_images = ['ruby:latest']
            image_update_param = 'container=web,image-and-tag=%s' % (
                new_images[0])
            updated_containers = ['web']
            expected_diff = '{"0": {"image": "%s"}}' % (
                new_images[0])
            self._test_image_update(task_dfn,
                                    image_update_param, '', updated_containers, new_images, expected_diff)

    def test_multi_containers_full_image_name_update_to_1_container_reordered(self):
        """Image names are correctly updated"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags]
        for task_dfn in task_dfns:
            new_images = ['ruby:latest']
            image_update_param = 'container=timer,image-and-tag=%s' % (
                new_images[0])
            updated_containers = ['timer']
            expected_diff = '{"1": {"image": "%s"}}' % (
                new_images[0])
            self._test_image_update(task_dfn,
                                    image_update_param, '', updated_containers, new_images, expected_diff)

    def test_multi_containers_full_image_name_update_to_2_containers(self):
        """Image names are correctly updated"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags]
        for task_dfn in task_dfns:
            new_images = ['ruby:latest', 'python:3.7.1']
            image_update_param = 'container=web,image-and-tag=%s, container=timer,image-and-tag=%s' % (
                new_images[0], new_images[1])
            updated_containers = ['web', 'timer']
            expected_diff = '{"0": {"image": "%s"}, "1": {"image": "%s"}}' % (
                new_images[0], new_images[1])
            self._test_image_update(task_dfn,
                                    image_update_param, '', updated_containers, new_images, expected_diff)

    def test_multi_containers_full_image_name_update_to_2_containers_reordered(self):
        """Image names are correctly updated"""
        task_dfns = [TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                     TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags]
        for task_dfn in task_dfns:
            new_images = ['python:3.7.1', 'ruby:latest']
            image_update_param = 'container=timer,image-and-tag=%s, container=web,image-and-tag=%s, ' % (
                new_images[0], new_images[1])
            updated_containers = ['timer', 'web']
            expected_diff = '{"0": {"image": "%s"}, "1": {"image": "%s"}}' % (
                new_images[1], new_images[0])
            self._test_image_update(task_dfn,
                                    image_update_param, '', updated_containers, new_images, expected_diff)

    def test_multi_containers_image_only_update_to_1_container_without_tag(self):
        """Image names are correctly updated"""
        new_images = ['ruby']
        image_update_param = 'container=web,image=%s' % (
            new_images[0])
        updated_containers = ['web']
        expected_diff = '{"0": {"image": "%s"}}' % (
            new_images[0])
        self._test_image_only_update(TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags,
                                     image_update_param, '', updated_containers, new_images, [], expected_diff)

    def test_multi_containers_image_only_update_to_2_containers_without_tags(self):
        """Image names are correctly updated"""
        new_images = ['ruby', 'python']
        image_update_param = 'container=web,image=%s, container=timer,image=%s' % (
            new_images[0], new_images[1])
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "%s"}, "1": {"image": "%s"}}' % (
            new_images[0], new_images[1])
        self._test_image_only_update(TestContainerDefinitionsUpdate.task_dfn_multi_containers_no_tags,
                                     image_update_param, '', updated_containers, new_images, [], expected_diff)

    def test_multi_containers_image_only_update_to_1_container(self):
        new_images = ['ruby']
        image_update_param = 'container=web,image=%s' % (new_images[0])
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "%s"}}' % (
            'ruby:v0')
        self._test_image_only_update(
            TestContainerDefinitionsUpdate.task_dfn_multi_containers, image_update_param, '', updated_containers, new_images, ['v0'], expected_diff)

    def test_multi_containers_image_only_update_to_2_containers(self):
        new_images = ['ruby', 'python']
        image_update_param = 'container=web,image=%s, container=timer,image=%s' % (
            new_images[0], new_images[1])
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "%s"}, "1": {"image": "%s"}}' % (
            'ruby:v0', 'python:v1')
        self._test_image_only_update(TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                                     image_update_param, '', updated_containers, new_images, ['v0', 'v1'], expected_diff)

    def test_multi_containers_tag_only_update_to_2_containers_and_reordered_containers(self):
        new_tags = ['v3', 'v4']
        image_update_param = 'container=timer,tag=%s, container=web,tag=%s' % (
            new_tags[0], new_tags[1])
        updated_containers = ['timer', 'web']
        expected_diff = '{"0": {"image": "%s"}, "1": {"image": "%s"}}' % (
            'nginx:v4', 'busybox:v3')
        self._test_image_only_update(TestContainerDefinitionsUpdate.task_dfn_multi_containers,
                                     image_update_param, '', updated_containers, ['busybox', 'nginx'], new_tags, expected_diff)

    def test_env_var_update(self):
        """Env vars are correctly updated"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_multi_containers_with_env_vars
        new_images = ['ruby:latest', 'python:3.7.1']
        image_update_param = 'container=web,image-and-tag=%s,container=timer,image-and-tag=%s' % (
            new_images[0], new_images[1])
        env_var_update_param = 'container=web,name=%s,value=%s,container=timer,name=%s,value=%s,container=web,name=%s,value=%s,' % (
            'protocol', 'https', 'scheduled', 'every week', 'hostname', '127.0.0.1')
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "ruby:latest", "environment": {"0": {"value": "127.0.0.1"}, "2": {"value": "https"}}}, "1": {"image": "python:3.7.1", "environment": {"1": {"value": "every week"}}}}'
        self._test_image_update(task_dfn,
                                image_update_param, env_var_update_param, updated_containers, new_images, expected_diff)

    def test_adding_env_vars_to_empty_list(self):
        """Env vars are correctly added"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_multi_containers
        new_images = ['ruby:latest', 'python:3.7.1']
        image_update_param = 'container=web,image-and-tag=%s,container=timer,image-and-tag=%s' % (
            new_images[0], new_images[1])
        env_var_update_param = 'container=web,name=%s,value=%s,container=timer,name=%s,value=%s,container=web,name=%s,value=%s,' % (
            'protocol', 'https', 'scheduled', 'every week', 'hostname', '127.0.0.1')
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "ruby:latest", "environment": [{"name": "protocol", "value": "https"}, {"name": "hostname", "value": "127.0.0.1"}]}, "1": {"image": "python:3.7.1", "environment": [{"name": "scheduled", "value": "every week"}]}}'
        self._test_image_update(task_dfn,
            image_update_param, env_var_update_param, updated_containers, new_images, expected_diff)

    def test_adding_new_env_vars(self):
        """New/existing env vars are correctly added/modified and unmodified env vars are preserved"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_multi_containers_with_env_vars
        new_images = ['ruby:latest', 'python:3.7.1']
        image_update_param = 'container=web,image-and-tag=%s,container=timer,image-and-tag=%s' % (
            new_images[0], new_images[1])
        env_var_update_param = 'container=web,name=%s,value=%s,container=timer,name=%s,value=%s,container=web,name=%s,value=%s,container=web,name=%s,value=%s,container=web,name=%s,value=%s' % (
            'protocol', 'https', 'scheduled', 'every week', 'hostname', '127.0.0.1', 'maxThreads', '100', 'minThreads', '20')
        updated_containers = ['web', 'timer']
        expected_diff = '{"0": {"image": "ruby:latest", "environment": {"0": {"value": "127.0.0.1"}, "2": {"value": "https"}, "$insert": [[3, {"name": "maxThreads", "value": "100"}], [4, {"name": "minThreads", "value": "20"}]]}}, "1": {"image": "python:3.7.1", "environment": {"1": {"value": "every week"}}}}'
        self._test_image_update(task_dfn,
            image_update_param, env_var_update_param, updated_containers, new_images, expected_diff)

    def _test_tag_only_update(self, task_dfn, image_update_param, ev_update_param, updated_containers, existing_images, new_tags, expected_diff):
        """Image names are correctly updated"""
        expected_image_names = [existing_images[i] + ':' +
                                new_tags[i] for i, v in enumerate(new_tags)]
        self._test_image_update(task_dfn, image_update_param, ev_update_param,
                                updated_containers, expected_image_names, expected_diff)

    def _test_image_only_update(self, task_dfn, image_update_param, ev_update_param, updated_containers, new_images, existing_tags, expected_diff):
        """Image names are correctly updated"""
        if existing_tags:
            expected_image_names = [new_images[i] + ':' +
                                    existing_tags[i] for i, v in enumerate(new_images)]
        else:
            expected_image_names = new_images[:]
        self._test_image_update(task_dfn, image_update_param, ev_update_param,
                                updated_containers, expected_image_names, expected_diff)

    def _test_image_update(self, task_dfn, image_update_param, ev_update_param, updated_containers, expected_image_names, expected_diff):
        """Image names are correctly updated"""
        ret_val = run(task_dfn, image_update_param, ev_update_param)
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        for i, v in enumerate(expected_image_names):
            self.assertEqual(self.get_container_definition(
                updated_containers[i], updated_obj)['image'], expected_image_names[i])
        self.assertEqual(self.get_diff(
            task_dfn, updated_obj, True), expected_diff)

    def check_env_var_update(self, updated_obj, expected_ev_updates):
        """Env vars are correctly updated"""
        for update in expected_ev_updates:
            self.assertEqual(self.get_env_var(update['name'],
                                              update['container'], updated_obj), update['value'])

    def get_container_definition(self, container_name, container_definitions):
        return [container for container in container_definitions if container['name'] == container_name][0]

    def get_env_var(self, env_var_name, container_name, container_definitions):
        [env_var for env_var in self.get_container_definition(container_name, container_definitions)[
            'environment'] if env_var['name'] == env_var_name][0]

    def test_no_volumes_key(self):
        """Updated definition preserves the lack of volumes key"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_no_volumes_key
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertIsNone(updated_obj[0].get('volumes'))
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_empty_volumes(self):
        """Updated definition preserves the empty volumes"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_empty_volumes
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertEqual(len(updated_obj[0]['volumes']), 0)
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_no_placement_constraints_key(self):
        """Updated definition preserves the lack of placementConstraints key"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_no_requires_compatibilities_key
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertIsNone(updated_obj[0].get('placementConstraints'))
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_empty_placement_constraints_key(self):
        """Updated definition preserves the empty placementConstraints"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_empty_placement_constraints
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertEqual(len(updated_obj[0]['placementConstraints']), 0)
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_no_requires_compatibilities_key(self):
        """Updated definition preserves the lack of requiresCompatibilities key"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_no_placement_constraints_key
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertIsNone(updated_obj[0].get('requiresCompatibilities'))
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_empty_requires_compatibilities_key(self):
        """Updated definition preserves the empty requiresCompatibilities"""
        task_dfn = TestContainerDefinitionsUpdate.task_dfn_empty_requires_compatibilities
        ret_val = run(task_dfn, 'container=sleep,image=busybox',  '')
        updated_obj = json.loads(ret_val)
        self.validate_container_definitions(updated_obj)
        self.assertEqual(len(updated_obj[0]['requiresCompatibilities']), 0)
        self.validate_no_change_made(task_dfn, updated_obj)

    def test_stdout_output(self):
        """Script results are printed out"""
        task_dfn_input = "{\"taskDefinition\": {\"containerDefinitions\": [{}]}}"
        output = self.execute_script(
            "python update_container_defs.py %s '' ''" % (task_dfn_input), 0)
        self.assertFalse(self.get_diff(task_dfn_input, output))

    def test_error_message_output(self):
        """An error message is output to stderr when an exception occurs"""
        output = self.execute_script(
            "python update_container_defs.py '{}' '' ''", 1)
        self.assertIn(b"No valid task definition found:", output)

    def validate_container_definitions(self, container_definitions):
        for container_definition in container_definitions:
            self.assertTrue(container_definition.get('image'))

    def validate_no_change_made(self, input_task_definition, processed_container_definitions):
        self.assertFalse(self.get_diff(input_task_definition,
                                       processed_container_definitions))

    def get_diff(self, input_task_definition, processed_container_definitions, return_as_str=False):
        result = diff(json.loads(input_task_definition)[
            'taskDefinition']['containerDefinitions'], processed_container_definitions)
        result_json = ''
        if return_as_str:
            try:
                result_json = json.dumps(result)
            except:
                # Ensure the result is valid json
                result_json = diff(json.loads(input_task_definition)[
            'taskDefinition']['containerDefinitions'], processed_container_definitions, dump=True)
        return result_json if return_as_str else result

    def execute_script(self, command, result_item_index):
        process = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        return process.communicate()[result_item_index]


if __name__ == '__main__':
    unittest.main()