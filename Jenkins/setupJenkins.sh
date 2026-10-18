#!/bin/bash

############################################################
# Jenkins Installation & Restore Script
# OS  : Ubuntu 24.04 / 26.04
############################################################

set -e

BACKUP_URL="http://129.159.237.133/artifacts/jenkins_backup.tar.gz"
BACKUP_FILE="/tmp/jenkins_backup.tar.gz"

echo "======================================="
echo "Updating packages..."
echo "======================================="
apt update -y

echo "======================================="
echo "Installing Java..."
echo "======================================="
apt install -y openjdk-21-jdk

echo "======================================="
echo "Adding Jenkins Repository..."
echo "======================================="

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
| tee /etc/apt/keyrings/jenkins-keyring.asc >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt update -y

echo "======================================="
echo "Installing Jenkins..."
echo "======================================="

apt install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Waiting for Jenkins to initialize..."
sleep 20

echo "======================================="
echo "Downloading Jenkins Backup..."
echo "======================================="

cd /tmp

curl -u downloader:Yash@123 -O "$BACKUP_URL"

echo "======================================="
echo "Stopping Jenkins..."
echo "======================================="

systemctl stop jenkins

echo "======================================="
echo "Cleaning Existing Jenkins Data..."
echo "======================================="

rm -rf /var/lib/jenkins/*

echo "======================================="
echo "Restoring Backup..."
echo "======================================="

tar -xzf "$BACKUP_FILE" -C /var/lib/jenkins

echo "======================================="
echo "Fixing Permissions..."
echo "======================================="

chown -R jenkins:jenkins /var/lib/jenkins

echo "======================================="
echo "Starting Jenkins..."
echo "======================================="

systemctl start jenkins

sleep 20

############################################################
# OUTPUT
############################################################

STATUS=$(systemctl is-active jenkins)

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s https://ifconfig.me)
fi

if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s https://icanhazip.com)
fi

PORT=$(grep -- '--httpPort=' /usr/lib/systemd/system/jenkins.service \
| sed -E 's/.*--httpPort=([0-9]+).*/\1/')

if [ -z "$PORT" ]; then
    PORT=8080
fi

PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

echo
echo "=========================================="
echo " Jenkins Installation Completed"
echo "=========================================="
echo "Jenkins Status : $STATUS"
echo "URL            : http://$IP:$PORT"

if [ -f "$PASSWORD_FILE" ]; then
    echo "Initial Password:"
    cat "$PASSWORD_FILE"
else
    echo "Initial Password: Not Available (Backup Restored)"
fi

echo "=========================================="
