variable "project"              { type = string }
variable "vpc_id"               { type = string }
variable "public_subnets"       { type = list(string) }
variable "allowed_ingress_cidrs"{ type = list(string) }
