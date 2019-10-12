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
| family	| Name of the task definition's family. | ✔	 
 | - |	string |
| container-image-name-updates |	Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name>image=<image-name>tag=<tag-name>,container=...,image-and-tag image tag=..., For each container, specify only either "image-and-tag" or "image" or "tag". If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair. If "image" is specified, the image tag defined in the previous task definition will be retained, if exists. If "tag" is specified, the image name defined in the previous task definition will be used. |	-	 | '' |	string |
| container-env-var-updates |	Use this to update or set the values of environment variables that will be defined for the containers. (Existing environment variables not included in this parameter will not be removed) Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=..., Values should not contain commas. | - | '' | string |

### run-task
| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| docker-image-for-job |	The docker image to be used for running this job on CircleCI. |	- |	'circleci/python:3.7.1' |	string |
| aws-access-key-id |	AWS access key id for IAM role. Defaulted to $AWS_ACCESS_KEY_ID |	- |	$AWS_ACCESS_KEY_ID	| string |
| aws-secret-access-key |	AWS secret key for IAM role. Defaulted to $AWS_SECRET_ACCESS_KEY | 	- |	$AWS_SECRET_ACCESS_KEY	| string |
| aws-region	| AWS region to operate in. Defaulted to $AWS_REGION |	- |	$AWS_REGION	 | string |
| cluster |	The name or ARN of the cluster on which to run the task.| ✔|	
| - |	string |
| task-definition |	"The family and revision (family:revision) or full ARN of the task definition to run. If a revision is not specified, the latest ACTIVE revision is used."| ✔| 	
| - |	string |
| count |	"The number of instantiations of the specified task to place on your cluster. You can specify up to 10 tasks per call." 	| - |	1 |	integer |
| started-by |	An optional tag specified when a task is started. For example, if you automatically trigger a task to run a batch process job, you could apply a unique identifier for that job to your task with the startedBy parameter. You can then identify which tasks belong to that job by filtering the results of a ListTasks call with the startedBy value. Up to 36 letters (uppercase and lowercase), num- bers, hyphens, and underscores are allowed. | 	- |	'' |	string |
| group	| The name of the task group to associate with the task. The default value is the family name of the task definition (for example, family:my-family-name). | 	- |	'' |	string |
| placement-constraints	| "An array of placement constraint objects to use for the task. You can specify up to 10 constraints per task (including constraints in the task definition and those specified at runtime). Expected format: type=string,field=string." 	| -	 | '' |	string |
| placement-strategy |	"The placement strategy objects to use for the task. You can specify a maximum of five strategy rules per task. Expected format: type=string,field=string." | 	- |	'' |	string |
| launch-type |	The launch type on which to run your task. For more information, see Amazon ECS Launch Types in the Amazon Elastic Container Service Developer Guide. Possible values EC2, FARGATE. | 	- |	FARGATE |	enum |
| platform-version | "The platform version the task should run. A platform version is only specified for tasks using the Fargate launch type." |	- |	LATEST	 | string |
| awsvpc |	"Does your task defintion use awsvpc mode or not. If so, this should be true and you should also include subnet-ids and optionally security-group-ids / assign-public-ips." | 	- |	true |	boolean |
| subnet-ids	| "List of subnet ids separated by commas. Expected Format: subnet-70faa93b,subnet-bcc54b93" | 	- |	'' |	string |
| security-group-ids	| "List of security group ids separated by commas. Expected Format: sg-010a460f7f442fa75,sg-010a420f7faa5fa75" | 	- |	''	| string |
| assign-public-ip |	"Assign a public IP or not" |	- |	DISABLED |	enum |
| tags |	"The metadata that you apply to the task to help you categorize and organize them. Each tag consists of a key and an optional value, both of which you define. Expected format: key=string,value=string." | 	- | 	'' |	string |
| enable-ecs-managed-tags |	"Specifies whether to enable Amazon ECS managed tags for the task." | 	- |	false	| boolean |
| propagate-tags |	"Specifies whether to propagate the tags from the task definition to the task. If no value is specified, the tags are not propagated. Tags can only be propagated to the task during task creation. To add tags to a task after task creation, use the TagResource API action." | -	|false	| boolean |


## Commands
### verify-revision-is-deployed
| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| family	| Name of the task definition's family.	| ✔| - |	string  |
| cluster-name |	The short name or full ARN of the cluster that hosts the service.	| ✔| - |	string |
| service-name |	The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition. |	- |	'' |	string |
| task-definition-arn |	ARN of the task definition whose deployment status is to be monitored.	| ✔ | - |	string |
| max-poll-attempts |	The maximum number of attempts to poll for the deployment status before giving up.	-	50	integer
poll-interval	The polling interval, in seconds. |	- |	20 |	integer |
| fail-on-verification-timeout |	Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts. | 	- |	true |	boolean |

### update-task-definition

| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| family |	Name of the task definition's family.	|✔| - |	string |
| container-image-name-updates |	Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name> _ image=<image-name> _ tag=<tag-name>,container=...,image-and-tag _ image _ tag=..., For each container, specify only either "image-and-tag" or "image" or "tag". If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair. If "image" is specified, the image tag defined in the previous task definition will be retained, if exists. If "tag" is specified, the image name defined in the previous task definition will be used. |	-	| '' |	string |
| container-env-var-updates |  	Use this to update or set the values of environment variables that will be defined for the containers. (Existing environment variables not included in this parameter will not be removed) Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=..., Values should not contain commas. | 	-	| '' |	string |
 
 ### update-service
 | parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| family |	Name of the task definition's family. | ✔ |	- |	string |
