# AWS ECS Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/aws-ecs)](https://circleci.com/orbs/registry/orb/circleci/aws-ecs) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-ecs-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

A CircleCI Orb to simplify deployments to Amazon Elastic Container Service (ECS). It supports EC2 and Fargate launch type deployments.

CircleCI orbs registry page: https://circleci.com/orbs/registry/orb/circleci/aws-ecs

## Features

This orb allows convenient updating of ECS services when only the Docker
image name/tag and/or environment variables in a service's container definitions need to be updated.
A sample project that demonstrates using the orb is available on this GitHub repository branch: https://github.com/CircleCI-Public/circleci-demo-aws-ecs-ecr

## Usage

See the [orb registry listing](http://circleci.com/orbs/registry/orb/circleci/aws-ecs) for usage guidelines.

## Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH`. Otherwise, `pip` is required to be available as the job will then attempt to install `aws` via `pip`. The default profile of `aws` will be used.
- `bash` to be present in `/bin/bash`. Otherwise, `/bin/sh` will be used, but the orb has not been tested for compatibility with other shells.

## Examples

### deploy-service-update

Update an ECS service.

```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@0.0.4
  aws-ecs: circleci/aws-ecs@0.0.10

workflows:
  build-and-deploy:
    jobs:
      - aws-ecr/build_and_push_image:
          account-url: '${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'
          repo: '${MY_APP_PREFIX}'
          region: '${AWS_REGION}'
          tag: '${CIRCLE_SHA1}'
      - aws-ecs/deploy-service-update:
          requires:
            - aws-ecr/build_and_push_image
          family: '${MY_APP_PREFIX}-service'
          cluster-name: '${MY_APP_PREFIX}-cluster'
          container-image-name-updates: 'container=${MY_APP_PREFIX}-service,tag=${CIRCLE_SHA1}'
```

### update-service

Use the AWS CLI and this orb to update an ECS service.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@0.0.15

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

### verify-revision-deployment

Verify the deployment of an ECS revision.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@0.0.10

jobs:
  verify-deployment:
    docker:
      - image: 'circleci/python:3.7.1'
    steps:
      - aws-cli/install
      - aws-cli/configure:
          aws-access-key-id: $AWS_ACCESS_KEY_ID
          aws-region: $AWS_REGION
      - run:
          name: Get last task definition
          command: >
            TASK_DEFINITION_ARN=$(aws ecs describe-task-definition \
                --task-definition ${MY_APP_PREFIX}-service \
                --output text \
                --query 'taskDefinition.taskDefinitionArn')
            echo "export TASK_DEFINITION_ARN='${TASK_DEFINITION_ARN}'" >>
            $BASH_ENV
      - aws-ecs/verify-revision-is-deployed:
          family: '${MY_APP_PREFIX}-service'
          cluster-name: '${MY_APP_PREFIX}-cluster'
          task-definition-arn: '${TASK_DEFINITION_ARN}'
workflows:
  test-workflow:
    jobs:
      - verify-deployment
```

### run-task-fargate

Start the run of an ECS task on Fargate.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@x.y.z

jobs:
  run-task:
    docker:
      - image: 'circleci/python:3.7.1'
    steps:
      - aws-ecs/run-task:
          cluster: cluster1
          task-definition: myapp
          subnet-ids: '$SUBNET_ONE, $SUBNET_TWO'
          security-group-ids: $SECURITY_GROUP_IDS
workflows:
  run-task:
    jobs:
      - run-task
```

### run-task-ec2

Start the run of an ECS task on EC2.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.4
  aws-ecs: circleci/aws-ecs@x.y.z

jobs:
  run-task:
    docker:
      - image: 'circleci/python:3.7.1'
    steps:
      - aws-ecs/run-task:
          cluster: cluster1
          task-definition: myapp
          awsvpc: false
workflows:
  run-task:
    jobs:
      - run-task
```

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/aws-ecs-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-ecs-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/orbs).
