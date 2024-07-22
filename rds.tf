# Create DB subnet group
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "private-group"
  
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-subnet-group"
  })  
}

# Create RDS
resource "aws_db_instance" "mysql_db" {
  allocated_storage            = 20
  storage_type                 = "gp2"
  engine                       = "mysql"
  engine_version               = "8.0.35"
  instance_class               = "db.t3.micro"
  db_name                      = var.rds_db_name
  username                     = var.rds_username
  password                     = var.rds_password
  port                         = 3306
  snapshot_identifier          = null
  skip_final_snapshot          = true
  db_subnet_group_name         = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]
  multi_az                     = true


  tags = merge(local.tags, {
    "Name" = "${var.tagName}-RDS"
  })
}

# output the rds endpoint
output "rds_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}