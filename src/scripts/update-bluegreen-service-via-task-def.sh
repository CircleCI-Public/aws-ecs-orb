set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ECS_PARAM_CD_APP_NAME=$(eval echo "$ECS_PARAM_CD_APP_NAME")
ECS_PARAM_CD_DEPLOY_GROUP_NAME=$(eval echo "$ECS_PARAM_CD_DEPLOY_GROUP_NAME")
ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME=$(eval echo "$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME")

DEPLOYED_REVISION="${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}"

if [ "$ECS_PARAM_ENABLE_CIRCUIT_BREAKER" == "1" ] && [ "$ECS_PARAM_VERIFY_REV_DEPLOY" == "0" ]; then
    echo "enable-circuit-breaker is set to true, but verify-revision-deploy is set to false.  verfiy-revision-deploy is must be set to true to use enable-circuit-breaker."
    exit 1
fi

DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name "$ECS_PARAM_CD_APP_NAME" \
    --deployment-group-name "$ECS_PARAM_CD_DEPLOY_GROUP_NAME" \
    --revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_PORT}}}}]}\"}}" \
    --query deploymentId \
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
