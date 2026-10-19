#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/awspro-terraform-setup.log) 2>&1

# Update operating system
dnf update -y

# Install required utilities
dnf install -y \
  git \
  jq \
  unzip \
  tar \
  gzip \
  curl \
  wget \
  bash-completion \
  python3 \
  python3-pip \
  ca-certificates \
  openssl

# Install AWS CLI v2
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o awscliv2.zip

unzip -q -o awscliv2.zip
./aws/install --update

rm -rf /tmp/aws /tmp/awscliv2.zip

# Install HashiCorp repository
dnf install -y dnf-plugins-core

dnf config-manager \
  --add-repo \
  https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
dnf install -y terraform

# Install Docker CLI and engine (optional for container testing)
dnf install -y docker
systemctl enable --now docker

# Create working directory
mkdir -p /opt/awspro/terraform
chmod 0755 /opt/awspro/terraform

# Verify installations
terraform -version
aws --version
git --version
jq --version
python3 --version
docker --version

echo "AWSPro Terraform execution server setup completed."