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
echo "Installing Jenkins..."
apt install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Waiting for Jenkins to initialize..."
sleep 20

echo "Downloading Jenkins Backup..."
sudo mkdir /opt/automation/
sudo chmod 777  /opt/automation/
cd  /opt/automation/
curl -u downloader:Yash@123 -O "$BACKUP_URL"

echo "Stopping Jenkins..."
systemctl stop jenkins
echo "Cleaning Existing Jenkins Data..."
rm -rf /var/lib/jenkins/*

echo "Restoring Backup..."
tar -xzf "$BACKUP_FILE" -C /var/lib/jenkins

echo "Fixing Permissions..."
chown -R jenkins:jenkins /var/lib/jenkins

echo "Starting Jenkins..."
systemctl start jenkins

sleep 20
echo ""

############################################################
# OUTPUT
############################################################

STATUS=$(systemctl is-active jenkins)
IP_ADDR="$(curl ifconfig.me)"
PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

echo
echo "=========================================="
echo " Jenkins Installation Completed"
echo "=========================================="
echo "Jenkins Status : $STATUS"
echo "URL            : http://$IP_ADDR:8080"

if [ -f "$PASSWORD_FILE" ]; then
    echo "Initial Password:"
    cat "$PASSWORD_FILE"
else
    echo "Initial Password: Not Available (Backup Restored)"
fi

echo "=========================================="
