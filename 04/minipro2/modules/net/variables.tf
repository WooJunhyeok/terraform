variable "project"           { type = string }
variable "vpc_cidr"          { type = string }
variable "azs"               { type = list(string) }
variable "public_cidrs"      { type = list(string) }
variable "private_app_cidrs" { type = list(string) }
variable "private_db_cidrs"  { type = list(string) }