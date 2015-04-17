#!/bin/sh

## Name of Docker Hub repository
REPO=releasequeue/ci-buildtools
##

echo Building and tagging ${REPO}:$1 and ${REPO}:latest

# Folder name to Docker name
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename ${PROJECT_DIR} | sed 's/[-_.]//g')

# Docker container and image variables
CHEF_IMAGE_NAME="releasequeue/chef-client"
CHEF_IMAGE_VERSION="12.1.1-1"
CHEF_CONTAINER_NAME=${PROJECT_NAME}_chef
DATA_IMAGE_NAME=${PROJECT_NAME}_chefdata
DATA_CONTAINER_NAME=${DATA_IMAGE_NAME}
APP_IMAGE_NAME="intermediate_app_image"
APP_CONTAINER_NAME=${PROJECT_NAME}_app_container

echo "####"
echo "#### Setting up Chef cookbooks"
echo "####"
rm -rf chef/cookbooks/
berks vendor chef/cookbooks

# Pull the Chef image
echo "####"
echo "#### Pulling Chef image"
echo "####"
docker pull ${CHEF_IMAGE_NAME}:${CHEF_IMAGE_VERSION}

# Remove old images if needed
echo "####"
echo "#### Removing images from previous run"
echo "####"
#docker images | grep "_chefdata" | awk '{print $1}' | xargs docker rmi
#docker images | grep "_image" | awk '{print $1}' | xargs docker rmi
docker rmi ${REPO}:latest

# Now build the chefdata container first
echo "####"
echo "#### Building data volume container with Chef cookbooks"
echo "####"
docker build -t ${DATA_IMAGE_NAME} chef

# Create the data volume containers
echo "####"
echo "#### Create the data volume containers for Chef and the cookbooks"
echo "####"
docker create --name ${CHEF_CONTAINER_NAME} ${CHEF_IMAGE_NAME}:${CHEF_IMAGE_VERSION} /bin/true
docker create --name ${DATA_CONTAINER_NAME} ${DATA_IMAGE_NAME} /bin/true

# Build the image
echo "####"
echo "#### Building application container using Chef"
echo "####"
docker run -it --name ${APP_CONTAINER_NAME} --volumes-from ${CHEF_CONTAINER_NAME} --volumes-from ${DATA_CONTAINER_NAME} ubuntu:14.04.2 /opt/chef/bin/chef-client -c /tmp/chef/zero.rb -z -j /tmp/chef/first-boot.json

# Commit the container to an intermediate image
echo "####"
echo "#### Committing the application container as an intermediate image"
echo "####"
docker commit ${APP_CONTAINER_NAME} ${APP_IMAGE_NAME}

# Build the final image starting from the intermediate container
echo "####"
echo "#### Building the final image starting from the intermediate image"
echo "####"
docker build -t ${REPO}:latest .

# Remove containers
echo "####"
echo "#### Removing containers from previous run"
echo "####"
docker rm ${APP_CONTAINER_NAME}
docker rm ${DATA_CONTAINER_NAME}
docker rm ${CHEF_CONTAINER_NAME}

# Remove images
echo "####"
echo "#### Removing intermediate images"
echo "####"
docker rmi ${APP_IMAGE_NAME}
docker rmi ${DATA_IMAGE_NAME}

# Push the image
#docker push $REPO:$1
#docker push $REPO:latest