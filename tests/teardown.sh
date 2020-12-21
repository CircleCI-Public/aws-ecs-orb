BASEDIR=$(pwd)

tearDownTF() {
    terraform init
    terraform destroy -auto-approve \
        -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
        -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
        -var "aws_region=${AWS_DEFAULT_REGION}" \
        -var "aws_account_id=${AWS_ACCOUNT_ID}" \
        -var "aws_resource_prefix=${AWS_RESOURCE_PREFIX}"
}

cd "${BASEDIR}/terraform_setup/ec2" || exit 1
AWS_RESOURCE_PREFIX=ecs-orb-ec2-1
tearDownTF
cd "${BASEDIR}/terraform_setup/fargate" || exit 1
AWS_RESOURCE_PREFIX=ecs-orb-fg-1
tearDownTF
cd "${BASEDIR}/terraform_setup/fargate_codedeploy" || exit 1
AWS_RESOURCE_PREFIX=ecs-orb-cdfg-1
tearDownTF
