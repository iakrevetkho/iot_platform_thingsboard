#!/usr/bin/env sh

# remove old docker versions
sudo apt-get remove docker docker-engine docker.io

# Install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add docker repo:
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Update the apt package index
sudo apt-get update -y

# Install docker-ce:
sudo apt-get install docker-ce -y

# Install docker-compose
# Download
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
# Apply permissions
sudo chmod +x /usr/local/bin/docker-compose

# Delete all previously containers
sudo docker rm $(sudo docker ps -a -q) -f
# Delete previously containers images
sudo docker rmi $(sudo docker images -q) -f

# Go to folder for Thingsboard deployment
cd thingsboard-docker

# Remove previous version of Thingsboard
sudo rm -rf /home/docker/hsqldb_volume
sudo rm -rf /home/docker/cassandra_volume
sudo rm -rf /home/docker/postgres_volume

# Deploy Thingsboard with demo data
# ADD_SCHEMA_AND_SYSTEM_DATA=true ADD_DEMO_DATA=true bash -c 'sudo docker-compose up -d tb'
# Deploy simple Thingsboard
sudo docker-compose up -d

# Return to main folder
cd ..

# 1000 - Portainer
# 1001 - cAdvisor
# 1002 - Node-Red
# 1003 - Swagger Editor

# Deploy Portainer for easiest container management
sudo docker run -d -p 1000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

# Deploy Node-Red
sudo docker run -d -p 1002:1880 --network="thingsboard-docker_default" --restart=always --name Node-Red nodered/node-red-docker

# Deploy Swagger Editor
sudo docker run -d -p 1003:8080 --network="thingsboard-docker_default" --restart=always swaggerapi/swagger-editor

#Deploy cAdvisor for monitoring resources
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=1001:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest

# Cleaning gurbage

