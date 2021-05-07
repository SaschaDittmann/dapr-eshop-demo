data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.prefix}-eks"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                         = "${var.prefix}-vpc"
  cidr                         = "10.0.0.0/16"
  azs                          = data.aws_availability_zones.available.names
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets               = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  create_database_subnet_group = true
  database_subnets             = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_dns_hostnames         = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"

  tags = {
    Name = "${var.prefix}-dynamodb-endpoint"
    App  = var.prefix
  }
}

resource "aws_vpc_endpoint" "rds" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.rds"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.prefix}-rds-endpoint"
    App  = var.prefix
  }
}

resource "aws_vpc_endpoint" "rds_data" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.rds-data"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.prefix}-rds-data-endpoint"
    App  = var.prefix
  }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.sns"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  tags = {
    Name = "${var.prefix}-sns-endpoint"
    App  = var.prefix
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  tags = {
    Name = "${var.prefix}-sqs-endpoint"
    App  = var.prefix
  }
}
