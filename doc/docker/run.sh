#!/bin/bash

# Remove any running container
docker stop $(docker ps -q --filter "name=neao_doc") >/dev/null 2>&1
docker container rm $(docker ps -a -q --filter "name=neao_doc") >/dev/null 2>&1

# Run image
docker run -dit --name neao_doc -p 8080:80 neao_doc

echo "open http://localhost:8080/ for visualizing the documentation"
