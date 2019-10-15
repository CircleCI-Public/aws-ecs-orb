# Changelog
Documents changes in orb version releases.

## [[0.0.16](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.16)]
### Changed
- Integration tests for the orb now use Terraform 0.12 instead of 0.11. (No actual change to the orb) [\#40](https://github.com/CircleCI-Public/aws-ecs-orb/pull/40) ([mikkopiu](https://github.com/mikkopiu))

## [[0.0.15](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.15)]
### Changed
- Orb description now includes a link to the GitHub repository [\#42](https://github.com/CircleCI-Public/aws-ecs-orb/pull/42) ([Bharat123rox](https://github.com/Bharat123rox))

## [[0.0.14](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.14)]
### Fixed
- Fix environment variable expansion in `codedeploy-load-balanced-container-name` parameter. This is relevant to Blue/Green deployments. [\#52](https://github.com/CircleCI-Public/aws-ecs-orb/pull/52) ([lokst](https://github.com/lokst))

## [[0.0.13](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.13)]
### Added
- Added a `run-task` command and a `run-task` job to wrap `aws ecs run-task` [\#35](https://github.com/CircleCI-Public/aws-ecs-orb/pull/35) ([codingdiaz](https://github.com/codingdiaz))

## [[0.0.12](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.12)]
### Changed
- The `update-service` command and `deploy-service-update` job now support Blue/Green deployments via additional parameters [\#34](https://github.com/CircleCI-Public/aws-ecs-orb/pull/34) ([enokawa](https://github.com/enokawa))

## [[0.0.11](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.11)]
### Changed
- Updated version of orb in examples [\#32](https://github.com/CircleCI-Public/aws-ecs-orb/pull/32) ([lokst](https://github.com/lokst))

## [[0.0.10](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.10)]
### Fixed
- Fix for proxyConfiguration, tags, pidMode and ipcMode not being copied to new task definition [\#32](https://github.com/CircleCI-Public/aws-ecs-orb/pull/31) ([lokst](https://github.com/lokst))

## [[0.0.9](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.9)]
### Fixed
- Bump dependencies used in orb generation, to remediate WS-2019-0064 (no actual change to the orb) [\#26](https://github.com/CircleCI-Public/aws-ecs-orb/pull/26) ([taxonomic-blackfish](https://github.com/taxonomic-blackfish))

## [[0.0.8](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.8)]
### Changed
- The `container-env-var-updates` parameter now supports adding environment variables that do not exist in the previous task definition [\#15](https://github.com/CircleCI-Public/aws-ecs-orb/pull/15) ([stringbeans](https://github.com/stringbeans))

## [[0.0.7](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.7)]
### Added
- Added `update-task-definition` command to allow updating a task definition without modifying a service. Refactored `update-service` command accordingly. [\#12](https://github.com/CircleCI-Public/aws-ecs-orb/pull/12) ([jeffnappi](https://github.com/jeffnappi))

## [[0.0.6](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.6)]
### Added
- Added tests for `service-name` parameter (no actual change to the orb) [\#8](https://github.com/CircleCI-Public/aws-ecs-orb/pull/8) ([lokst](https://github.com/lokst))

## [[0.0.5](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.5)]
### Changed
- Added `service-name` parameter [\#6](https://github.com/CircleCI-Public/aws-ecs-orb/pull/6) ([stringbeans](https://github.com/stringbeans))
