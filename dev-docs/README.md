# Notes for Internal Contributors

The notes here are primarily targeted at internal (CircleCI) contributors to the orb but could be of reference to fork owners who wish to run the tests with their own AWS account.

## Building

### Required Project Environment Variables

The following [project environment variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project) must be set for the project on CircleCI via the project settings page, before the project can be built successfully.

| Variable                       | Description                           |
| -------------------------------| --------------------------------------|
| `AWS_ACCESS_KEY_ID`            | Picked up by the AWS CLI              |
| `AWS_SECRET_ACCESS_KEY`        | Picked up by the AWS CLI              |
| `AWS_DEFAULT_REGION`           | Picked up by the AWS CLI              |
| `AWS_ACCOUNT_ID`               | AWS account id                        |
| `CIRCLECI_API_KEY`             | Used by the `queue` orb               |
| `AWS_RESOURCE_NAME_PREFIX_EC2` | Prefix used to name AWS resources for EC2 launch type integration tests                                        |
| `AWS_RESOURCE_NAME_PREFIX_FARGATE` | Prefix used to name AWS resources for Fargate launch type integration tests                               |
| `AWS_RESOURCE_NAME_PREFIX_CODEDEPLOY_FARGATE` | Prefix used to name AWS resources for Fargate launch type integration tests that use CodeDeploy |
| `SKIP_TEST_ENV_CREATION`       | Whether to skip test env setup        |
| `SKIP_TEST_ENV_TEARDOWN`       | Whether to skip test env teardown     |

### Required Context and Context Environment Variables

The `orb-publishing` context is referenced in the build. In particular, the following [context environment variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-context) must be set in the `orb-publishing` context, before the project can be built successfully.

| Variable                       | Description                      |
| -------------------------------| ---------------------------------|
| `CIRCLE_TOKEN`                 | CircleCI API token used to publish the orb  |
