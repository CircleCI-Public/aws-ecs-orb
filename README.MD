# aws-ecs Orb

A CircleCI Orb to simplify deployments to Amazon Elastic Container Service (ECS). It supports EC2 and Fargate launch type deployments.

## Features

This orb allows convenient updating of ECS services when only the Docker
image name/tag and/or environment variables in a service's container definitions need to be updated.

### Jobs

You can reference the provided Jobs from a 2.1 Workflows configuration stanza. 

- **update-service** - Update an ECS service.

#### update-service Example

```
version: 2.1

```

### Commands
You may use the following commands directly from your own job.

- update-service - Registers a task definition for the given ECS service and updates the service to use it. The new task definition is based on the last task definition, except with the Docker image/tag names and environment variables of the containers updated according to this command's parameters. Optionally polls the status of the deployment until the created task definition revision has reached its desired running task count and is the only revision deployed for the service.

- verify-revision-is-deployed - Polls the service's deployment status at intervals until the given task definition revision is the only one deployed for the service, and for the task definition revision's running task count to match the desired count.


#### update-service Command Example

```
version: 2.1

```


#### verify-revision-is-deployed Command Example
```
version: 2.1

```

## Parameters / Configuration

### update-service

| Parameter         | type    | default  |     description |
|------------------|--------|-------------|----------------|
| family        | string  |     | Name of the task definition's family | 
| cluster-name   | string  |   | The short name or full ARN of the cluster that hosts the service |
| container-image-name-updates      | string   | ""    | Use this to update the Docker image names and/or tag names of existing containers that had been defined in the previous task definition. <br>Expected format: container=<container-name>,image-and-tag=<image-name>:<tag-name>|image=<image-name>|tag=<tag-name>,container=...,image-and-tag|image|tag=... <br>For each container, specify only either "image-and-tag" or "image" or "tag".<br>If "image-and-tag" is specified, the container image will be updated to the value of the name-value pair.<br>If "image" is specified, the image tag defined in the previous task definition will be retained, if exists.<br>If "tag" is specified, the image name defined in the previous task definition will be used. |
| container-env-var-updates        | string  | ""   | Use this to update the values of (only) existing environment variables that had been defined for the containers in the previous task definition. <br>Expected format: container=<container-name>,name=<env-var-name>,value=<env-var-value>,container=...,name=...,value=...,<br>Values should not contain commas. |
| verify-revision-is-deployed   | boolean  | false  | Runs the verify-revision-is-deployed Orb command to verify that the revision has been deployed and is the only deployed revision for the service. <br>Note: enabling this may result in the build being marked as failed if tasks for older revisions fail to be stopped before the max number of polling attempts is reached. |
| max-poll-attempts   | string  | "50"  | The maximum number of attempts to poll the deployment status before giving up. <br>Only in use when verify-revision-is-deployed is set to true. |
| poll-interval   | string  | "20"  | The polling interval, in seconds. <br>Only in use when verify-revision-is-deployed is set to true. |
| enable-trace   | boolean  | false  | Set this to true for commands to be run with the xtrace shell option enabled (set -x). <br>Do *not* enable this if you have sensitive variables that you do not want appearing in the build output. |

## Usage

Example config:
```yaml
orbs:
  aws-ecs: circleci/aws-ecs@0.0.1
```