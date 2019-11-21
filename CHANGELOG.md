# Changelog
Documents changes in orb version releases.

## [[1.0.1](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=1.0.1)]
### Fixed
- Fix bug that caused orb to fail if single quotes were present in task definition [\#67](https://github.com/CircleCI-Public/aws-ecs-orb/pull/67) ([Xheno](https://github.com/Xheno))

## [[1.0.0](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=1.0.0)]
### Changed
- Improved the build process, but there is no actual change to the orb. Promoted the orb to a 1.0.0 version release as it can be considered stable. [\#77](https://github.com/CircleCI-Public/aws-ecs-orb/pull/77) ([lokst](https://github.com/lokst))

## [[0.0.22](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.22)]
### Fixed
- Updated vulnerable handlebars version [\#69](https://github.com/CircleCI-Public/aws-ecs-orb/pull/69) ([sagarvd01](https://github.com/sagarvd01))
Note: This is not a crucial fix since handlebars is only used at orb-build time to generate the orb YAML.

## [[0.0.21](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.21)]
### Changed
- Update the orb description to mention AWS Fargate launch type support [\#71](https://github.com/CircleCI-Public/aws-ecs-orb/pull/71) ([lokst](https://github.com/lokst))

## [[0.0.20](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.20)]
### Fixed
- Fix typo in orb description [\#70](https://github.com/CircleCI-Public/aws-ecs-orb/pull/70) ([ashishpatelcs](https://github.com/ashishpatelcs))

## [[0.0.19](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.19)]
### Changed
- Improved validation: add validation check for if container is included in container-image-name-updates [\#39](https://github.com/CircleCI-Public/aws-ecs-orb/pull/39) ([Xheno](https://github.com/Xheno))

## [[0.0.18](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.18)]
### Changed
- (No actual change to the orb) Use assertIsNone instead of assertEquals in Python testsuite [\#46](https://github.com/CircleCI-Public/aws-ecs-orb/pull/46) ([StrikerRUS](https://github.com/StrikerRUS))

## [[0.0.17](https://circleci.com/orbs/registry/orb/circleci/aws-ecs?version=0.0.17)]
### Changed
- Simplified and speeded up Python function [\#45](https://github.com/CircleCI-Public/aws-ecs-orb/pull/45) ([StrikerRUS](https://github.com/StrikerRUS))

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
