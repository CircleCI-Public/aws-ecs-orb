set -o noglob
if [ "<<parameters.launch-type>>" == "FARGATE" ]; then
    echo "Setting --platform-version"
    set -- "$@" --platform-version "<<parameters.platform-version>>"
fi
if [ ! -z "<<parameters.started-by>>" ]; then
    echo "Setting --started-by"
    set -- "$@" --started-by "<<parameters.started-by>>"
fi
if [ ! -z "<<parameters.group>>" ]; then
    echo "Setting --group"
    set -- "$@" --group "<<parameters.group>>"
fi
if [ ! -z "<<parameters.overrides>>" ]; then
    echo "Setting --overrides"
    set -- "$@" --overrides "<<parameters.overrides>>"
    fi
if [ ! -z "<<parameters.tags>>" ]; then
    echo "Setting --tags"
    set -- "$@" --tags "<<parameters.tags>>"
fi
if [ ! -z "<<parameters.placement-constraints>>" ]; then
    echo "Setting --placement-constraints"
    set -- "$@" --placement-constraints "<<parameters.placement-constraints>>"
fi
if [ ! -z "<<parameters.placement-strategy>>" ]; then
    echo "Setting --placement-strategy"
    set -- "$@" --placement-strategy "<<parameters.placement-strategy>>"
fi
if [ "<<parameters.enable-ecs-managed-tags>>" == "true" ]; then
    echo "Setting --enable-ecs-managed-tags"
    set -- "$@" --enable-ecs-managed-tags
fi
if [ "<<parameters.propagate-tags>>" == "true" ]; then
    echo "Setting --propagate-tags"
    set -- " $@" --propagate-tags "TASK_DEFINITION"
fi
if [ "<<parameters.awsvpc>>" == "true" ]; then
    echo "Setting --network-configuration"
    set -- "$@" --network-configuration awsvpcConfiguration="{subnets=[<<parameters.subnet-ids>>],securityGroups=[<<parameters.security-group-ids>>],assignPublicIp=<<parameters.assign-public-ip>>}"\

fi

aws ecs run-task \
  --cluster <<parameters.cluster>> \
  --task-definition <<parameters.task-definition>> \
  --count <<parameters.count>> \
  --launch-type <<parameters.launch-type>> \
  "$@"
