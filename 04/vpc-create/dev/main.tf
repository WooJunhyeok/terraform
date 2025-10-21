
#####################################
# AWS Provider
#####################################
provider "aws" {
  region = "ap-northeast-2"
}

#####################################
# module : myvpc
#####################################
module "myvpc" {
  source = "../modules/vpc"
  # Optional Parameters
  vpc_cidr = "192.168.0.0/24"
  subnet_cidr = "192.168.0.0/25"
}

module "myinstance" {
    source = "../modules/ec2"

    # Required Parameters
    ec2_count = 1
    subnet_id = module.myvpc.subnet_id
}