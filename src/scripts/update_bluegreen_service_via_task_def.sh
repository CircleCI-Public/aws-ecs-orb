set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ORB_EVAL_CD_APP_NAME=$(circleci env subst "$ORB_EVAL_CD_APP_NAME")
ORB_EVAL_CD_DEPLOY_GROUP_NAME=$(circleci env subst "$ORB_EVAL_CD_DEPLOY_GROUP_NAME")
ORB_EVAL_CD_LOAD_BALANCED_CONTAINER_NAME=$(circleci env subst "$ORB_EVAL_CD_LOAD_BALANCED_CONTAINER_NAME")
ORB_EVAL_CD_CAPACITY_PROVIDER_WEIGHT=$(circleci env subst "$ORB_EVAL_CD_CAPACITY_PROVIDER_WEIGHT")
ORB_EVAL_CD_CAPACITY_PROVIDER_BASE=$(circleci env subst "$ORB_EVAL_CD_CAPACITY_PROVIDER_BASE")
ORB_EVAL_CD_DEPLOYMENT_CONFIG_NAME=$(circleci env subst "$ORB_EVAL_CD_DEPLOYMENT_CONFIG_NAME")

DEPLOYED_REVISION="${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}"

if [ "$ORB_VAL_ENABLE_CIRCUIT_BREAKER" == "1" ] && [ "$ORB_VAL_VERIFY_REV_DEPLOY" == "0" ]; then
    echo "enable-circuit-breaker is set to true, but verify-revision-deploy is set to false.  verfiy-revision-deploy must be set to true to use enable-circuit-breaker."
    exit 1
fi

if [ -n "$ORB_EVAL_CD_CAPACITY_PROVIDER_NAME" ]; then 
    if [ -z "$ORB_EVAL_CD_CAPACITY_PROVIDER_WEIGHT" ] || [ -z "$ORB_EVAL_CD_CAPACITY_PROVIDER_BASE" ]; then 
        echo "Capacity Provider base and weight parameter must all be provided. Please try again"
        exit 1
    else 
        REVISION="{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ORB_EVAL_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ORB_VAL_CD_LOAD_BALANCED_CONTAINER_PORT},\\\"CapacityProviderStrategy\\\":[{\\\"CapacityProvider\\\":\\\"$ORB_EVAL_CD_CAPACITY_PROVIDER_NAME\\\", \\\"Base\\\":${ORB_EVAL_CD_CAPACITY_PROVIDER_BASE}, \\\"Weight\\\":${ORB_EVAL_CD_CAPACITY_PROVIDER_WEIGHT}}]}}}]}\"}}"
    fi
else
    REVISION="{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ORB_EVAL_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ORB_VAL_CD_LOAD_BALANCED_CONTAINER_PORT}}}}]}\"}}"
fi 

if [ -n "$ORB_EVAL_CD_DEPLOYMENT_CONFIG_NAME" ]; then
    set -- "$@" --deployment-config-name "${ORB_EVAL_CD_DEPLOYMENT_CONFIG_NAME}"
fi

DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name "$ORB_EVAL_CD_APP_NAME" \
    --deployment-group-name "$ORB_EVAL_CD_DEPLOY_GROUP_NAME" \
    --query deploymentId \
    --revision "${REVISION}" \
    "$@" \
    --output text)

echo "Created CodeDeploy deployment: $DEPLOYMENT_ID"

if [ "$ORB_VAL_VERIFY_REV_DEPLOY" == "1" ]; then
    echo "Waiting for deployment to succeed."
    if aws deploy wait deployment-successful --deployment-id "${DEPLOYMENT_ID}"; then
        echo "Deployment succeeded."
    elif [ "$ORB_VAL_ENABLE_CIRCUIT_BREAKER" == "1" ]; then
        echo "Deployment failed. Rolling back."
        aws deploy stop-deployment --deployment-id "${DEPLOYMENT_ID}" --auto-rollback-enabled
    else
        echo "Deployment failed. Exiting."
        exit 1
    fi
fi

echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"
