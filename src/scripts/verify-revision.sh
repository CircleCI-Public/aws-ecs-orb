if [ "<< parameters.task-definition-arn >>" = "" ]; then
    echo "Invalid task-definition-arn parameter value: << parameters.task-definition-arn >>"
    exit 1
fi

SERVICE_NAME="$(echo << parameters.service-name >>)"\
      

if [ -z "${SERVICE_NAME}" ]; then
    SERVICE_NAME="$(echo << parameters.family >>)"
fi

echo "Verifying that << parameters.task-definition-arn >> is deployed.."
attempt=0
while [ "$attempt" -lt << parameters.max-poll-attempts >> ]
do
    DEPLOYMENTS=$(aws ecs describe-services \
        --cluster << parameters.cluster-name >> \
        --services ${SERVICE_NAME} \
        --output text \
        --query 'services[0].deployments[].[taskDefinition, status]')
    NUM_DEPLOYMENTS=$(aws ecs describe-services \
        --cluster << parameters.cluster-name >> \
        --services ${SERVICE_NAME} \
        --output text \
        --query 'length(services[0].deployments)')
    TARGET_REVISION=$(aws ecs describe-services \
        --cluster << parameters.cluster-name >> \
        --services ${SERVICE_NAME} \
        --output text \
        --query "services[0].deployments[?taskDefinition==\`<< parameters.task-definition-arn >>\` && runningCount == desiredCount && (status == \`PRIMARY\` || status == \`ACTIVE\`)][taskDefinition]")
    echo "Current deployments: $DEPLOYMENTS"\
      
    if [ "$NUM_DEPLOYMENTS" = "1" ] && [ "$TARGET_REVISION" = "<< parameters.task-definition-arn >>" ]; then
        echo "The task definition revision $TARGET_REVISION is the only deployment for the service and has attained the desired running task count."
        exit 0
    else
        echo "Waiting for revision << parameters.task-definition-arn >> to reach desired running count / older revisions to be stopped.."
        sleep << parameters.poll-interval >>
    fi
    attempt=$((attempt + 1))
done
echo "Stopped waiting for deployment to be stable - please check the status of << parameters.task-definition-arn >> on the AWS ECS console."
<<# parameters.fail-on-verification-timeout >>exit 1<</ parameters.fail-on-verification-timeout >>
