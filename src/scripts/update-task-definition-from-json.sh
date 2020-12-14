if [ "${ECS_PARAM_TASK_DEFINITION_JSON:0:1}" != "/" ]; then
    ECS_PARAM_TASK_DEFINITION_JSON="$(pwd)/${ECS_PARAM_TASK_DEFINITION_JSON}"
fi

REVISION=$(aws ecs register-task-definition \
    --cli-input-json file://"${ECS_PARAM_TASK_DEFINITION_JSON}" \
    --output text \
    --query 'taskDefinition.taskDefinitionArn')
echo "Registered task definition: ${REVISION}"

echo "export CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN='${REVISION}'" >> "$BASH_ENV"
