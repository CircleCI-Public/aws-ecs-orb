#!/bin/bash
set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_STR_FAMILY="$(circleci env subst "$ORB_STR_FAMILY")"
ORB_STR_CLUSTER_NAME="$(circleci env subst "$ORB_STR_CLUSTER_NAME")"
ORB_STR_SERVICE_NAME="$(circleci env subst "$ORB_STR_SERVICE_NAME")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"

if [ -z "${ORB_STR_SERVICE_NAME}" ]; then
    ORB_STR_SERVICE_NAME="$ORB_STR_FAMILY"
fi

if [ "$ORB_BOOL_FORCE_NEW_DEPLOY" == "1" ]; then
    set -- "$@" --force-new-deployment
fi

if [ "$ORB_BOOL_ENABLE_CIRCUIT_BREAKER" == "1" ]; then
    set -- "$@" --deployment-configuration "deploymentCircuitBreaker={enable=true,rollback=true}"
fi

DEPLOYED_REVISION=$(aws ecs update-service \
    --profile "${ORB_STR_PROFILE_NAME}" \
    --cluster "$ORB_STR_CLUSTER_NAME" \
    --service "${ORB_STR_SERVICE_NAME}" \
    --task-definition "${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
    --output text \
    --query service.taskDefinition \
    "$@")
echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"
