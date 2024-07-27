#!/bin/bash

# Set variables
DOMAIN=orbyanduche.nebed.io
FRONTEND_DIR=/var/www/orbyanduche
DOCKER_IMAGE_NAME=orbyanduche
DOCKER_CONTAINER_NAME=orbyanduche

# Update and install necessary packages
sudo apt update
sudo apt install -y docker.io docker-compose nginx

# Build the Docker image for the Flask backend
cd /path/to/your/flask/app
sudo docker build -t $DOCKER_IMAGE_NAME .

# Run the Docker container
sudo docker run -d --name $DOCKER_CONTAINER_NAME -p 5000:5000 $DOCKER_IMAGE_NAME

# Set up the Vue.js frontend
sudo mkdir -p $FRONTEND_DIR
sudo cp -r /path/to/your/vue/dist/* $FRONTEND_DIR

# Set up Nginx
sudo cp /path/to/orbyanduche.conf /etc/nginx/sites-available/$DOMAIN
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx

echo "Deployment completed. The site should be available at http://$DOMAIN"
