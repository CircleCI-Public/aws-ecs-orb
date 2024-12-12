#!/bin/bash
if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_STR_CLUSTER_NAME="$(circleci env subst "$ORB_STR_CLUSTER_NAME")"
ORB_STR_TASK_DEF="$(circleci env subst "$ORB_STR_TASK_DEF")"
ORB_STR_STARTED_BY="$(circleci env subst "$ORB_STR_STARTED_BY")"
ORB_STR_GROUP="$(circleci env subst "$ORB_STR_GROUP")"
ORB_STR_PLACEMENT_STRATEGY="$(circleci env subst "$ORB_STR_PLACEMENT_STRATEGY")"
ORB_STR_PLACEMENT_CONSTRAINTS="$(circleci env subst "$ORB_STR_PLACEMENT_CONSTRAINTS")"
ORB_STR_PLATFORM_VERSION="$(circleci env subst "$ORB_STR_PLATFORM_VERSION")"
ORB_STR_TAGS="$(circleci env subst "$ORB_STR_TAGS")"
ORB_STR_CD_CAPACITY_PROVIDER_STRATEGY="$(circleci env subst "$ORB_STR_CD_CAPACITY_PROVIDER_STRATEGY")"
ORB_STR_RUN_TASK_OUTPUT="$(circleci env subst "$ORB_STR_RUN_TASK_OUTPUT")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"
ORB_STR_ASSIGN_PUB_IP="$(circleci env subst "$ORB_STR_ASSIGN_PUB_IP")"
ORB_AWS_REGION="$(circleci env subst "$ORB_AWS_REGION")"
ORB_STR_EXIT_CODE_FROM="$(circleci env subst "$ORB_STR_EXIT_CODE_FROM")"

if [[ "$ORB_STR_OVERRIDES" == *"\${"* ]]; then
    ORB_STR_OVERRIDES="$(echo "${ORB_STR_OVERRIDES}" | circleci env subst)"
fi

set -o noglob
if [ -n "$ORB_STR_PLATFORM_VERSION" ]; then
    echo "Setting --platform-version"
    set -- "$@" --platform-version "$ORB_STR_PLATFORM_VERSION"
fi
if [ -n "$ORB_STR_STARTED_BY" ]; then
    echo "Setting --started-by"
    set -- "$@" --started-by "$ORB_STR_STARTED_BY"
fi
if [ -n "$ORB_STR_GROUP" ]; then
    echo "Setting --group"
    set -- "$@" --group "$ORB_STR_GROUP"
fi
if [ -n "$ORB_STR_OVERRIDES" ]; then
    echo "Setting --overrides"
    set -- "$@" --overrides "$ORB_STR_OVERRIDES"
fi
if [ -n "$ORB_STR_TAGS" ]; then
    echo "Setting --tags"
    set -- "$@" --tags "$ORB_STR_TAGS"
fi
if [ -n "$ORB_STR_PLACEMENT_CONSTRAINTS" ]; then
    echo "Setting --placement-constraints"
    set -- "$@" --placement-constraints "$ORB_STR_PLACEMENT_CONSTRAINTS"
fi
if [ -n "$ORB_STR_PLACEMENT_STRATEGY" ]; then
    echo "Setting --placement-strategy"
    set -- "$@" --placement-strategy "$ORB_STR_PLACEMENT_STRATEGY"
fi
if [ "$ORB_BOOL_ENABLE_ECS_MANAGED_TAGS" == "1" ]; then
    echo "Setting --enable-ecs-managed-tags"
    set -- "$@" --enable-ecs-managed-tags
fi
if [ "$ORB_BOOL_ENABLE_EXECUTE_COMMAND" == "1" ]; then
    echo "Setting --enable-execute-command"
    set -- "$@" --enable-execute-command
fi
if [ "$ORB_BOOL_PROPAGATE_TAGS" == "1" ]; then
    echo "Setting --propagate-tags"
    set -- "$@" --propagate-tags "TASK_DEFINITION"
fi
if [ "$ORB_BOOL_AWSVPC" == "1" ]; then
    echo "Setting --network-configuration"
    if [ -z "$ORB_STR_SUBNET_ID" ]; then
        echo '"subnet-ids" is missing.'
        echo 'When "awsvpc" is enabled, "subnet-ids" must be provided.'
        exit 1
    fi
    ORB_STR_SUBNET_ID="$(circleci env subst "$ORB_STR_SUBNET_ID")"
    ORB_STR_SEC_GROUP_ID="$(circleci env subst "$ORB_STR_SEC_GROUP_ID")"
    set -- "$@" --network-configuration awsvpcConfiguration="{subnets=[$ORB_STR_SUBNET_ID],securityGroups=[$ORB_STR_SEC_GROUP_ID],assignPublicIp=$ORB_STR_ASSIGN_PUB_IP}"
