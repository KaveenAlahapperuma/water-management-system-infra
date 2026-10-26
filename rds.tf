resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-db-subnets"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.prefix}-db-subnets" }
}

resource "aws_security_group" "rds" {
  name        = "${var.prefix}-rds-sg"
  description = "PostgreSQL access from EKS nodes only"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.prefix}-rds-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL from EKS nodes"
}

resource "aws_db_instance" "main" {
  identifier     = "${var.prefix}-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  db_name  = "wms"
  username = "wmsadmin"

  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.this["secrets"].arn

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = aws_kms_key.this["rds"].arn

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = { Name = "${var.prefix}-postgres" }
}