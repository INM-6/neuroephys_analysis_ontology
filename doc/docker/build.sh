#!/bin/bash

RELEASE_PATH=$(realpath ../releases/*)

# Get latest version
if ! ls -ad $RELEASE_PATH
then
    printf "\n\nNo documentation found in '$RELEASE_PATH'\n"
    printf "Please, build the documentation first with $(realpath ../build_doc.sh)\n\n"
    exit
fi
LATEST_VERSION=$(ls -ad $RELEASE_PATH | tail -n 1)

# Copy updated documentation files
rm -rf ./doc
cp -r $LATEST_VERSION ./doc

# Remove any running container
docker stop $(docker ps -q --filter "name=neao_doc") >/dev/null 2>&1
docker container rm $(docker ps -a -q --filter "name=neao_doc") >/dev/null 2>&1

# Build docker image with Apache and documentation
docker build --no-cache -t neao_doc .

# Prune old images
docker image prune -f
