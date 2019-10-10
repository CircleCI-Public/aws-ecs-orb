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

## Jobs

### deploy-service-update
| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| docker-image-for-job	| The docker image to be used for running this job on CircleCI. |	- |	'circleci/python:3.7.1' |	string |
| aws-access-key-id |	AWS access key id for IAM role. Defaulted to $AWS_ACCESS_KEY_ID |	-	| $AWS_ACCESS_KEY_ID |	string |
| aws-secret-access-key |	AWS secret key for IAM role. Defaulted to $AWS_SECRET_ACCESS_KEY | - | $AWS_SECRET_ACCESS_KEY |	string |
| aws-region	| AWS region to operate in. Defaulted to $AWS_REGION | -	| $AWS_REGION |	string |
| family | Name of the task definition's family.	|✔ | - |	string |
| cluster-name | The short name or full ARN of the cluster that hosts the service. |✔	| - |	string |
| service-name	| The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition. | - | '' |	string |
| deployment-controller |	The deployment controller to use for the service. Defaulted to ECS | - | ECS | enum |
| codedeploy-application-name |	The name of the AWS CodeDeploy application used for the deployment. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". |	-	| '' |	string |
| codedeploy-deployment-group-name |	The name of the AWS CodeDeploy deployment group used for the deployment. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". 	| - |	''	| string |
| codedeploy-load-balanced-container-name |	The name of the container to be load-balanced via AWS CodeDeploy. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". |	- |	'' |	string |
| codedeploy-load-balanced-container-port |	The port of the container to be load-balanced via AWS CodeDeploy. Only effective when the deployment-controller parameter value is "CODE_DEPLOY".| 	- | 	80 | 	integer |
| container-image-name-updates |	Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name>image=<image-name>tag=<tag-name>,container=...,image-and-tag image tag=..., For each container, specify only either "image-and-tag" or "image" or "tag". If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair. If "image" is specified, the image tag defined in the previous task definition will be retained, if exists. If "tag" is specified, the image name defined in the previous task definition will be used. | 	- |	'' |	string |
| container-env-var-updates |	Use this to update or set the values of environment variables that will be defined for the containers. (Existing environment variables not included in this parameter will not be removed) Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=..., Values should not contain commas. |	-	| '' |	string |
|verify-revision-is-deployed |	Runs the verify-revision-is-deployed Orb command to verify that the revision has been deployed and is the only deployed revision for the service. Note: enabling this may result in the build being marked as failed if tasks for older revisions fail to be stopped before the max number of polling attempts is reached. Does not support ECS services that are of the Blue/Green Deployment type. 	| - |	false |	boolean |
| max-poll-attempts |	The maximum number of attempts to poll the deployment status before giving up. Only in use when verify-revision-is-deployed is set to true. |	- |	50 |	integer |
| poll-interval |	The polling interval, in seconds. Only in use when verify-revision-is-deployed is set to true. |	- |	20 |	integer |
| fail-on-verification-timeout |	Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts. Only in use when verify-revision-is-deployed is set to true. |	- |	true |	boolean |

### update-task-definition
| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| docker-image-for-job	| The docker image to be used for running this job on CircleCI. |	- |	'circleci/python:3.7.1' |	string |
| aws-access-key-id |	AWS access key id for IAM role. Defaulted to $AWS_ACCESS_KEY_ID |	- |	$AWS_ACCESS_KEY_ID |	string |
| aws-secret-access-key	| AWS secret key for IAM role. Defaulted to $AWS_SECRET_ACCESS_KEY |	- |	$AWS_SECRET_ACCESS_KEY	| string |
| aws-region	| AWS region to operate in. Defaulted to $AWS_REGION |	- |	$AWS_REGION |	string |
| family	| Name of the task definition's family. |	 
 | - |	string |
| container-image-name-updates |	Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name>image=<image-name>tag=<tag-name>,container=...,image-and-tag image tag=..., For each container, specify only either "image-and-tag" or "image" or "tag". If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair. If "image" is specified, the image tag defined in the previous task definition will be retained, if exists. If "tag" is specified, the image name defined in the previous task definition will be used. |	-	 | '' |	string |
| container-env-var-updates |	Use this to update or set the values of environment variables that will be defined for the containers. (Existing environment variables not included in this parameter will not be removed) Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=..., Values should not contain commas. |
- | '' | string |
## Example

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

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/aws-ecs-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-ecs-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/orbs).
