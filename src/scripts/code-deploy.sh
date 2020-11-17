set -o noglob
DEPLOYMENT_CONTROLLER="$(echo << parameters.deployment-controller >>)"
DEPLOYED_REVISION="${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}"
DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name "<< parameters.codedeploy-application-name >>" \
    --deployment-group-name "<< parameters.codedeploy-deployment-group-name >>" \
    --revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": \
       {\"content\": \"{\"version\": 1, \"Resources\": [{\"TargetService\": \
              {\"Type\": \"AWS::ECS::Service\", \"Properties\": \
              {\"TaskDefinition\": \"${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}\", \
              \"LoadBalancerInfo\": {\"ContainerName\": \"<< parameters.codedeploy-load-balanced-container-name >>\", \"ContainerPort\": << parameters.codedeploy-load-balanced-container-port >>}}}}]}\"}}" \
    --query deploymentId \
    --output text)

echo "Created CodeDeploy deployment: $DEPLOYMENT_ID"
if [ "<< parameters.verify-revision-is-deployed >>" == "true" ]; then
  echo "Waiting for deployment to succeed."
  if $(aws deploy wait deployment-successful --deployment-id ${DEPLOYMENT_ID}); then
    echo "Deployment succeeded."
  else
    echo "Deployment failed."
    exit 1
  fi
fi
echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> $BASH_ENV
