set -o noglob
SERVICE_NAME="$(echo << parameters.service-name >>)"

if [ -z "${SERVICE_NAME}" ]; then
  SERVICE_NAME="$(echo << parameters.family >>)"
fi
if [ "<< parameters.force-new-deployment >>" == "true" ]; then
  set -- "$@" --force-new-deployment
fi

DEPLOYED_REVISION=$(aws ecs update-service \
  --cluster "<< parameters.cluster-name >>" \
  --service "${SERVICE_NAME}" \
  --task-definition "
${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
  --output text \
  --query service.taskDefinition "$@")
echo "export CCI_ORB_AWS_ECS_DEPLOYED_REVISION='${DEPLOYED_REVISION}'" >> $BASH_ENV
