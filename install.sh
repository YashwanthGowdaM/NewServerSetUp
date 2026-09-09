#!/bin/bash

# ===================================================================
# Server Initial Setup Script
# Tested on Ubuntu 24.04 LTS
# ===================================================================

set -e

# ----------------------------
# Colors
# ----------------------------
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

print_header() {
    echo
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

# ----------------------------
# Root Check
# ----------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this script using sudo.${NC}"
    exit 1
fi

USERNAME=${SUDO_USER:-$(whoami)}
HOME_DIR=$(eval echo "~$USERNAME")

print_header "1. Updating Ubuntu"

apt update
apt upgrade -y
apt autoremove -y
apt autoclean -y

print_header "2. Installing Basic Packages"

apt install -y \
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
ca-certificates \
gnupg \
software-properties-common \
apt-transport-https

updatedb

print_header "3. Installing AWS CLI v2"

ARCH=$(dpkg --print-architecture)

if [[ "$ARCH" == "amd64" ]]; then
    AWS_ARCH="x86_64"
elif [[ "$ARCH" == "arm64" ]]; then
    AWS_ARCH="aarch64"
else
    echo "Unsupported Architecture: $ARCH"
    exit 1
fi

cd /tmp

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o awscliv2.zip

rm -rf aws
unzip -oq awscliv2.zip

./aws/install --update

rm -rf aws awscliv2.zip

print_header "4. Installing Docker"

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt update

apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker "$USERNAME"

print_header "5. Installing Python"

apt install -y \
python3 \
python3-pip \
python3-venv

print_header "6. Creating Login Banner"

cat >/etc/motd <<EOF

============================================================
                 Ubuntu Server
============================================================

Authorized access only.

Hostname : $(hostname)
Server   : $(hostname -I | awk '{print $1}')

============================================================

EOF

print_header "7. Installed Versions"

echo
echo "Ubuntu"
lsb_release -d

echo
echo "Git"
git --version

echo
echo "Docker"
docker --version

echo
echo "Docker Compose"
docker compose version

echo
echo "AWS CLI"
aws --version

echo
echo "Python"
python3 --version

echo
echo "PIP"
pip3 --version

echo
echo "Tree"
tree --version | head -1

echo
echo "Locate"
locate --version

print_header "8. Cleaning"

apt clean
apt autoremove -y

print_header "Completed"

echo
echo "Server Initial Setup Completed Successfully."
echo
echo "IMPORTANT:"
echo "Log out and log back in before using Docker without sudo."
