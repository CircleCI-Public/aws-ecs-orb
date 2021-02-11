set -o noglob

# These variables are evaluated so the config file may contain and pass in environment variables to the parameters.
ECS_PARAM_CD_APP_NAME=$(eval echo "$ECS_PARAM_CD_APP_NAME")
ECS_PARAM_CD_DEPLOY_GROUP_NAME=$(eval echo "$ECS_PARAM_CD_DEPLOY_GROUP_NAME")
ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME=$(eval echo "$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME")


DEPLOYED_REVISION="${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}"

DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name "$ECS_PARAM_CD_APP_NAME" \
    --deployment-group-name "$ECS_PARAM_CD_DEPLOY_GROUP_NAME" \
    --revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": \"{\\\"version\\\": 1, \\\"Resources\\\": [{\\\"TargetService\\\": {\\\"Type\\\": \\\"AWS::ECS::Service\\\", \\\"Properties\\\": {\\\"TaskDefinition\\\": \\\"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\\\", \\\"LoadBalancerInfo\\\": {\\\"ContainerName\\\": \\\"$ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_NAME\\\", \\\"ContainerPort\\\": $ECS_PARAM_CD_LOAD_BALANCED_CONTAINER_PORT}}}}]}\"}}" \
    --query deploymentId \
    --output text)
echo "Created CodeDeploy deployment: $DEPLOYMENT_ID"

if [ "$ECS_PARAM_VERIFY_REV_DEPLOY" == "1" ]; then
    echo "Waiting for deployment to succeed."
    if $(aws deploy wait deployment-successful --deployment-id "${DEPLOYMENT_ID}"); then
        echo "Deployment succeeded."
    else
        echo "Deployment failed."
        exit 1
    fi
fi

echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> "$BASH_ENV"