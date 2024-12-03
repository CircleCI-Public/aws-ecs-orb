#!/bin/bash
set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_STR_FAMILY="$(circleci env subst "$ORB_STR_FAMILY")"
ORB_STR_CLUSTER_NAME="$(circleci env subst "$ORB_STR_CLUSTER_NAME")"
ORB_STR_SERVICE_NAME="$(circleci env subst "$ORB_STR_SERVICE_NAME")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"
ORB_AWS_REGION="$(circleci env subst "$ORB_AWS_REGION")"

SERVICE_EXISTS=$(aws ecs describe-services \
    --profile "${ORB_STR_PROFILE_NAME}" \
    --cluster "$ORB_STR_CLUSTER_NAME" \
    --services "${ORB_STR_SERVICE_NAME}" \
    --query "services[?serviceName=='$ORB_STR_SERVICE_NAME'].serviceName" \
    --region "${ORB_AWS_REGION}" \
    --output text
)
echo "$SERVICE_EXISTS"
if [ -z "${ORB_STR_SERVICE_NAME}" ]; then
    ORB_STR_SERVICE_NAME="$ORB_STR_FAMILY"
fi

if [ "$ORB_BOOL_FORCE_NEW_DEPLOY" == "1" ] && [ -n "$SERVICE_EXISTS" ]; then
    set -- "$@" --force-new-deployment
fi

if [ "$ORB_BOOL_ENABLE_CIRCUIT_BREAKER" == "1" ]; then
    set -- "$@" --deployment-configuration "deploymentCircuitBreaker={enable=true,rollback=true}"
fi

if [ -n "$ORB_AWS_DESIRED_COUNT" ]; then
    set -- "$@" --desired-count "$ORB_AWS_DESIRED_COUNT"
fi

if [ -z "$SERVICE_EXISTS" ]; then
    echo "The service doesn't exist"
    if [ "$ORB_AWS_CREATE_SERVICE" = 1 ]; then
        NEW_SERVICE=$(aws ecs create-service \
            --cluster "$ORB_STR_CLUSTER_NAME" \
            --region "${ORB_AWS_REGION}" \
            --profile "${ORB_STR_PROFILE_NAME}" \
            --service-name "${ORB_STR_SERVICE_NAME}" \
            --task-definition "${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
            --load-balancers "targetGroupArn=$ORB_STR_TARGET_GROUP,containerName=$ORB_STR_CONTAINER_NAME,containerPort=$ORB_CONTAINER_PORT" \
            "$@")
        echo "$NEW_SERVICE"
            # --network-configuration "awsvpcConfiguration={subnets=[$ORB_STR_SUBNETS],securityGroups=[$ORB_STR_SECURITY_GROUPS],assignPublicIp=$ORB_PUBLIC_IP}" \
    fi
else
    DEPLOYED_REVISION=$(aws ecs update-service \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --cluster "$ORB_STR_CLUSTER_NAME" \
        --service "${ORB_STR_SERVICE_NAME}" \
        --task-definition "${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
        --output text \
        --region "${ORB_AWS_REGION}" \
        --query service.taskDefinition \
        "$@")
    echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"
fi