# tests/

This is where your testing scripts for whichever language is embeded in your orb live, which can be executed locally and within a CircleCI pipeline prior to publishing.

# Testing Orbs

This orb is built using the `circleci orb pack` command, which allows the _command_ logic to be separated out into separate _shell script_ `.sh` files. Because the logic now sits in a known and executable language, it is possible to perform true unit testing using existing frameworks such a [BATS-Core](https://github.com/bats-core/bats-core#installing-bats-from-source).

## **Example _command.yml_**

```yaml

description: A sample command

parameters:
  source:
    description: "source path parameter example"
    type: string
    default: src

steps:
  - run:
      name: "Ensure destination path"
      environment:
        ORB_SOURCE_PATH: <<parameters.source>>
      command: <<include(scripts/command.sh)>>
```
<!--- <span> is used to disable the automatic linking to a potential website. --->
## **Example _command<span>.sh_**

```bash

CreatePackage() {
    cd "$ORB_SOURCE_PATH" && make
    # Build some application at the source location
    # In this example, let's assume given some
    # sample application and known inputs,
    # we expect a certain logfile would be generated.
}

# Will not run if sourced from another script.
# This is done so this script may be tested.
if [[ "$_" == "$0" ]]; then
    CreatePackage
fi

```

We want our script to execute when running in our CI environment or locally, but we don't want to execute our script if we are testing it. In the case of testing, we only want to source the functions within our script,t his allows us to mock inputs and test individual functions.

**A POSIX Compliant Source Checking Method:**

```shell
# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    RUN CODE
fi
```

**Example _command_tests.bats_**

BATS-Core is a useful testing framework for shell scripts. Using the "source checking" methods above, we can source our shell scripts from within our BATS tests without executing any code. This allows us to call specific functions and test their output.

```bash
# Runs prior to every test.
setup() {
    # Load functions from our script file.
    # Ensure the script will not execute as
    # shown in the above script example.
    source ./src/scripts/command.sh
}

@test '1: Test Build Results' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export ORB_SOURCE_PATH="src/my-sample-app"
    CreatePackage
    # test the results
    grep -e 'RESULT="success"' log.txt
}

```

Tests can contain any valid shell code. Any error codes returned during a test will result in a test failure.

In this example, we grep the contents of `log.txt.` which should contain a `success` result if the `CreatePackage` function we had loaded executed successfully.

## See:
 - [BATS Orb](https://circleci.com/orbs/registry/orb/circleci/bats)
 - [Orb Testing CircleCI Docs](https://circleci.com/docs/2.0/testing-orbs)
 - [BATS-Core GitHub](https://github.com/bats-core/bats-core)
