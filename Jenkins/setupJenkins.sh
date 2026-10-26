#!/bin/bash

set -e

BACKUP_URL="http://129.159.237.133/artifacts/Jenkins/jenkins_backup_v1.tar.gz"
BACKUP_USER="mygart"
BACKUP_PASS="Yash@123"

WORK_DIR="/opt/automation"
BACKUP_FILE="${WORK_DIR}/jenkins_backup_v1.tar.gz"

echo "Updating packages..."
apt update -y

echo "Installing Java..."
apt install -y openjdk-21-jdk curl gnupg -qq

echo "Adding Jenkins repository..."
mkdir -p /etc/apt/keyrings

rm -f /etc/apt/sources.list.d/jenkins.list

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
| tee /etc/apt/keyrings/jenkins-keyring.asc >/dev/null

cat >/etc/apt/sources.list.d/jenkins.list <<EOF
deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/
EOF

apt update -y

echo "Installing Jenkins..."
apt install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Waiting for Jenkins to start..."
sleep 20

echo "Creating working directory..."
mkdir -p "$WORK_DIR"

echo "Downloading Jenkins backup..."
curl -u mygart:'Yash@123' -O 'http://129.159.237.133/artifacts/Jenkins/jenkins_backup_v1.tar.gz'

echo "Stopping Jenkins..."
systemctl stop jenkins

echo "Removing existing Jenkins data..."
rm -rf /var/lib/jenkins/*

echo "Restoring Jenkins backup..."
tar -xzf "$BACKUP_FILE" -C /var/lib/jenkins

echo "Setting permissions..."
chown -R jenkins:jenkins /var/lib/jenkins

echo "Starting Jenkins..."
systemctl start jenkins

echo "Waiting for Jenkins..."
sleep 30

STATUS=$(systemctl is-active jenkins)

PORT=8080

PUBLIC_IP=$(curl -s ifconfig.me)

if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(hostname -I | awk '{print $1}')
fi

PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

echo
echo "Jenkins Status : $STATUS"
echo "URL            : http://${PUBLIC_IP}:${PORT}"
echo "Password       : Admin@12345"