| cluster-name |	The short name or full ARN of the cluster that hosts the service.	| ✔ | - |	string |
| service-name |	The name of the service to update. If undefined, we assume `family` is the name of both the service and task definition.	| - |	'' |	string |
| deployment-controller |	The deployment controller to use for the service. Defaulted to ECS |	- |	ECS |	enum |
| codedeploy-application-name |	The name of the AWS CodeDeploy application used for the deployment. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". | 	- | 	'' |	string |
| codedeploy-deployment-group-name	| The name of the AWS CodeDeploy deployment group used for the deployment. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". | 	- |	'' |	string |
| codedeploy-load-balanced-container-name |	The name of the container to be load-balanced via AWS CodeDeploy. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". 	| - |	'' |	string |
| codedeploy-load-balanced-container-port |	The port of the container to be load-balanced via AWS CodeDeploy. Only effective when the deployment-controller parameter value is "CODE_DEPLOY". | 	- |	80 |	integer |
| container-image-name-updates |	Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name> _ image=<image-name> _ tag=<tag-name>,container=...,image-and-tag _ image _ tag=..., For each container, specify only either "image-and-tag" or "image" or "tag". If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair. If "image" is specified, the image tag defined in the previous task definition will be retained, if exists. If "tag" is specified, the image name defined in the previous task definition will be used. | 	- |	'' |	string |
| container-env-var-updates |	Use this to update or set the values of environment variables that will be defined for the containers. (Existing environment variables not included in this parameter will not be removed) Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=..., Values should not contain commas. |	-	 | '' |	string |
| verify-revision-is-deployed	| Runs the verify-revision-is-deployed Orb command to verify that the revision has been deployed and is the only deployed revision for the service. Note: enabling this may result in the build being marked as failed if tasks for older revisions fail to be stopped before the max number of polling attempts is reached. Does not support ECS services that are of the Blue/Green Deployment type. |	- |	false	| boolean |
| max-poll-attempts |	The maximum number of attempts to poll the deployment status before giving up. Only in use when verify-revision-is-deployed is set to true. |	- |	50 |	integer |
| poll-interval |	The polling interval, in seconds. Only in use when verify-revision-is-deployed is set to true. |	- |	20 |	integer |
| fail-on-verification-timeout	| Whether to exit with an error if the verification of the deployment status does not complete within the number of polling attempts. Only in use when verify-revision-is-deployed is set to true. 	| - |	true |	boolean |

### run-task
| parameter	| description	| required |	default |	type |
| --- | --- | --- | --- | --- |
| cluster	The name or ARN of the cluster on which to run the task.	| ✔ | - |	string |
| task-definition |	"The family and revision (family:revision) or full ARN of the task definition to run. If a revision is not specified, the latest ACTIVE revision is used." 	| ✔ | -	 | string |
| count |	"The number of instantiations of the specified task to place on your cluster. You can specify up to 10 tasks per call." 	 | - | 	1 |	integer |
| started-by |	An optional tag specified when a task is started. For example, if you automatically trigger a task to run a batch process job, you could apply a unique identifier for that job to your task with the startedBy parameter. You can then identify which tasks belong to that job by filtering the results of a ListTasks call with the startedBy value. Up to 36 letters (uppercase and lowercase), num- bers, hyphens, and underscores are allowed. |	- |	''	 | string |
| group |	The name of the task group to associate with the task. The default value is the family name of the task definition (for example, family:my-family-name). |	- |	'' |	string |
| placement-constraints |	"An array of placement constraint objects to use for the task. You can specify up to 10 constraints per task (including constraints in the task definition and those specified at runtime). Expected format: type=string,field=string." 	| - |	'' |	string |
| placement-strategy |	"The placement strategy objects to use for the task. You can specify a maximum of five strategy rules per task. Expected format: type=string,field=string." |	-	| '' |	string |
| launch-type |	The launch type on which to run your task. For more information, see Amazon ECS Launch Types in the Amazon Elastic Container Service Developer Guide. Possible values EC2, FARGATE. |	- |	FARGATE |	enum | 
| platform-version |	"The platform version the task should run. A platform version is only specified for tasks using the Fargate launch type." |	-	 | LATEST |	string |
| awsvpc |	"Does your task defintion use awsvpc mode or not. If so, this should be true and you should also include subnet-ids and optionally security-group-ids / assign-public-ips." |	- |	true |	boolean |
| subnet-ids |	"List of subnet ids separated by commas. Expected Format: subnet-70faa93b,subnet-bcc54b93" |	- |	'' |	string |
| security-group-ids |	"List of security group ids separated by commas. Expected Format: sg-010a460f7f442fa75,sg-010a420f7faa5fa75" |	- |	'' |	string |
| assign-public-ip |	"Assign a public IP or not"  |	- |	DISABLED |	enum |
| tags |	"The metadata that you apply to the task to help you categorize and organize them. Each tag consists of a key and an optional value, both of which you define. Expected format: key=string,value=string." |	- |	'' |	string |
| enable-ecs-managed-tags |	"Specifies whether to enable Amazon ECS managed tags for the task." |	-	 | false |	boolean |
| propagate-tags |	"Specifies whether to propagate the tags from the task definition to the task. If no value is specified, the tags are not propagated. Tags can only be propagated to the task during task creation. To add tags to a task after task creation, use the TagResource API action." |	- |	false	| boolean |

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
