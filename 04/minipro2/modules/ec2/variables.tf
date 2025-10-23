variable "project"           { type = string }
variable "vpc_id"            { type = string }
variable "app_subnets"       { type = list(string) }
variable "instance_type"     { type = string }
variable "key_name"          { 
    type = string 
    default = null 
    }
variable "allowed_ssh_cidrs" { type = list(string) }
variable "target_group_arn"  { type = string }
variable "db_endpoint"       { type = string }
variable "db_username"       { type = string }
variable "db_password"       { 
    type = string 
    sensitive = true 
    }
variable "alb_sg_id"         { type = string }
variable "db_sg_id"          { type = string }
