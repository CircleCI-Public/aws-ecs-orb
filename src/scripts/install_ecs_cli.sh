#!/bin/bash
if [ $EUID == 0 ]; then export SUDO=""; else export SUDO="sudo"; fi

ORB_STR_VERSION="$(circleci env subst "${ORB_STR_VERSION}")"
ORB_EVAL_INSTALL_DIR="$(eval echo "${ORB_EVAL_INSTALL_DIR}")"

# Platform check
if uname -a | grep "Darwin"; then
    export SYS_ENV_PLATFORM="darwin"
    MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
    DELIMIT_VERSION=$(echo "$ORB_STR_VERSION" | cut -dv -f2)
    MAJOR=$(echo "$DELIMIT_VERSION" | cut -d. -f1)
    MINOR=$(echo "$DELIMIT_VERSION" | cut -d. -f2)
    if [ "$MACOS_VERSION" -ge "12" ] && [ "$MAJOR" -le "1" ] && [ "$MINOR" -lt "9" ]; then
        echo "Error: ECS CLI version ${ORB_STR_VERSION} is not supported with macOS version ${MACOS_VERSION}. Please upgrade to macOS version 1.9 or later."
        exit 1
    fi
elif uname -a | grep "x86_64 GNU/Linux"; then
    export SYS_ENV_PLATFORM="linux"
else
    echo "This platform appears to be unsupported."
    uname -a
    exit 1
fi

Install_ECS_CLI(){
    $SUDO curl -Lo "${ORB_EVAL_INSTALL_DIR}" "https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-${SYS_ENV_PLATFORM}-amd64-$1"
    $SUDO chmod +x "${ORB_EVAL_INSTALL_DIR}"
}

Uninstall_ECS_CLI(){
    echo "Uninstalling ECS CLI..."
    ECS_CLI_PATH="$(command -v ecs-cli)"
    $SUDO rm -rf "${ECS_CLI_PATH}"
}

if ! command -v ecs-cli; then
    echo "Installing ECS CLI..."
    Install_ECS_CLI "${ORB_STR_VERSION}"
    ecs-cli --version
else
    if [ "$ORB_BOOL_OVERRIDE_INSTALLED" = 1 ]; then
        echo "Overriding installed ECS CLI..."
        Uninstall_ECS_CLI
        Install_ECS_CLI "${ORB_STR_VERSION}"
        ecs-cli --version
    else
        echo "ECS CLI is already installed."
        ecs-cli --version
    fi
fi

