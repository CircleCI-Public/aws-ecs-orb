from __future__ import absolute_import
from itertools import groupby
import sys
import json

# shellcheck disable=SC1036  # Hold-over from previous iteration.
def run(previous_task_definition, container_image_name_updates,
        container_env_var_updates):
    try:
        definition = json.loads(previous_task_definition)
        container_definitions = definition['taskDefinition']['containerDefinitions']
    except:
        raise Exception('No valid task definition found: ' + previous_task_definition)

    # Expected format: container=x,name=y,value=z,container=...,name=...,value=
    if container_env_var_updates:
        __upsert_container_definitions(container_definitions, container_env_var_updates, 'environment', ['container', 'name', 'value'])

    # Build a map of the original container definitions so that the
    # array index positions can be easily looked up
    container_map = {
        container_definition['name']: {
            'image': container_definition['image'],
            'index': index,
        }
        for index, container_definition in enumerate(container_definitions)
    }
    # Expected format: container=...,image-and-tag|image|tag=...,container=...,image-and-tag|image|tag=...,
    try:
        if container_image_name_updates and "container=" not in container_image_name_updates:
            raise ValueError('The container parameter is required in the container_image_name_updates variable.')

        image_kv_pairs = container_image_name_updates.split(',')
        for index, kv_pair in enumerate(image_kv_pairs):
            kv = kv_pair.split('=')
            key = kv[0].strip()
            if key == 'container':
                container_name = kv[1].strip()
                image_kv = image_kv_pairs[index+1].split('=')
                container_entry = container_map.get(container_name)
                if container_entry is None:
                    raise ValueError('The container ' + container_name + ' is not defined in the existing task definition')
                container_index = container_entry['index']
                image_specifier_type = image_kv[0].strip()
                image_value = image_kv[1].strip()
                if image_specifier_type == 'image-and-tag':
                    container_definitions[container_index]['image'] = image_value
                else:
                    existing_image_name_tokens = container_entry['image'].split(':')
                    if image_specifier_type == 'image':
                        tag = ''
                        if len(existing_image_name_tokens) == 2:
                            tag = ':' + existing_image_name_tokens[1]
                        container_definitions[container_index]['image'] = image_value + tag
                    elif image_specifier_type == 'tag':
                        container_definitions[container_index]['image'] = existing_image_name_tokens[0] + ':' + image_value
                    else:
                        raise ValueError(
                            'Image name update parameter format is incorrect: ' + container_image_name_updates)
            elif key and key not in ['container', 'image', 'image-and-tag', 'tag']:
                raise ValueError('Incorrect key found in image name update parameter: ' + key)

    except ValueError as value_error:
        raise value_error
    except:
        raise Exception('Image name update parameter could not be processed; please check parameter value: ' + container_image_name_updates)
    return json.dumps(container_definitions)

def __chunk(elements, n):
    for i in range(0, len(elements), n):
        yield elements[i:i + n]

def __groupby(elements, key):
    for key, group in groupby(sorted(elements, key=key), key):
        yield key, group

def __upsert_container_definitions(container_definitions, config_updates, definition_key, config_keys):
        try:
            container, name, value = config_keys
            container_map = {
                container_definition[name]: {
                    'index': index,
                    'map': {
                        dict[name]: dict[value]
                        for dict in (container_definition.get(definition_key) or [])
                    }
                }
                for index, container_definition in enumerate(container_definitions)
            }

            chunks = __chunk(config_updates.split(','), 3)
            # [
            #     ["container=x", "name=y", "value=z"]
            # ]

            map_updates = [
                { 
                    key_value_pair.split("=")[0]: key_value_pair.split("=")[1]
                    for key_value_pair in chunk if key_value_pair
                }
                for chunk in chunks
            ]
            map_updates = [
                dict
                for dict in map_updates if dict # remove empty dict
            ]
            # [
            #     {"container": "x", "name": "y", "value": "z"}
            # ]

            for update in map_updates:
                if sorted(update.keys()) != config_keys:
                    raise ValueError("Incorrect key found in {} variable update parameter: {}".format(definition_key, update.keys))

            for container_name, group in __groupby(map_updates, lambda x: x[container]):
                upsert_group_map = {
                    g[name]: g[value]
                    for g in group
                }
                container_entry = container_map.get(container_name)
                if container_entry is None:
                    raise ValueError('The container ' + container_name + ' is not defined in the existing task definition')
                container_index = container_entry['index']
                new_map = dict(
                    container_entry['map'],
                    **upsert_group_map
                )
                container_definitions[container_index]['environment'] = [
                    {'name': key, 'value': value}
                    for key, value in new_map.items()
                ]
        except ValueError as value_error:
            raise value_error
        except:
            raise Exception("{} variable update parameter could not be processed; please check parameter value: {}".format(definition_key, config_updates))


if __name__ == '__main__':
    try:
        print(run(sys.argv[1], sys.argv[2], sys.argv[3]))
    except Exception as e:
        sys.stderr.write(str(e) + "\n")
        exit(1)
