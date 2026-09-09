#!/bin/bash

set -e

echo "===================================================="
echo "      SERVER INITIAL SETUP STARTED"
echo "===================================================="

# Update Ubuntu
echo "Updating Ubuntu..."
sudo apt update
sudo apt upgrade -y

# Install Common Packages
echo "Installing common packages..."
sudo apt install -y \
git \
curl \
wget \
vim \
tree \
plocate \
zip \
unzip \
jq \
htop \
net-tools \
dnsutils \
python3 \
python3-pip \
python3-venv

sudo updatedb

# Install AWS CLI v2
echo "Installing AWS CLI..."
cd /tmp

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -oq awscliv2.zip
sudo ./aws/install --update

rm -rf aws awscliv2.zip

# Install Docker
echo "Installing Docker..."

curl -fsSL https://get.docker.com | sudo sh

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

# Install GitHub CLI
echo "Installing GitHub CLI..."

(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y))
sudo mkdir -p -m 755 /etc/apt/keyrings

wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
| sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null

sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
| sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt update
sudo apt install gh -y

echo
echo "===================================================="
echo "Installed Versions"
echo "===================================================="

git --version
gh --version | head -1
aws --version
docker --version
docker compose version
python3 --version
pip3 --version
tree --version | head -1
locate --version

echo
echo "===================================================="
echo "Setup Completed Successfully"
echo "===================================================="
echo
echo "Logout/Login once to use Docker without sudo."
