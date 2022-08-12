set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ECS_PARAM_CD_APP_NAME=$(eval echo "$ECS_PARAM_CD_APP_NAME")
ECS_PARAM_CD_DEPLOY_GROUP_NAME=$(eval echo "$ECS_PARAM_CD_DEPLOY_GROUP_NAME")
ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME=$(eval echo "$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME")
ECS_PARAM_CD_DEPLOYMENT_CONFIG_NAME=$(eval echo "$ECS_PARAM_CD_DEPLOYMENT_CONFIG_NAME")

DEPLOYED_REVISION="${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}"

if [ "$ECS_PARAM_ENABLE_CIRCUIT_BREAKER" == "1" ] && [ "$ECS_PARAM_VERIFY_REV_DEPLOY" == "0" ]; then
    echo "enable-circuit-breaker is set to true, but verify-revision-deploy is set to false.  verfiy-revision-deploy must be set to true to use enable-circuit-breaker."
    exit 1
fi

if [ -n "$ECS_PARAM_CD_CAPACITY_PROVIDER_NAME" ]; then 
    if [ -z "$ECS_PARAM_CD_CAPACITY_PROVIDER_WEIGHT" ] || [ -z "$ECS_PARAM_CD_CAPACITY_PROVIDER_BASE" ]; then 
        echo "Capacity Provider base and weight parameter must all be provided. Please try again"
        exit 1
    else 
        REVISION="{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_PORT},\\\"CapacityProviderStrategy\\\":[{\\\"CapacityProvider\\\":\\\"$ECS_PARAM_CD_CAPACITY_PROVIDER_NAME\\\", \\\"Base\\\":${ECS_PARAM_CD_CAPACITY_PROVIDER_BASE}, \\\"Weight\\\":${ECS_PARAM_CD_CAPACITY_PROVIDER_WEIGHT}}]}}}]}\"}}"
    fi
else
    REVISION="{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_PORT}}}}]}\"}}"
fi 

if [ -n "$ECS_PARAM_CD_DEPLOYMENT_CONFIG_NAME" ]; then
    set -- "$@" --deployment-config-name "${ECS_PARAM_CD_DEPLOYMENT_CONFIG_NAME}"
fi

DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name "$ECS_PARAM_CD_APP_NAME" \
    --deployment-group-name "$ECS_PARAM_CD_DEPLOY_GROUP_NAME" \
    --query deploymentId \
    --revision "${REVISION}" \
    "$@" \
    --output text)

echo "Created CodeDeploy deployment: $DEPLOYMENT_ID"

if [ "$ECS_PARAM_VERIFY_REV_DEPLOY" == "1" ]; then
    echo "Waiting for deployment to succeed."
    if aws deploy wait deployment-successful --deployment-id "${DEPLOYMENT_ID}"; then
        echo "Deployment succeeded."
    elif [ "$ECS_PARAM_ENABLE_CIRCUIT_BREAKER" == "1" ]; then
        echo "Deployment failed. Rolling back."
        aws deploy stop-deployment --deployment-id "${DEPLOYMENT_ID}" --auto-rollback-enabled
    else
        echo "Deployment failed. Exiting."
        exit 1
    fi
fi

echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"
