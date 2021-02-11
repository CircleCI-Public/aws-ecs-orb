# Notes for Internal Contributors

The notes here are primarily targeted at internal (CircleCI) contributors to the orb but could be of reference to fork owners who wish to run the tests with their own AWS account.

## Building

### Required Project Environment Variables

The following [project environment variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project) must be set for the project on CircleCI via the project settings page, before the project can be built successfully.

| Variable                       | Description                           |
| -------------------------------| --------------------------------------|
| `AWS_ACCESS_KEY_ID`            | Picked up by the AWS CLI              |
| `AWS_SECRET_ACCESS_KEY`        | Picked up by the AWS CLI              |
| `AWS_DEFAULT_REGION`           | Picked up by the AWS CLI. Set to `us-east-1`.              |
| `AWS_ACCOUNT_ID`               | AWS account id                        |
| `CIRCLECI_API_KEY`             | Used by the `queue` orb               |
| `AWS_RESOURCE_NAME_PREFIX_EC2` | Prefix used to name AWS resources for EC2 launch type integration tests. Set to `ecs-orb-ec2-1`.                                        |
| `AWS_RESOURCE_NAME_PREFIX_FARGATE` | Prefix used to name AWS resources for Fargate launch type integration tests. Set to `ecs-orb-fg-1`.                               |
| `AWS_RESOURCE_NAME_PREFIX_FARGATE_SPOT` | Prefix used to name AWS resources for Fargate Spot launch type integration tests. Set to `ecs-orb-fgs-1`.                               |
| `AWS_RESOURCE_NAME_PREFIX_CODEDEPLOY_FARGATE` | Prefix used to name AWS resources for Fargate launch type integration tests that use CodeDeploy. Set to `ecs-orb-cdfg-1`. |
| `SKIP_TEST_ENV_CREATION`       | Whether to skip test env setup        |
| `SKIP_TEST_ENV_TEARDOWN`       | Whether to skip test env teardown     |

## Tear down infra on CircleCI
If during development of this orb you execute a pipeline on CircleCI that fails to finish, you may need to manually tear down the infrastructure before being able to properly test again in a future pipeline.

This can be done most easily by SSHing into any of the `set-up-test-env` jobs and running the included teardown script.

1. SSH into `set-up-test-env` on CircleCI
2. `cd project/tests`
3. `./teardown.sh`

## Setting up / tearing down test infra locally

You can also set up the same test infrastructure set up by the build pipeline,
by running terraform locally.

This is also useful when you need to tear down infra manually after the pipeline failed. (For the ec2 and fargate tests, you can also tear down the infrastructure by going to the CloudFormation page on the AWS console and deleting the stacks prefixed with `ecs-orb`)

Set up AWS credentials and `AWS_DEFAULT_REGION`:

```
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_ACCOUNT_ID=...
AWS_DEFAULT_REGION=us-east-1
```

Then set `AWS_RESOURCE_PREFIX` to the correct value:

*For EC2 tests*

```
AWS_RESOURCE_PREFIX=ecs-orb-ec2-1
cd tests/terraform_setup/ec2
```

*For Fargate tests*

```
AWS_RESOURCE_PREFIX=ecs-orb-fg-1
cd tests/terraform_setup/fargate
```

*For CodeDeploy tests*

```
AWS_RESOURCE_PREFIX=ecs-orb-cdfg-1
cd tests/terraform_setup/fargate_codedeploy
```

### Infra setup/teardown steps (for all)

```
terraform apply \
    -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
    -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
    -var "aws_region=${AWS_DEFAULT_REGION}" \
    -var "aws_account_id=${AWS_ACCOUNT_ID}" \
    -var "aws_resource_prefix=${AWS_RESOURCE_PREFIX}"
```

```
terraform destroy \
    -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
    -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
    -var "aws_region=${AWS_DEFAULT_REGION}" \
    -var "aws_account_id=${AWS_ACCOUNT_ID}" \
    -var "aws_resource_prefix=${AWS_RESOURCE_PREFIX}"
```

### Required Context and Context Environment Variables

The `orb-publishing` context is referenced in the build. In particular, the following [context environment variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-context) must be set in the `orb-publishing` context, before the project can be built successfully.

| Variable                       | Description                      |
| -------------------------------| ---------------------------------|
| `CIRCLE_TOKEN`                 | CircleCI API token used to publish the orb  |