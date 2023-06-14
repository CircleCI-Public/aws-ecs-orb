#!/bin/bash
# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_STR_FAMILY="$(circleci env subst "$ORB_STR_FAMILY")"
ORB_STR_SERVICE_NAME="$(circleci env subst "$ORB_STR_SERVICE_NAME")"
ORB_STR_CLUSTER_NAME="$(circleci env subst "$ORB_STR_CLUSTER_NAME")"
ORB_STR_TASK_DEF_ARN="$(circleci env subst "$ORB_STR_TASK_DEF_ARN")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"

if [ "$ORB_STR_TASK_DEF_ARN" = "" ]; then
    echo "Invalid task-definition-arn parameter value: $ORB_STR_TASK_DEF_ARN"
    exit 1
fi


if [ -z "${ORB_STR_SERVICE_NAME}" ]; then
    ORB_STR_SERVICE_NAME="$ORB_STR_FAMILY"
fi

echo "Verifying that $ORB_STR_TASK_DEF_ARN is deployed.."

attempt=0

while [ "$attempt" -lt "$ORB_VAL_MAX_POLL_ATTEMPTS" ]

do
    DEPLOYMENTS=$(aws ecs describe-services \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --cluster "$ORB_STR_CLUSTER_NAME" \
        --services "${ORB_STR_SERVICE_NAME}" \
        --output text \
        --query 'services[0].deployments[].[taskDefinition, status]' \
        "$@")
    NUM_DEPLOYMENTS=$(aws ecs describe-services \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --cluster "$ORB_STR_CLUSTER_NAME" \
        --services "${ORB_STR_SERVICE_NAME}" \
        --output text \
        --query 'length(services[0].deployments)' \
        "$@")
    TARGET_REVISION=$(aws ecs describe-services \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --cluster "$ORB_STR_CLUSTER_NAME" \
        --services "${ORB_STR_SERVICE_NAME}" \
        --output text \
        --query "services[0].deployments[?taskDefinition==\`$ORB_STR_TASK_DEF_ARN\` && runningCount == desiredCount && (status == \`PRIMARY\` || status == \`ACTIVE\`)][taskDefinition]" \
        "$@")
    echo "Current deployments: $DEPLOYMENTS"
    if [ "$NUM_DEPLOYMENTS" = "1" ] && [ "$TARGET_REVISION" = "$ORB_STR_TASK_DEF_ARN" ]; then
        echo "The task definition revision $TARGET_REVISION is the only deployment for the service and has attained the desired running task count."
        exit 0
    else
        echo "Waiting for revision $ORB_STR_TASK_DEF_ARN to reach desired running count / older revisions to be stopped.."
        sleep "$ORB_VAL_POLL_INTERVAL"
    fi
    attempt=$((attempt + 1))
done

echo "Stopped waiting for deployment to be stable - please check the status of $ORB_STR_TASK_DEF_ARN on the AWS ECS console."

if [ "$ORB_VAL_FAIL_ON_VERIFY_TIMEOUT" = "1" ]; then
    exit 1
fi

