#/bin/bash

#ex) docker rmi test-service:0.1
docker rmi {image name}:0.1
#docker build -t test-service:0.1 .
docker build -t {image name}:0.1 .
