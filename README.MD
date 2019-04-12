# AWS ECS Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/aws-ecs)](https://circleci.com/orbs/registry/orb/circleci/aws-ecs) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-ecs-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/orbs)

A CircleCI Orb to simplify deployments to Amazon Elastic Container Service (ECS). It supports EC2 and Fargate launch type deployments.

CircleCI orbs registry page: https://circleci.com/orbs/registry/orb/circleci/aws-ecs

## Features

This orb allows convenient updating of ECS services when only the Docker
image name/tag and/or environment variables in a service's container definitions need to be updated.
A sample project that demonstrates using the orb is available on this GitHub repository branch: https://github.com/CircleCI-Public/circleci-demo-aws-ecs-ecr/tree/simple_orb_demo

### Jobs

You can reference the following Jobs provided by this orb from a 2.1 Workflows configuration stanza.

- [**deploy-service-update**](#deploy-service-update) - Update an ECS service.
- [**update-task-definition**](#update-task-definition) - Update an ECS task definition without modifying a service.

#### deploy-service-update

##### Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH`. Otherwise, `pip` is required to be available as the job will then attempt to install `aws` via `pip`. The default profile of `aws` will be used.
- `bash` to be present in `/bin/bash`. Otherwise, `/bin/sh` will be used, but the orb has not been tested for compatibility with other shells.

##### Parameters

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| docker-image-for-job        | string  | "circleci/python:3.7.1"    | The docker image to be used for running this job on CircleCI |
| aws-access-key-id        | string  | $AWS_ACCESS_KEY_ID     | AWS access key id for IAM role. Defaulted to $AWS_ACCESS_KEY. |
| aws-secret-access-key        | string  | $AWS_SECRET_ACCESS_KEY    | AWS secret key for IAM role. Defaulted to $AWS_SECRET_ACCESS_KEY. |
| aws-region        | string  | $AWS_REGION    | AWS region to operate in. Defaulted to $AWS_REGION. |
| family        | string  |     | Name of the task definition's family |
| cluster-name   | string  |   | The short name or full ARN of the cluster that hosts the service |
| service-name   | string  |   | The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition. |
| container-image-name-updates      | string   | ""    | Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. <br>**Expected format**: container=\<container-name\>,image-and-tag=\<image-name\>:\<tag-name\>\|image=\<image-name\>\|tag=\<tag-name\>,container=...,image-and-tag\|image\|tag=... <br>For each container, specify only either `image-and-tag` or `image` or `tag`.<br>If `image-and-tag` is specified, the container image will be updated to the value of the name-value pair.<br>If `image` is specified, the image tag defined in the previous task definition will be retained, if exists.<br>If `tag` is specified, the image name defined in the previous task definition will be used. |
| container-env-var-updates        | string  | ""   | Use this to update or set the values of environment variables that will be defined for the containers. <br>**Expected format**: container=\<container-name\>,name=\<env-var-name\>,value=\<env-var-value\>,container=...,name=...,value=...,<br>Values should not contain commas. |
| verify-revision-is-deployed   | boolean  | false  | Runs the verify-revision-is-deployed Orb command to verify that the revision has been deployed and is the only deployed revision for the service. <br><br>**Note**: Enabling this may result in the build being marked as failed if tasks for older revisions fail to be stopped before the max number of polling attempts is reached. |
| max-poll-attempts   | integer  | 50  | The maximum number of attempts to poll the deployment status before giving up. <br>Only in use when verify-revision-is-deployed is set to true. |
| poll-interval   | integer  | 20  | The polling interval, in seconds. <br>Only in use when verify-revision-is-deployed is set to true. |
| fail-on-verification-timeout   | boolean  | true  | Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts. <br>Only in use when verify-revision-is-deployed is set to true. |

##### Example

```
version: 2.1
orbs:
  aws-ecr: circleci/aws-ecr@0.0.4
  aws-ecs: circleci/aws-ecs@0.0.3
workflows:
  build-and-deploy:
    jobs:
      - aws-ecr/build_and_push_image:
          account-url: "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
          repo: "${MY_APP_PREFIX}"
          region: "${AWS_REGION}"
          tag: "${CIRCLE_SHA1}"
      - aws-ecs/deploy-service-update:
          requires:
            - aws-ecr/build_and_push_image
          family: "${MY_APP_PREFIX}-service"
          cluster-name: "${MY_APP_PREFIX}-cluster"
          container-image-name-updates: "container=${MY_APP_PREFIX}-service,tag=${CIRCLE_SHA1}"
```

#### update-task-definition

##### Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH`. Otherwise, `pip` is required to be available as the job will then attempt to install `aws` via `pip`. The default profile of `aws` will be used.
- `bash` to be present in `/bin/bash`. Otherwise, `/bin/sh` will be used, but the orb has not been tested for compatibility with other shells.

##### Parameters

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| docker-image-for-job        | string  | "circleci/python:3.7.1"    | The docker image to be used for running this job on CircleCI |
| aws-access-key-id        | string  | $AWS_ACCESS_KEY_ID     | AWS access key id for IAM role. Defaulted to $AWS_ACCESS_KEY. |
| aws-secret-access-key        | string  | $AWS_SECRET_ACCESS_KEY    | AWS secret key for IAM role. Defaulted to $AWS_SECRET_ACCESS_KEY. |
| aws-region        | string  | $AWS_REGION    | AWS region to operate in. Defaulted to $AWS_REGION. |
| family        | string  |     | Name of the task definition's family |
| container-image-name-updates      | string   | ""    | Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. <br>**Expected format**: container=\<container-name\>,image-and-tag=\<image-name\>:\<tag-name\>\|image=\<image-name\>\|tag=\<tag-name\>,container=...,image-and-tag\|image\|tag=... <br>For each container, specify only either `image-and-tag` or `image` or `tag`.<br>If `image-and-tag` is specified, the container image will be updated to the value of the name-value pair.<br>If `image` is specified, the image tag defined in the previous task definition will be retained, if exists.<br>If `tag` is specified, the image name defined in the previous task definition will be used. |
| container-env-var-updates        | string  | ""   | Use this to update or set the values of environment variables that will be defined for the containers. <br>**Expected format**: container=\<container-name\>,name=\<env-var-name\>,value=\<env-var-value\>,container=...,name=...,value=...,<br>Values should not contain commas. |

```
version: 2.1
orbs:
  aws-ecr: circleci/aws-ecr@0.0.4
  aws-ecs: circleci/aws-ecs@0.0.3
workflows:
  build-and-deploy:
    jobs:
      - aws-ecr/build_and_push_image:
          account-url: "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
          repo: "${MY_APP_PREFIX}"
          region: "${AWS_REGION}"
          tag: "${CIRCLE_SHA1}"
      - aws-ecs/update-task-definition:
          requires:
            - aws-ecr/build_and_push_image
          family: "${MY_APP_PREFIX}-service"
          container-image-name-updates: "container=${MY_APP_PREFIX}-service,tag=${CIRCLE_SHA1}"
```

### Commands
You may use the following commands provided by this orb directly from your own job.

- [**update-service**](#update-service) - Registers a task definition for the given ECS service and updates the service to use it. The new task definition is based on the last task definition, except with the Docker image/tag names and environment variables of the containers updated according to this command's parameters. Optionally polls the status of the deployment until the created task definition  has reached its desired running task count and is the only one deployed for the service.

- [**verify-revision-is-deployed**](#verify-revision-is-deployed) - Polls the service's deployment status at intervals until the given task definition is the only one deployed for the service, and the task definition's running task count matches the desired count.

- [**update-task-definition**](#update-task-definition) - Updates a task definition without modifying a serivce. Useful for updating single run tasks.


#### update-service


##### Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH` and configured with the necessary credentials and region information. The version of `aws` CLI used should support the launch type of the deployment. The default profile of `aws` will be used.

##### Parameters

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| family        | string  |     | Name of the task definition's family |
| cluster-name   | string  |   | The short name or full ARN of the cluster that hosts the service |
| service-name   | string  |   | The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition. |
| container-image-name-updates      | string   | ""    | Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. <br>**Expected format**: container=\<container-name\>,image-and-tag=\<image-name\>:\<tag-name\>\|image=\<image-name\>\|tag=\<tag-name\>,container=...,image-and-tag\|image\|tag=... <br>For each container, specify only either `image-and-tag` or `image` or `tag`.<br>If `image-and-tag` is specified, the container image will be updated to the value of the name-value pair.<br>If `image` is specified, the image tag defined in the previous task definition will be retained, if exists.<br>If `tag` is specified, the image name defined in the previous task definition will be used. |
| container-env-var-updates        | string  | ""   | Use this to update or set the values of environment variables that will be defined for the containers. <br>**Expected format**: container=\<container-name\>,name=\<env-var-name\>,value=\<env-var-value\>,container=...,name=...,value=...<br>Values should not contain commas. |
| verify-revision-is-deployed   | boolean  | false  | Runs the verify-revision-is-deployed Orb command to verify that the revision has been deployed and is the only deployed revision for the service. <br><br>**Note**: Enabling this may result in the build being marked as failed if tasks for older revisions fail to be stopped before the max number of polling attempts is reached. |
| max-poll-attempts   | integer  | 50  | The maximum number of attempts to poll the deployment status before giving up. <br>Only in use when verify-revision-is-deployed is set to true. |
| poll-interval   | integer  | 20  | The polling interval, in seconds. <br>Only in use when verify-revision-is-deployed is set to true. |
| fail-on-verification-timeout   | boolean  | true  | Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts. <br>Only in use when verify-revision-is-deployed is set to true. |

##### Example

```
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@0.0.3

jobs:
  update-tag:
    docker:
      - image: circleci/python:3.7.1
    steps:
      - aws-cli/install
      - aws-cli/configure:
          aws-access-key-id: "$AWS_ACCESS_KEY_ID"
          aws-region: "$AWS_REGION"
      - aws-ecs/update-service:
          family: "${MY_APP_PREFIX}-service"
          cluster-name: "${MY_APP_PREFIX}-cluster"
          container-image-name-updates: "container=${MY_APP_PREFIX}-service,tag=stable"
workflows:
  deploy:
    jobs:
      - update-tag
```


#### verify-revision-is-deployed

##### Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH` and configured with the necessary credentials and region information. The version of `aws` CLI used should support the launch type of the deployment. The default profile of `aws` will be used.

##### Parameters

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| family        | string  |     | Name of the task definition's family |
| cluster-name   | string  |   | The short name or full ARN of the cluster that hosts the service |
| service-name   | string  |   | The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition. |
| task-definition-arn      | string   |    | ARN of the task definition whose deployment status is to be monitored |
| max-poll-attempts   | integer  | 50  | The maximum number of attempts to poll the deployment status before giving up. <br>Only in use when verify-revision-is-deployed is set to true. |
| poll-interval   | integer  | 20  | The polling interval, in seconds |
| fail-on-verification-timeout   | boolean  | true  | Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts.|

##### Example

```
version: 2.1
orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@0.0.3

jobs:
  verify-deployment:
    docker:
      - image: circleci/python:3.7.1
    steps:
      - aws-cli/install
      - aws-cli/configure:
          aws-access-key-id: "$AWS_ACCESS_KEY_ID"
          aws-region: "$AWS_REGION"
      - run:
          name: Get last task definition
          command: |
            TASK_DEFINITION_ARN=$(aws ecs describe-task-definition \
                --task-definition ${MY_APP_PREFIX}-service \
                --output text \
                --query 'taskDefinition.taskDefinitionArn')
            echo "export TASK_DEFINITION_ARN='${TASK_DEFINITION_ARN}'" >> $BASH_ENV
      - aws-ecs/verify-revision-is-deployed:
          family: "${MY_APP_PREFIX}-service"
          cluster-name: "${MY_APP_PREFIX}-cluster"
          task-definition-arn: "${TASK_DEFINITION_ARN}"

workflows:
  test-workflow:
    jobs:
      - verify-deployment
```

#### update-task-definition


##### Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH` and configured with the necessary credentials and region information. The version of `aws` CLI used should support the launch type of the deployment. The default profile of `aws` will be used.

##### Parameters

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| family        | string  |     | Name of the task definition's family |
| container-image-name-updates      | string   | ""    | Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. <br>**Expected format**: container=\<container-name\>,image-and-tag=\<image-name\>:\<tag-name\>\|image=\<image-name\>\|tag=\<tag-name\>,container=...,image-and-tag\|image\|tag=... <br>For each container, specify only either `image-and-tag` or `image` or `tag`.<br>If `image-and-tag` is specified, the container image will be updated to the value of the name-value pair.<br>If `image` is specified, the image tag defined in the previous task definition will be retained, if exists.<br>If `tag` is specified, the image name defined in the previous task definition will be used. |
| container-env-var-updates        | string  | ""   | Use this to update or set the values of environment variables that will be defined for the containers. <br>**Expected format**: container=\<container-name\>,name=\<env-var-name\>,value=\<env-var-value\>,container=...,name=...,value=...<br>Values should not contain commas. |

##### Example

```
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@0.0.3

jobs:
  update-tag:
    docker:
      - image: circleci/python:3.7.1
    steps:
      - aws-cli/install
      - aws-cli/configure:
          aws-access-key-id: "$AWS_ACCESS_KEY_ID"
          aws-region: "$AWS_REGION"
      - aws-ecs/update-service:
          family: "${MY_APP_PREFIX}-service"
          container-image-name-updates: "container=${MY_APP_PREFIX}-service,tag=stable"
workflows:
  deploy:
    jobs:
      - update-tag
```
