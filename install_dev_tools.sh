#!/bin/bash

sudo apt-get update

if ! command -v curl &> /dev/null; then
    echo "Install curl..."
    sudo apt-get install -y curl
fi

if ! command -v docker &> /dev/null; then
  echo "Install Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
else
  echo "Docker already installed"
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Install Docker Compose..."
  sudo apt-get install -y docker-compose
else
  echo "Docker Compose already installed"
fi

if ! python3 --version | grep -q '3\.[9-9]\|[1-9][0-9]'; then
  echo "Install Python 3.9+..."
  sudo apt-get install -y python3 python3-pip
else
  echo "Python 3.9+ already installed"
fi

if ! command -v pip3 &> /dev/null; then
  echo "Install pip3..."
  sudo apt-get install -y python3-pip
else
  echo "pip3 already installed"
fi

if ! python3 -m django --version &> /dev/null; then
  echo "Install Django..."
  sudo apt-get install -y python3-django
else
  echo "Django already installed"
fi

echo "Installation complete!"