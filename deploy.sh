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

# Create folder for Thingsboard deployment
mkdir thingsboard-docker
cd thingsboard-docker

# Download Thingsboard docker files
curl -L https://raw.githubusercontent.com/thingsboard/thingsboard/release-2.0/docker/docker-compose.yml > docker-compose.yml
curl -L https://raw.githubusercontent.com/thingsboard/thingsboard/release-2.0/docker/.env > .env
curl -L https://raw.githubusercontent.com/thingsboard/thingsboard/release-2.0/docker/tb.env > tb.env

# Remove previous version of Thingsboard
sudo rm -rf /home/docker/hsqldb_volume

# Deploy Thingsboard with demo data
ADD_SCHEMA_AND_SYSTEM_DATA=true ADD_DEMO_DATA=true bash -c 'sudo docker-compose up -d tb'
# Deploy simple Thingsboard
# sudo docker-compose up -d tb

# Deploy Portainer for easiest container management
sudo docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

# Deploy Node-Red
sudo docker run -d -p 1880:1880 --restart=always --name Node-Red nodered/node-red-docker

# Deploy Swagger Editor
sudo docker run -d -p 1000:8080 --restart=always swaggerapi/swagger-editor
