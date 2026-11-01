
data "aws_ssm_parameter" "awspro_bastion_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "awspro_bastion_role" {
  name = "awspro-bastion-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "awspro-bastion-role-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "awspro_bastion_ssm" {
  role       = aws_iam_role.awspro_bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "awspro_bastion_profile" {
  name = "awspro-bastion-profile-dev"
  role = aws_iam_role.awspro_bastion_role.name
}

resource "aws_security_group" "awspro_bastion_sg" {
  name        = "awspro-bastion-sg-dev"
  description = "Restricted SSH and SSM access for Dev bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from approved administrator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "Outbound connectivity for SSM and administration"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "awspro-bastion-sg-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "awspro_bastion" {
  ami                         = data.aws_ssm_parameter.awspro_bastion_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.awspro_bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.awspro_bastion_profile.name
  associate_public_ip_address = true
  key_name                    = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
      dnf install -y amazon-ssm-agent
    fi

    systemctl enable amazon-ssm-agent
    systemctl restart amazon-ssm-agent
  EOF

  tags = {
    Name        = "awspro-bastion-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.awspro_bastion_ssm
  ]
}
