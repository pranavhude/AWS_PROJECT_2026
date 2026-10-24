```bash
#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/awspro-terraform-setup.log) 2>&1

# Update OS
dnf update -y

# Install Git and required utilities
dnf install -y \
  git \
  jq \
  curl \
  unzip \
  tar \
  gzip \
  ca-certificates

# Install Terraform repository
dnf install -y dnf-plugins-core

dnf config-manager \
  --add-repo \
  https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
dnf install -y terraform

# Install and start SSM Agent
dnf install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# Create Terraform working directory
mkdir -p /opt/awspro/terraform
chmod 0755 /opt/awspro/terraform

# Verify installations
git --version
terraform -version
systemctl is-active amazon-ssm-agent

echo "Git, Terraform, and SSM Agent setup completed."