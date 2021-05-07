resource "aws_db_instance" "mysql" {
  identifier           = "${var.prefix}-mysql"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "catalog"
  username             = var.mysql_admin_username
  password             = var.mysql_admin_password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = module.vpc.database_subnet_group_name
  skip_final_snapshot  = true

  vpc_security_group_ids = [
    aws_security_group.rds.id,
    module.vpc.default_security_group_id
  ]

  tags = {
    Name = "${var.prefix}-mysql"
    App  = var.prefix
  }
}
