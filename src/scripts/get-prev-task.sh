set -o noglob

# shellcheck disable=SC2034  # Hold-over from previous iteration.
PREVIOUS_TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$ECS_PARAM_FAMILY" --include TAGS)
# shellcheck disable=SC2034  # Hold-over from previous iteration.
CONTAINER_IMAGE_NAME_UPDATES="$ECS_PARAM_CONTAINER_IMAGE_NAME_UPDATES"
# shellcheck disable=SC2034  # Hold-over from previous iteration.
CONTAINER_ENV_VAR_UPDATES="$ECS_PARAM_CONTAINER_ENV_VAR_UPDATES"


# Prepare script for updating container definitions

UPDATE_CONTAINER_DEFS_SCRIPT_FILE=$(mktemp_update_container_defs.py.XXXXXX)

chmod +x "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE"

cat > "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE" \<<-EOF

from __future__ import absolute_import

import sys

import json


# shellcheck disable=SC1036  # Hold-over from previous iteration.
def run(previous_task_definition, container_image_name_updates,
container_env_var_updates):
    try:
        definition = json.loads(previous_task_definition)
        container_definitions = definition['taskDefinition']['containerDefinitions']
    except:
        raise Exception('No valid task definition found: ' +
                        previous_task_definition)

    # Build a map of the original container definitions so that the
    # array index positions can be easily looked up
    container_map = {}
    for index, container_definition in enumerate(container_definitions):
        env_var_map = {}
        env_var_definitions = container_definition.get('environment')
        if env_var_definitions is not None:
            for env_var_index, env_var_definition in enumerate(env_var_definitions):
                env_var_map[env_var_definition['name']] = {
                    'index': env_var_index}
        container_map[container_definition['name']] = {
            'image': container_definition['image'], 'index': index, 'environment_map': env_var_map}

    # Expected format: container=...,name=...,value=...,container=...,name=...,value=
    try:
        env_kv_pairs = container_env_var_updates.split(',')
        for index, kv_pair in enumerate(env_kv_pairs):
            kv = kv_pair.split('=')
            key = kv[0].strip()

            if key == 'container':
                container_name = kv[1].strip()
                env_var_name_kv = env_kv_pairs[index+1].split('=')
                env_var_name = env_var_name_kv[1].strip()
                env_var_value_kv = env_kv_pairs[index+2].split('=')
                env_var_value = env_var_value_kv[1].strip()
                if env_var_name_kv[0].strip() != 'name' or env_var_value_kv[0].strip() != 'value':
                    raise ValueError(
                        'Environment variable update parameter format is incorrect: ' + container_env_var_updates)

                container_entry = container_map.get(container_name)
                if container_entry is None:
                    raise ValueError('The container ' + container_name +
                                        ' is not defined in the existing task definition')
                container_index = container_entry['index']
                env_var_entry = container_entry['environment_map'].get(
                    env_var_name)
                if env_var_entry is None:
                    # The existing container definition did not contain environment variables
                    if container_definitions[container_index].get('environment') is None:
                        container_definitions[container_index]['environment'] = []
                    # This env var did not exist in the existing container definition
                    container_definitions[container_index]['environment'].append({'name': env_var_name, 'value': env_var_value})
                else:
                    env_var_index = env_var_entry['index']
                    container_definitions[container_index]['environment'][env_var_index]['value'] = env_var_value
            elif key and key not in ['container', 'name', 'value']:
                raise ValueError(
                    'Incorrect key found in environment variable update parameter: ' + key)
    except ValueError as value_error:
        raise value_error
    except:
        raise Exception(
            'Environment variable update parameter could not be processed; please check parameter value: ' + container_env_var_updates)

    # Expected format: container=...,image-and-tag|image|tag=...,container=...,image-and-tag|image|tag=...,
    try:
        if container_image_name_updates and "container=" not in container_image_name_updates:
            raise ValueError(
                'The container parameter is required in the container_image_name_updates variable.')

        image_kv_pairs = container_image_name_updates.split(',')
        for index, kv_pair in enumerate(image_kv_pairs):
            kv = kv_pair.split('=')
            key = kv[0].strip()
            if key == 'container':
                container_name = kv[1].strip()
                image_kv = image_kv_pairs[index+1].split('=')
                container_entry = container_map.get(container_name)
                if container_entry is None:
                    raise ValueError('The container ' + container_name +
                                        ' is not defined in the existing task definition')
                container_index = container_entry['index']
                image_specifier_type = image_kv[0].strip()
                image_value = image_kv[1].strip()
                if image_specifier_type == 'image-and-tag':
                    container_definitions[container_index]['image'] = image_value
                else:
                    existing_image_name_tokens = container_entry['image'].split(
                        ':')
                    if image_specifier_type == 'image':
                        tag = ''
                        if len(existing_image_name_tokens) == 2:
                            tag = ':' + existing_image_name_tokens[1]
                        container_definitions[container_index]['image'] = image_value + tag
                    elif image_specifier_type == 'tag':
                        container_definitions[container_index]['image'] = existing_image_name_tokens[0] + \
                            ':' + image_value
                    else:
                        raise ValueError(
                            'Image name update parameter format is incorrect: ' + container_image_name_updates)
            elif key and key not in ['container', 'image', 'image-and-tag', 'tag']:
                raise ValueError(
                    'Incorrect key found in image name update parameter: ' + key)

    except ValueError as value_error:
        raise value_error
    except:
        raise Exception(
            'Image name update parameter could not be processed; please check parameter value: ' + container_image_name_updates)
    return json.dumps(container_definitions)


