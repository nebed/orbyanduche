#!/bin/bash

# Set variables
DOMAIN=orbyanduche.nebed.io
FRONTEND_DIR=/var/www/orbyanduche
DOCKER_IMAGE_NAME=orbyanduche
DOCKER_CONTAINER_NAME=orbyanduche

# Update and install necessary packages
sudo apt update
sudo apt install -y docker.io docker-compose

# Build the Docker image for the Flask backend
cd /opt/orbyanduche
sudo docker build -t $DOCKER_IMAGE_NAME .

# Run the Docker container
sudo mkdir -p /opt/qrcodes
sudo docker run -d --name $DOCKER_CONTAINER_NAME -p 5000:5000 -v /opt/qrcodes:/app/qrcodes $DOCKER_IMAGE_NAME

# Set up the Vue.js frontend
sudo mkdir -p $FRONTEND_DIR
sudo cp -r /opt/orbyanduche/dist/* $FRONTEND_DIR

# Generate nginx certificate
sudo service nginx stop
sudo certbot certonly  --standalone -d orbyanduche.nebed.io  --non-interactive --agree-tos -m webmaster@nebed.io
sudo service nginx start

# Set up Nginx
sudo cp /opt/orbyanduche/orbyanduche_nginx.conf /etc/nginx/sites-available/$DOMAIN
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx

echo "Deployment completed. The site should be available at http://$DOMAIN"
