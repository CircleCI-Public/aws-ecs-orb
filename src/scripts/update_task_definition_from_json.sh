ORB_EVAL_PROFILE_NAME=$(circleci env subst "$ORB_EVAL_PROFILE_NAME")
ORB_EVAL_TASK_DEFINITION_JSON=$(circleci env subst "$ORB_EVAL_TASK_DEFINITION_JSON")

if [ "${ORB_EVAL_TASK_DEFINITION_JSON:0:1}" != "/" ]; then
    ORB_EVAL_TASK_DEFINITION_JSON="$(pwd)/${ORB_EVAL_TASK_DEFINITION_JSON}"
fi

REVISION=$(aws ecs register-task-definition \
    --profile "${ORB_EVAL_PROFILE_NAME}" \
    --cli-input-json file://"${ORB_EVAL_TASK_DEFINITION_JSON}" \
    --output text \
    --query 'taskDefinition.taskDefinitionArn' \
    "$@")
echo "Registered task definition: ${REVISION}"

echo "export CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN='${REVISION}'" >> "$BASH_ENV"
