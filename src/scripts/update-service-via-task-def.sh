set -o noglob

if [ -z "${SERVICE_NAME}" ]; then
    SERVICE_NAME="$ECS_PARAM_FAMILY"
fi

if [ "$ECS_PARAM_FORCE_NEW_DEPLOY" == "true" ]; then
    set -- "$@" --force-new-deployment
fi

DEPLOYED_REVISION=$(aws ecs update-service \
    --cluster "$ECS_PARAM_CLUSTER_NAME" \
    --service "${SERVICE_NAME}" \
    --task-definition "${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
    --output text \
    --query service.taskDefinition \
    "$@")
echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"