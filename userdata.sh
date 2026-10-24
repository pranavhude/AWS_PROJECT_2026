
#!/bin/bash
set -Eeuo pipefail

# --------------------------------------------------
# AWSPro Terraform Server - User Data
# OS: Amazon Linux 2023
# --------------------------------------------------

exec > >(tee -a /var/log/awspro-terraform-setup.log) 2>&1

trap 'rc=$?; echo "ERROR: Setup failed at line ${LINENO}, exit code ${rc}"; exit "$rc"' ERR

echo "===== Starting AWSPro Terraform Server Setup ====="

# Run as root through EC2 user data
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: User data must run as root."
  exit 1
fi

# --------------------------------------------------
# 1. UPDATE OPERATING SYSTEM
# --------------------------------------------------

dnf update -y

# --------------------------------------------------
# 2. INSTALL REQUIRED UTILITIES AND GIT
# --------------------------------------------------

dnf install -y \
  git \
  jq \
  curl \
  unzip \
  tar \
  gzip \
  ca-certificates \
  shadow-utils \
  dnf-plugins-core

# --------------------------------------------------
# 3. INSTALL TERRAFORM
# --------------------------------------------------

if ! command -v terraform >/dev/null 2>&1; then
  dnf config-manager \
    --add-repo \
    https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

  dnf install -y terraform
fi

# --------------------------------------------------
# 4. INSTALL AWS CLI V2
# --------------------------------------------------

if ! command -v aws >/dev/null 2>&1; then
  ARCH="$(uname -m)"

  case "$ARCH" in
    x86_64)
      AWS_CLI_ARCH="x86_64"
      ;;
    aarch64)
      AWS_CLI_ARCH="aarch64"
      ;;
    *)
      echo "ERROR: Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  cd /tmp

  curl --fail --silent --show-error --location \
    "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}.zip" \
    -o awscliv2.zip

  unzip -q -o awscliv2.zip

  ./aws/install

  rm -rf aws awscliv2.zip
fi

# --------------------------------------------------
# 5. INSTALL AND START SSM AGENT
# --------------------------------------------------

if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
  ARCH="$(uname -m)"

  case "$ARCH" in
    x86_64)
      SSM_ARCH="linux_amd64"
      ;;
    aarch64)
      SSM_ARCH="linux_arm64"
      ;;
    *)
      echo "ERROR: Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  curl --fail --silent --show-error --location \
    "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/${SSM_ARCH}/amazon-ssm-agent.rpm" \
    -o /tmp/amazon-ssm-agent.rpm

  dnf install -y /tmp/amazon-ssm-agent.rpm

  rm -f /tmp/amazon-ssm-agent.rpm
fi

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# --------------------------------------------------
# 6. CREATE TERRAFORM WORKING DIRECTORY
# --------------------------------------------------

mkdir -p /opt/awspro/terraform
chmod 0755 /opt/awspro
chmod 0755 /opt/awspro/terraform

# --------------------------------------------------
# 7. VERIFY INSTALLATIONS
# --------------------------------------------------

echo "===== Git Version ====="
git --version

echo "===== Terraform Version ====="
terraform -version

echo "===== AWS CLI Version ====="
aws --version

echo "===== SSM Agent Status ====="
systemctl is-active amazon-ssm-agent

echo "===== AWSPro Terraform Server Setup Completed ====="
