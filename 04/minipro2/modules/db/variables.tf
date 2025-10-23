variable "project"        { type = string }
variable "vpc_id"         { type = string }
variable "db_subnet_ids"  { type = list(string) }
variable "db_username"    { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"  # Aurora MySQL 3 최소 권장
}