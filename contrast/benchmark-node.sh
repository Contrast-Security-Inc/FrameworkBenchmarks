#!/bin/bash
set -e

cd "${0%/*}"

# Use files in the script directory by default
AGENT_FILE=${1-node-contrast.tgz}

if [[ $(basename -- "$AGENT_FILE") != "node-contrast.tgz" ]];
    then echo "First argument must be a path to node-contrast.tgz" && exit 1;
fi;

if [[ ! -f $AGENT_FILE ]];
    then echo "Could not find $AGENT_FILE" && exit 1;
fi;

# Copy files into correct place
./copy-files.sh JavaScript $AGENT_FILE

# Create tfb network if it's not already up
if ! docker network inspect tfb >/dev/null 2>&1; then
  docker network create tfb >/dev/null
fi

# Start contrast-service container
docker build . -f contrast-service.dockerfile -t contrast-service   
docker run --rm -d --network tfb --name contrast-service contrast-service

# Run tests
../tfb --tag contrast --test-lang JavaScript --type fortune --duration 5

# Stop contrast-service container
docker stop contrast-service