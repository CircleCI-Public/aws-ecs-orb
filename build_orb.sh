#!/bin/bash
set -eo pipefail

cd $(dirname "$0")
node tools/orb-template-processor.js src/orb.yml.hbs > src/@orb.yml