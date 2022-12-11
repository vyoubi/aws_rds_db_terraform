provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "internshop"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "internshop" {
  name       = "internshop"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "InternshopDB"
  }
}

resource "aws_security_group" "rds" {
  name   = "internshop_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internshop_rds"
  }
}

resource "aws_db_parameter_group" "internshop" {
  name   = "internshop"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "internshop" {
  identifier             = "internshop"
  instance_class         = "db.t3.micro"
  allocated_storage      = 50
  engine                 = "postgres"
  engine_version         = "13.7"
  username               = "internshop"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.internshop.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.internshop.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
