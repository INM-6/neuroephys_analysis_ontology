#!/bin/bash

# Remove any running container
docker rm $(docker stop $(docker ps -a -q --filter "name=neao_doc"))

# Run image
docker run -dit --name neao_doc -p 8080:80 neao_doc

echo "open http://localhost:8080/ for visualizing the documentation"
