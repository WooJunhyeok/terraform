variable "region" {
    default = "us-east-2"
}

variable "vpc_cidr" {
    default = "190.160.0.0/16"
}

variable "subnet_cidr" {
    default = ["190.160.1.0/24", "190.160.2.0/24", "190.160.3.0/24"]
}
# slice([0,1,2], 0, 2)
# element([0,1,2], count.index)

# variable "asz" {
#     type = list
#     default = ["us-east-2a","us-east=2b","us-east-2c"]
# }

data "aws_availability_zones" "azs" {}