fi
if [ -n "$ORB_STR_CD_CAPACITY_PROVIDER_STRATEGY" ]; then
    echo "Setting --capacity-provider-strategy"
    # do not quote
    # shellcheck disable=SC2086
    set -- "$@" --capacity-provider-strategy $ORB_STR_CD_CAPACITY_PROVIDER_STRATEGY
fi
if [ -n "$ORB_VAL_LAUNCH_TYPE" ]; then
    if [ -n "$ORB_STR_CD_CAPACITY_PROVIDER_STRATEGY" ]; then
        echo "Error: "
        echo 'If a "capacity-provider-strategy" is specified, the "launch-type" parameter must be set to an empty string.'
        exit 1
    else
        echo "Setting --launch-type"
        set -- "$@" --launch-type "$ORB_VAL_LAUNCH_TYPE"
    fi
fi
if [ "$ORB_BOOL_WAIT_TASK_STOPPED" == "1" ]; then
    echo "Setting query to export taskArn"
    set -- "$@" --query 'tasks[].taskArn' --output text
fi

echo "Setting --count"
set -- "$@" --count "$ORB_INT_COUNT"
echo "Setting --task-definition"
set -- "$@" --task-definition "$ORB_STR_TASK_DEF"
echo "Setting --cluster"
set -- "$@" --cluster "$ORB_STR_CLUSTER_NAME"

if [ -n "${ORB_STR_RUN_TASK_OUTPUT}" ]; then
    if [ "$ORB_BOOL_WAIT_TASK_STOPPED" == "1" ]; then
        echo "Exporting the run_task_output parameter is not compatible with wait_task_stopped parameter."
        exit 1
    fi

    set -x
    aws ecs run-task --profile "${ORB_STR_PROFILE_NAME}" --region "${ORB_AWS_REGION}" "$@" | tee "${ORB_STR_RUN_TASK_OUTPUT}"
    set +x
else
    set -x
    ORB_STR_TASK_ARN=$(aws ecs run-task --profile "${ORB_STR_PROFILE_NAME}" --region "${ORB_AWS_REGION}" "$@")
    set +x
fi

if [ "$ORB_BOOL_WAIT_TASK_STOPPED" == "1" ]; then
    echo "Waiting for ECS task $ORB_STR_TASK_ARN to stop..."

    ORB_STR_WAIT_EXIT_CODE=$(aws ecs wait tasks-stopped \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --region "${ORB_AWS_REGION}" \
        --cluster "${ORB_STR_CLUSTER_NAME}" \
        --tasks "${ORB_STR_TASK_ARN}"; \
        echo $?
    )

    if [[ "${ORB_STR_WAIT_EXIT_CODE}" -ne 0 ]]; then
        echo "Stopped waiting for the task execution to end. Please check the status of $ORB_STR_TASK_ARN on the AWS ECS console."
        exit "${ORB_STR_WAIT_EXIT_CODE}"
    fi

    # Get exit code
    if [ -n "$ORB_STR_EXIT_CODE_FROM" ]; then
        ORB_STR_TASK_EXIT_CODE=$(aws ecs describe-tasks \
            --profile "${ORB_STR_PROFILE_NAME}" \
            --region "${ORB_AWS_REGION}" \
            --cluster "${ORB_STR_CLUSTER_NAME}" \
            --tasks "${ORB_STR_TASK_ARN}" \
            --query "tasks[0].containers[?name=='$ORB_STR_EXIT_CODE_FROM'].exitCode" \
            --output text)
    else
        # Assume the first container
        ORB_STR_TASK_EXIT_CODE=$(aws ecs describe-tasks \
            --profile "${ORB_STR_PROFILE_NAME}" \
            --region "${ORB_AWS_REGION}" \
            --cluster "${ORB_STR_CLUSTER_NAME}" \
            --tasks "${ORB_STR_TASK_ARN}" \
            --query "tasks[0].containers[0].exitCode" \
            --output text)
    fi

    if [ "${ORB_STR_TASK_EXIT_CODE:-1}" -eq 0 ]; then
        echo "The task execution ended successfully."
    else
        echo "The task execution ended with an error, please check the status and logs of $ORB_STR_TASK_ARN on the AWS ECS console."
    fi

    exit "${ORB_STR_TASK_EXIT_CODE:-1}"
fi
