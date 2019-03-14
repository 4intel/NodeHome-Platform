#/bin/bash

#ex) docker rmi test-service:0.1
docker rmi {docker account}/{image name}:0.1
#docker build -t test-service:0.1 .
docker build -t {docker account}/{image name}:0.1 .
