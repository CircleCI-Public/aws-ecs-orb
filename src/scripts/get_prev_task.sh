#!/bin/bash
set -o noglob

# These variables are STRuated so the config file may contain and pass in environment variables to the parameters.
ORB_STR_FAMILY="$(circleci env subst "$ORB_STR_FAMILY")"
ORB_STR_CONTAINER_IMAGE_NAME_UPDATES="$(circleci env subst "$ORB_STR_CONTAINER_IMAGE_NAME_UPDATES")"
ORB_STR_CONTAINER_ENV_VAR_UPDATE="$(circleci env subst "$ORB_STR_CONTAINER_ENV_VAR_UPDATE")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"
ORB_STR_CONTAINER_SECRET_UPDATES="$(circleci env subst "$ORB_STR_CONTAINER_SECRET_UPDATES")"
ORB_STR_CONTAINER_DOCKER_LABEL_UPDATES="$(circleci env subst "$ORB_STR_CONTAINER_DOCKER_LABEL_UPDATES")"
ORB_STR_PREVIOUS_REVISION_NUMBER="$(circleci env subst "$ORB_STR_PREVIOUS_REVISION_NUMBER")"

if [ -z "${ECS_PARAM_PREVIOUS_REVISION}" ]; then
  ECS_TASK_DEFINITION_NAME="$ORB_STR_FAMILY"
else
  ECS_TASK_DEFINITION_NAME="$ORB_STR_FAMILY:$ORB_STR_PREVIOUS_REVISION_NUMBER"
fi

# shellcheck disable=SC2034
PREVIOUS_TASK_DEFINITION="$(aws ecs describe-task-definition --task-definition "${ECS_TASK_DEFINITION_NAME}" --include TAGS --profile "${ORB_STR_PROFILE_NAME}" "$@")"

# Prepare script for updating container definitions

UPDATE_CONTAINER_DEFS_SCRIPT_FILE=$(mktemp _update_container_defs.py.XXXXXX)
chmod +x "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE"

cat <<< "$ECS_SCRIPT_UPDATE_CONTAINER_DEFS" > "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE"


# Prepare container definitions
CONTAINER_DEFS="$(python "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE" "$PREVIOUS_TASK_DEFINITION" "$ORB_STR_CONTAINER_IMAGE_NAME_UPDATES" "$ORB_STR_CONTAINER_ENV_VAR_UPDATE" "$ORB_STR_CONTAINER_SECRET_UPDATES" "$ORB_STR_CONTAINER_DOCKER_LABEL_UPDATES")"

# Escape single quotes from environment variables for BASH_ENV

CLEANED_CONTAINER_DEFS=$(echo "$CONTAINER_DEFS" | sed -E "s:':'\\\'':g")

# Prepare script for getting task definition values

GET_TASK_DFN_VAL_SCRIPT_FILE=$(mktemp _get_task_def_value.py.XXXXXX)
chmod +x "$GET_TASK_DFN_VAL_SCRIPT_FILE"

cat <<< "$ECS_SCRIPT_GET_TASK_DFN_VAL" > "$GET_TASK_DFN_VAL_SCRIPT_FILE"



# Get other task definition values

TASK_ROLE=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'taskRoleArn' "$PREVIOUS_TASK_DEFINITION")

EXECUTION_ROLE=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'executionRoleArn' "$PREVIOUS_TASK_DEFINITION")

NETWORK_MODE=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'networkMode' "$PREVIOUS_TASK_DEFINITION")

VOLUMES=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'volumes' "$PREVIOUS_TASK_DEFINITION")

PLACEMENT_CONSTRAINTS=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'placementConstraints' "$PREVIOUS_TASK_DEFINITION")

REQ_COMP=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'requiresCompatibilities' "$PREVIOUS_TASK_DEFINITION")

TASK_CPU=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'cpu' "$PREVIOUS_TASK_DEFINITION")

TASK_MEMORY=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'memory' "$PREVIOUS_TASK_DEFINITION")

PID_MODE=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'pidMode' "$PREVIOUS_TASK_DEFINITION")

IPC_MODE=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'ipcMode' "$PREVIOUS_TASK_DEFINITION")

TAGS=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'tags' "$PREVIOUS_TASK_DEFINITION")

PROXY_CONFIGURATION=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'proxyConfiguration' "$PREVIOUS_TASK_DEFINITION")

RUNTIME_PLATFORM=$(python "$GET_TASK_DFN_VAL_SCRIPT_FILE" 'runtimePlatform' "$PREVIOUS_TASK_DEFINITION")

EPHEMERAL_STORAGE=$(echo "${PREVIOUS_TASK_DEFINITION}" | jq ".taskDefinition.ephemeralStorage //empty" -c)

# Make task definition values available as env variables
# shellcheck disable=SC2129
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

echo "export CCI_ORB_AWS_ECS_RUNTIME_PLATFORM='${RUNTIME_PLATFORM}'" >> "$BASH_ENV"

echo "export CCI_ORB_AWS_ECS_EPHEMERAL_STORAGE='${EPHEMERAL_STORAGE}'" >> "$BASH_ENV"

rm "$UPDATE_CONTAINER_DEFS_SCRIPT_FILE" "$GET_TASK_DFN_VAL_SCRIPT_FILE"
