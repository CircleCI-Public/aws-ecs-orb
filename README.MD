# AWS ECS Orb for CircleCI

[![CircleCI Build Status](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/CircleCI-Public/aws-ecs-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/aws-ecs)](https://circleci.com/orbs/registry/orb/circleci/aws-ecs) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-ecs-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)


A CircleCI Orb to simplify deployments to Amazon Elastic Container Service (ECS). Supports EC2 and Fargate launch type deployments.

## Features

This orb allows convenient updating of ECS services when only the Docker
image name/tag and/or environment variables in a service's container definitions need to be updated.
A sample project that demonstrates using the orb is available on this GitHub repository branch: https://github.com/CircleCI-Public/circleci-demo-aws-ecs-ecr

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/circleci/aws-ecs) - The official registry page of this orb for all versions, executors, commands, and jobs described.
[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using and creating CircleCI Orbs.

## Usage

See the [orb registry listing](https://circleci.com/orbs/registry/orb/circleci/aws-ecs) for usage guidelines.

## Requirements
- `python` should be available in `PATH`. Supported versions are Python 2 version 2.7.1 and above and Python 3 version 3.4.9 and above.
- The `aws` CLI should be available in `PATH`. Otherwise, `pip` is required to be available as the job will then attempt to install `aws` via `pip`. The default profile of `aws` will be used.
- `bash` to be present in `/bin/bash`. Otherwise, `/bin/sh` will be used, but the orb has not been tested for compatibility with other shells.

## How to Contribute

We welcome [issues](https://github.com/CircleCI-Public/aws-ecs-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-ecs-orb/pulls) against this repository!

For internal contributors, please view the development docs: [here](https://github.com/CircleCI-Public/aws-ecs-orb/tree/master/dev-docs)

### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from fore _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On merge, after manual approval, the orb will automatically be published to the Orb Registry.


For further questions/comments about this or other orbs, visit the Orb Category of [CircleCI Discuss](https://discuss.circleci.com/c/orbs).

