resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow all inbound traffic for RDS"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  identifier             = "database-1"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "null_resource" "init_db" {
  depends_on = [aws_db_instance.default]

  provisioner "local-exec" {
    # מריץ את קובץ ה-SQL מול ה-RDS שנוצר
    command = "mysql -h ${aws_db_instance.default.address} -P ${aws_db_instance.default.port} -u root -p${aws_db_instance.default.password} < ${var.init_db_sql_path}"
  }
}
