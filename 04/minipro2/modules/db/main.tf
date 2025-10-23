# DB SG: 3306은 나중에 EC2 웹SG에서만 허용
resource "aws_security_group" "db" {
  name   = "${var.project}-db-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-db-sg" }
}


resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnets"
  subnet_ids = var.db_subnet_ids
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.project}-aurora"
  engine             = "aurora-mysql"
  # engine_version   = "8.0.mysql_aurora.3.06.0" # 버전 고정 원하면 사용
  master_username    = var.db_username
  master_password    = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  storage_encrypted       = true
  tags = { Name = "${var.project}-aurora" }
}

# Writer + Reader
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.project}-writer"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.this.engine
}

resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.project}-reader"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.this.engine
}


