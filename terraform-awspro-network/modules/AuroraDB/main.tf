
resource "aws_db_subnet_group" "awspro_mysql_subnets" {
  name        = "${var.identifier}-subnet-group"
  description = "Private subnets for AWSPro MySQL Dev"
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name        = "${var.identifier}-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "awspro_mysql_sg" {
  name        = "${var.identifier}-sg"
  description = "Allow MySQL only from ECS application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from ECS security group only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.identifier}-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "awspro_mysql" {
  identifier = var.identifier

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.master_username
  port     = 3306

  # AWS generates and manages the master password in Secrets Manager.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.awspro_mysql_subnets.name
  vpc_security_group_ids = [aws_security_group.awspro_mysql_sg.id]
  publicly_accessible    = false

  multi_az               = true
  backup_retention_period = 7
  backup_window           = "18:00-19:00"
  maintenance_window      = "Sun:19:00-Sun:20:00"

  auto_minor_version_upgrade = true
  deletion_protection        = true
  skip_final_snapshot        = false
  final_snapshot_identifier  = var.final_snapshot_identifier
  copy_tags_to_snapshot      = true
  apply_immediately          = false

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name        = var.identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_db_subnet_group.awspro_mysql_subnets,
    aws_security_group.awspro_mysql_sg
  ]
}
