#!/bin/bash

set -e

DOCKER_VERSION="20.10.9"
DOCKER_COMPOSE_VERSION="1.29.2"

sudo apt-get update
sudo apt-get install -y curl

echo "Installing Docker..."

wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz

tar xzvf docker-${DOCKER_VERSION}.tgz
sudo mv docker/* /usr/bin/

rm -rf docker-${DOCKER_VERSION}.tgz docker

sudo bash -c 'cat <<EOF > /etc/systemd/system/docker.service
[Unit]
Description=Docker Daemon
After=network.target

[Service]
ExecStart=/usr/bin/dockerd
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ${USER}

echo "Installing Docker Compose..."

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

echo "Verifying installations..."
docker --version
docker-compose --version

echo "Installation completed. You may need to re-login or restart to use Docker without sudo."

echo '{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
sudo systemctl enable docker

