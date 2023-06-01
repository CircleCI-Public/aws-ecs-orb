if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_EVAL_CLUSTER_NAME=$(circleci env subst "$ORB_EVAL_CLUSTER_NAME")
ORB_EVAL_TASK_DEF=$(circleci env subst "$ORB_EVAL_TASK_DEF")
ORB_EVAL_STARTED_BY=$(circleci env subst "$ORB_EVAL_STARTED_BY")
ORB_EVAL_GROUP=$(circleci env subst "$ORB_EVAL_GROUP")
ORB_EVAL_PLACEMENT_STRATEGY=$(circleci env subst "$ORB_EVAL_PLACEMENT_STRATEGY")
ORB_EVAL_PLACEMENT_CONSTRAINTS=$(circleci env subst "$ORB_EVAL_PLACEMENT_CONSTRAINTS")
ORB_EVAL_PLATFORM_VERSION=$(circleci env subst "$ORB_EVAL_PLATFORM_VERSION")
ORB_EVAL_TAGS=$(circleci env subst "$ORB_EVAL_TAGS")
ORB_EVAL_CD_CAPACITY_PROVIDER_STRATEGY=$(circleci env subst "$ORB_EVAL_CD_CAPACITY_PROVIDER_STRATEGY")
ORB_EVAL_RUN_TASK_OUTPUT=$(circleci env subst "$ORB_EVAL_RUN_TASK_OUTPUT")
ORB_EVAL_PROFILE_NAME=$(circleci env subst "$ORB_EVAL_PROFILE_NAME")

if [[ "$ORB_EVAL_OVERRIDES" == *"\${"* ]]; then
    ORB_EVAL_OVERRIDES=$(echo "${ORB_EVAL_OVERRIDES}" | circleci env subst)
fi

set -o noglob
if [ -n "$ORB_EVAL_PLATFORM_VERSION" ]; then
    echo "Setting --platform-version"
    set -- "$@" --platform-version "$ORB_EVAL_PLATFORM_VERSION"
fi
if [ -n "$ORB_EVAL_STARTED_BY" ]; then
    echo "Setting --started-by"
    set -- "$@" --started-by "$ORB_EVAL_STARTED_BY"
fi
if [ -n "$ORB_EVAL_GROUP" ]; then
    echo "Setting --group"
    set -- "$@" --group "$ORB_EVAL_GROUP"
fi
if [ -n "$ORB_EVAL_OVERRIDES" ]; then
    echo "Setting --overrides"
    set -- "$@" --overrides "$ORB_EVAL_OVERRIDES"
fi
if [ -n "$ORB_EVAL_TAGS" ]; then
    echo "Setting --tags"
    set -- "$@" --tags "$ORB_EVAL_TAGS"
fi
if [ -n "$ORB_EVAL_PLACEMENT_CONSTRAINTS" ]; then
    echo "Setting --placement-constraints"
    set -- "$@" --placement-constraints "$ORB_EVAL_PLACEMENT_CONSTRAINTS"
fi
if [ -n "$ORB_EVAL_PLACEMENT_STRATEGY" ]; then
    echo "Setting --placement-strategy"
    set -- "$@" --placement-strategy "$ORB_EVAL_PLACEMENT_STRATEGY"
fi
if [ "$ORB_VAL_ENABLE_ECS_MANAGED_TAGS" == "1" ]; then
    echo "Setting --enable-ecs-managed-tags"
    set -- "$@" --enable-ecs-managed-tags
fi
if [ "$ORB_VAL_PROPAGATE_TAGS" == "1" ]; then
    echo "Setting --propagate-tags"
    set -- "$@" --propagate-tags "TASK_DEFINITION"
fi
if [ "$ORB_VAL_AWSVPC" == "1" ]; then
    echo "Setting --network-configuration"
    if [ -z "$ORB_EVAL_SUBNET_ID" ]; then
        echo '"subnet-ids" is missing.'
        echo 'When "awsvpc" is enabled, "subnet-ids" must be provided.'
        exit 1
    fi
    ORB_EVAL_SUBNET_ID=$(circleci env subst "$ORB_EVAL_SUBNET_ID")
    ORB_EVAL_SEC_GROUP_ID=$(circleci env subst "$ORB_EVAL_SEC_GROUP_ID")
    set -- "$@" --network-configuration awsvpcConfiguration="{subnets=[$ORB_EVAL_SUBNET_ID],securityGroups=[$ORB_EVAL_SEC_GROUP_ID],assignPublicIp=$ORB_VAL_ASSIGN_PUB_IP}"
fi
if [ -n "$ORB_EVAL_CD_CAPACITY_PROVIDER_STRATEGY" ]; then
    echo "Setting --capacity-provider-strategy"
    # do not quote
    # shellcheck disable=SC2086
    set -- "$@" --capacity-provider-strategy $ORB_EVAL_CD_CAPACITY_PROVIDER_STRATEGY
fi

if [ -n "$ORB_VAL_LAUNCH_TYPE" ]; then
    if [ -n "$ORB_EVAL_CD_CAPACITY_PROVIDER_STRATEGY" ]; then
        echo "Error: "
        echo 'If a "capacity-provider-strategy" is specified, the "launch-type" parameter must be set to an empty string.'
        exit 1
    else
        echo "Setting --launch-type"
        set -- "$@" --launch-type "$ORB_VAL_LAUNCH_TYPE"
    fi
fi


echo "Setting --count"
set -- "$@" --count "$ORB_VAL_COUNT"
echo "Setting --task-definition"
set -- "$@" --task-definition "$ORB_EVAL_TASK_DEF"
echo "Setting --cluster"
set -- "$@" --cluster "$ORB_EVAL_CLUSTER_NAME"


if [ -n "${ORB_EVAL_RUN_TASK_OUTPUT}" ]; then
    set -x
    aws ecs run-task --profile "${ORB_EVAL_PROFILE_NAME}" "$@" | tee "${ORB_EVAL_RUN_TASK_OUTPUT}"
    set +x
else
    set -x    
    aws ecs run-task --profile "${ORB_EVAL_PROFILE_NAME}" "$@"
    set +x
fi
