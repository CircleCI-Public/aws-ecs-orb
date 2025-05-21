#!/bin/bash
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"
ORB_STR_TASK_DEFINITION_JSON="$(circleci env subst "$ORB_STR_TASK_DEFINITION_JSON")"
ORB_AWS_REGION="$(circleci env subst "$ORB_AWS_REGION")"

if [ "${ORB_STR_TASK_DEFINITION_JSON:0:1}" != "/" ]; then
    ORB_STR_TASK_DEFINITION_JSON="$(pwd)/${ORB_STR_TASK_DEFINITION_JSON}"
fi

REVISION=$(aws ecs register-task-definition \
    --profile "${ORB_STR_PROFILE_NAME}" \
    --cli-input-json file://"${ORB_STR_TASK_DEFINITION_JSON}" \
    --output text \
    --region "${ORB_AWS_REGION}" \
    --query 'taskDefinition.taskDefinitionArn' \
    "$@")
echo "Registered task definition: ${REVISION}"

echo "export CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN='${REVISION}'" >> "$BASH_ENV"
