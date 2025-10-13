#!/bin/bash
set -o noglob

ORB_STR_TASK_DEFINITION_TAGS="$(circleci env subst "$ORB_STR_TASK_DEFINITION_TAGS")"
ORB_STR_PROFILE_NAME="$(circleci env subst "$ORB_STR_PROFILE_NAME")"
ORB_AWS_REGION="$(circleci env subst "$ORB_AWS_REGION")"

# shellcheck disable=SC2086
aws ecs tag-resource \
	--resource-arn "${CCI_ORB_AWS_ECS_REGISTERED_TASK_DFN}" \
	--tags ${ORB_STR_TASK_DEFINITION_TAGS} \
	--profile "${ORB_STR_PROFILE_NAME}" \
	--region "${ORB_AWS_REGION}"
