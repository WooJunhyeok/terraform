terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ------------------------
# 1. 네트워크 모듈 호출
# ------------------------
module "net" {
  source              = "./modules/net"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  public_subnet_az_id = var.public_subnet_az_id
  tags                = var.common_tags
}

# ------------------------
# 2. EC2 모듈 호출
# ------------------------
module "ec2" {
  source             = "./modules/ec2"
  subnet_id          = module.net.public_subnet_id
  security_group_id  = module.net.sg_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  tags               = var.common_tags
}