if __name__ == '__main__':
    try:
        print(run(sys.argv[1], sys.argv[2], sys.argv[3]))
    except Exception as e:
        sys.stderr.write(str(e) + "\n")
        exit(1)

EOF


# Prepare container definitions

CONTAINER_DEFS=$(python "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE" "$PREVIOUS_TASK_DEFINITION" "$CONTAINER_IMAGE_NAME_UPDATES" "$CONTAINER_ENV_VAR_UPDATES")


# Escape single quotes from environment variables for BASH_ENV

CLEANED_CONTAINER_DEFS=$(echo "$CONTAINER_DEFS" | sed -E "s:':'\\\'':g")


# Prepare script for getting task definition values

GET_TASK_DFN_VAL_SCRIPT_FILE=$(mktemp _get_task_def_value.py.XXXXXX)

chmod +x $GET_TASK_DFN_VAL_SCRIPT_FILE

cat > $GET_TASK_DFN_VAL_SCRIPT_FILE \<<-EOF

from __future__ import absolute_import

import sys

import json



def run(element_name, task_definition_str):
    try:
        definition = json.loads(task_definition_str)
        task_definition = definition['taskDefinition']
    except:
        raise Exception('No valid task definition found: ' +
                        task_definition_str)
    str_list_types = ['requiresCompatibilities']
    json_arr_types = ['placementConstraints', 'volumes', 'tags']
    json_obj_types = ['proxyConfiguration']
    if element_name in json_arr_types:
        output_value = '[]'
    elif element_name in json_obj_types:
        output_value = '{}'
    else:
        output_value = ''
    if element_name == 'tags':
        if element_name in definition:
            element_value = definition[element_name]
            output_value = json.dumps(element_value)
    elif element_name in task_definition:
        element_value = task_definition[element_name]
        if element_name in str_list_types:
            output_value = ' '.join(list_item.strip() for list_item in element_value)
        elif element_name in json_arr_types or element_name in json_obj_types:
            output_value = json.dumps(element_value)
        else:
            output_value = str(element_value)
    return output_value


if __name__ == '__main__':
    try:
        print(run(sys.argv[1], sys.argv[2]))
    except Exception as e:
        sys.stderr.write(str(e) + "\n")
        exit(1)

EOF


# Get other task definition values

TASK_ROLE=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'taskRoleArn' "$PREVIOUS_TASK_DEFINITION")

EXECUTION_ROLE=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'executionRoleArn' "$PREVIOUS_TASK_DEFINITION")

NETWORK_MODE=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'networkMode' "$PREVIOUS_TASK_DEFINITION")

VOLUMES=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'volumes' "$PREVIOUS_TASK_DEFINITION")

PLACEMENT_CONSTRAINTS=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'placementConstraints' "$PREVIOUS_TASK_DEFINITION")

REQ_COMP=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'requiresCompatibilities' "$PREVIOUS_TASK_DEFINITION")

TASK_CPU=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'cpu' "$PREVIOUS_TASK_DEFINITION")

TASK_MEMORY=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'memory' "$PREVIOUS_TASK_DEFINITION")

PID_MODE=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'pidMode' "$PREVIOUS_TASK_DEFINITION")

IPC_MODE=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'ipcMode' "$PREVIOUS_TASK_DEFINITION")

TAGS=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'tags' "$PREVIOUS_TASK_DEFINITION")

PROXY_CONFIGURATION=$(python $GET_TASK_DFN_VAL_SCRIPT_FILE 'proxyConfiguration' "$PREVIOUS_TASK_DEFINITION")


# Make task definition values available as env variables

echo "export CCI_ORB_AWS_ECS_TASK_ROLE='${TASK_ROLE}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_EXECUTION_ROLE='${EXECUTION_ROLE}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_NETWORK_MODE='${NETWORK_MODE}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_CONTAINER_DEFS='${CLEANED_CONTAINER_DEFS}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_VOLUMES='${VOLUMES}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_PLACEMENT_CONSTRAINTS='${PLACEMENT_CONSTRAINTS}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_REQ_COMP='${REQ_COMP}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_TASK_CPU='${TASK_CPU}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_TASK_MEMORY='${TASK_MEMORY}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_PID_MODE='${PID_MODE}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_IPC_MODE='${IPC_MODE}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_TAGS='${TAGS}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_PROXY_CONFIGURATION='${PROXY_CONFIGURATION}'" >> "$BASH_ENV"


rm $UPDATE_CONTAINER_DEFS_SCRIPT_FILE $GET_TASK_DFN_VAL_SCRIPT_FILE