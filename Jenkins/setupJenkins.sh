#!/bin/bash
set -e

BACKUP_URL="http://129.159.237"
# FIX: Adjusted to the actual download folder so tar can find it
BACKUP_FILE="/opt/automation/jenkins_backup.tar.gz"

echo "Updating packages..."
apt update -y

echo "Installing Java..."
apt install -y openjdk-21-jdk

echo "Adding Jenkins Repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://jenkins.io | tee /etc/apt/keyrings/jenkins-keyring.asc >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://jenkins.io binary/" > /etc/apt/sources.list.d/jenkins.list

apt update -y
echo "Installing Jenkins..."
apt install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Waiting for Jenkins to initialize..."
sleep 20

echo "Downloading Jenkins Backup to local disk..."
sudo mkdir -p /opt/automation/
sudo chmod 777 /opt/automation/
cd /opt/automation/
# Downloads directly into your spacious 12GB root partition, bypassing /tmp
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

STATUS=$(systemctl is-active jenkins)
IP_ADDR="$(curl -s ifconfig.me)"
echo "=========================================="
echo " Jenkins Installation Completed"
echo "=========================================="
echo "Jenkins Status : $STATUS"
echo "URL            : http://$IP_ADDR:8080"
echo "=========================================="
