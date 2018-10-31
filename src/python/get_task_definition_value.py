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
    json_arr_types = ['placementConstraints', 'volumes']
    if element_name in json_arr_types:
        output_value = '[]'
    else:
        output_value = ''
    if element_name in task_definition:
        element_value = task_definition[element_name]
        if element_name in str_list_types:
            for i, list_item in enumerate(element_value):
                output_value += list_item.strip()
                if len(element_value) - 1 > i:
                    output_value += ' '
        elif element_name in json_arr_types:
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
